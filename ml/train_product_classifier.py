"""Train, calibrate, and export RyanGunshop's SKU classifier.

The script deliberately refuses undersized datasets and only marks a manifest
production-ready when held-out accuracy, accepted precision, and coverage pass
the declared gates. Raw product photos stay outside Git.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import re
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image

IMAGE_SUFFIXES = {".jpg", ".jpeg", ".png", ".webp"}
LABEL_PATTERN = re.compile(r"^(?:__unknown__|[a-z0-9][a-z0-9._-]{1,63})$")
IMAGE_SIZE = 224
MIN_IMAGES_PER_CLASS = 40
MIN_SKU_CLASSES = 2
SEED = 20260927


@dataclass(frozen=True)
class Sample:
    path: Path
    label_index: int


def parse_args() -> argparse.Namespace:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset", type=Path, default=root / "ml" / "dataset")
    parser.add_argument(
        "--output", type=Path, default=root / "mobile" / "assets" / "models"
    )
    parser.add_argument("--head-epochs", type=int, default=12)
    parser.add_argument("--fine-tune-epochs", type=int, default=8)
    parser.add_argument("--batch-size", type=int, default=16)
    return parser.parse_args()


def discover_dataset(dataset: Path) -> tuple[list[str], dict[str, list[Path]]]:
    classes: dict[str, list[Path]] = {}
    for directory in sorted(path for path in dataset.iterdir() if path.is_dir()):
        label = directory.name
        if not LABEL_PATTERN.fullmatch(label):
            raise ValueError(f"Label tidak valid: {label}")
        images = sorted(
            path for path in directory.rglob("*")
            if path.is_file() and path.suffix.lower() in IMAGE_SUFFIXES
        )
        if len(images) < MIN_IMAGES_PER_CLASS:
            raise ValueError(
                f"{label} hanya memiliki {len(images)} foto; "
                f"minimal {MIN_IMAGES_PER_CLASS}."
            )
        for image_path in images:
            with Image.open(image_path) as image:
                image.verify()
        classes[label] = images
    if "__unknown__" not in classes:
        raise ValueError("Dataset wajib memiliki kelas __unknown__.")
    if len(classes) - 1 < MIN_SKU_CLASSES:
        raise ValueError(f"Dataset wajib memiliki minimal {MIN_SKU_CLASSES} kelas SKU.")
    return sorted(classes), classes


def split_samples(
    labels: list[str], classes: dict[str, list[Path]]
) -> tuple[list[Sample], list[Sample], list[Sample]]:
    rng = random.Random(SEED)
    train: list[Sample] = []
    validation: list[Sample] = []
    test: list[Sample] = []
    for label_index, label in enumerate(labels):
        paths = list(classes[label])
        rng.shuffle(paths)
        test_count = max(1, round(len(paths) * .15))
        validation_count = max(1, round(len(paths) * .15))
        test.extend(Sample(path, label_index) for path in paths[:test_count])
        validation.extend(
            Sample(path, label_index)
            for path in paths[test_count:test_count + validation_count]
        )
        train.extend(
            Sample(path, label_index)
            for path in paths[test_count + validation_count:]
        )
    rng.shuffle(train)
    rng.shuffle(validation)
    rng.shuffle(test)
    return train, validation, test


def dataset_from(samples: list[Sample], batch_size: int, training: bool):
    import tensorflow as tf

    paths = [str(sample.path) for sample in samples]
    labels = [sample.label_index for sample in samples]
    dataset = tf.data.Dataset.from_tensor_slices((paths, labels))
    if training:
        dataset = dataset.shuffle(len(samples), seed=SEED, reshuffle_each_iteration=True)

    def decode(path, label):
        content = tf.io.read_file(path)
        image = tf.io.decode_image(content, channels=3, expand_animations=False)
        image.set_shape([None, None, 3])
        image = tf.image.resize(image, [IMAGE_SIZE, IMAGE_SIZE])
        return tf.cast(image, tf.float32), label

    return (
        dataset.map(decode, num_parallel_calls=tf.data.AUTOTUNE)
        .batch(batch_size)
        .prefetch(tf.data.AUTOTUNE)
    )


def build_model(class_count: int):
    import tensorflow as tf

    augmentation = tf.keras.Sequential(
        [
            tf.keras.layers.RandomFlip("horizontal", seed=SEED),
            tf.keras.layers.RandomRotation(.08, seed=SEED),
            tf.keras.layers.RandomZoom(.15, seed=SEED),
            tf.keras.layers.RandomContrast(.2, seed=SEED),
        ],
        name="augmentation",
    )
    base = tf.keras.applications.MobileNetV2(
        input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3),
        include_top=False,
        weights="imagenet",
        pooling="avg",
    )
    base.trainable = False
    inputs = tf.keras.Input((IMAGE_SIZE, IMAGE_SIZE, 3), name="rgb_0_255")
    x = augmentation(inputs)
    x = tf.keras.layers.Rescaling(1 / 127.5, offset=-1)(x)
    x = base(x, training=False)
    x = tf.keras.layers.Dropout(.25)(x)
    outputs = tf.keras.layers.Dense(class_count, activation="softmax")(x)
    model = tf.keras.Model(inputs, outputs)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-3),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model, base


def calibrate(probabilities: np.ndarray, expected: np.ndarray) -> dict[str, float]:
    predicted = probabilities.argmax(axis=1)
    confidence = probabilities.max(axis=1)
    correct = predicted == expected
    selected = None
    for threshold in np.arange(.50, .951, .01):
        accepted = confidence >= threshold
        coverage = float(accepted.mean())
        precision = float(correct[accepted].mean()) if accepted.any() else 0.0
        if precision >= .95 and coverage >= .50:
            selected = (float(threshold), precision, coverage)
            break
    if selected is None:
        threshold = .90
        accepted = confidence >= threshold
        selected = (
            threshold,
            float(correct[accepted].mean()) if accepted.any() else 0.0,
            float(accepted.mean()),
        )
    return {
        "threshold": round(selected[0], 2),
        "acceptedPrecision": round(selected[1], 4),
        "coverage": round(selected[2], 4),
        "testAccuracy": round(float(correct.mean()), 4),
    }


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for block in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> None:
    args = parse_args()
    labels, classes = discover_dataset(args.dataset)
    train_samples, validation_samples, test_samples = split_samples(labels, classes)

    import tensorflow as tf

    tf.keras.utils.set_random_seed(SEED)
    train = dataset_from(train_samples, args.batch_size, True)
    validation = dataset_from(validation_samples, args.batch_size, False)
    test = dataset_from(test_samples, args.batch_size, False)
    model, base = build_model(len(labels))
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_accuracy", patience=3, restore_best_weights=True
        )
    ]
    model.fit(
        train,
        validation_data=validation,
        epochs=args.head_epochs,
        callbacks=callbacks,
    )
    base.trainable = True
    for layer in base.layers[:-30]:
        layer.trainable = False
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-5),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    model.fit(
        train,
        validation_data=validation,
        epochs=args.fine_tune_epochs,
        callbacks=callbacks,
    )

    probabilities = model.predict(test, verbose=0)
    expected = np.concatenate([batch.numpy() for _, batch in test])
    metrics = calibrate(probabilities, expected)
    production_ready = (
        metrics["testAccuracy"] >= .85
        and metrics["acceptedPrecision"] >= .95
        and metrics["coverage"] >= .50
    )

    args.output.mkdir(parents=True, exist_ok=True)
    model_path = args.output / "product_classifier.tflite"
    labels_path = args.output / "labels.txt"
    manifest_path = args.output / "product_classifier.manifest.json"
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    model_path.write_bytes(converter.convert())
    labels_path.write_text("\n".join(labels) + "\n", encoding="utf-8")
    manifest = {
        "schemaVersion": 1,
        "modelVersion": "ryangunshop-sku-mobilenetv2-v1",
        "architecture": "MobileNetV2 1.0 224 float16 weights",
        "modelAsset": "assets/models/product_classifier.tflite",
        "labelsAsset": "assets/models/labels.txt",
        "modelSha256": sha256(model_path),
        "labelsSha256": sha256(labels_path),
        "inputWidth": IMAGE_SIZE,
        "inputHeight": IMAGE_SIZE,
        "inputMean": 0,
        "inputStd": 1,
        "labelCount": len(labels),
        "recommendedThreshold": metrics["threshold"],
        "productionReady": production_ready,
        "purpose": "Klasifikasi SKU RyanGunshop dari dataset privat terkalibrasi.",
        "source": "ml/dataset (lokal, tidak disimpan di Git)",
        "metrics": metrics,
        "dataset": {
            "classCount": len(labels),
            "trainImages": len(train_samples),
            "validationImages": len(validation_samples),
            "testImages": len(test_samples),
            "minimumImagesPerClass": min(map(len, classes.values())),
        },
    }
    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest, indent=2, ensure_ascii=False))
    if not production_ready:
        raise SystemExit(
            "Model diekspor tetapi productionReady=false karena quality gate gagal."
        )


if __name__ == "__main__":
    main()
