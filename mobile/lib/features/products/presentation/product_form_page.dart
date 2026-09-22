import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({
    required this.repository,
    required this.storeId,
    this.product,
    super.key,
  });

  final ProductRepository repository;
  final String storeId;
  final ProductEntity? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  static const _categories = [
    'Makanan',
    'Minuman',
    'Sembako',
    'Kebutuhan rumah',
    'Perawatan diri',
    'Lainnya',
  ];

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minimumStockController;
  late final TextEditingController _leadTimeDaysController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _shelfController;
  late final TextEditingController _aiLabelController;
  late String _category;
  String? _newPhotoPath;
  bool _removePhoto = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name);
    _purchasePriceController = TextEditingController(
      text: product?.purchasePrice.toString() ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: product?.sellingPrice.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: product?.stock.toString() ?? '0',
    );
    _minimumStockController = TextEditingController(
      text: product?.minimumStock.toString() ?? '0',
    );
    _leadTimeDaysController = TextEditingController(
      text: product?.leadTimeDays.toString() ?? '3',
    );
    _barcodeController = TextEditingController(text: product?.barcode);
    _shelfController = TextEditingController(text: product?.shelfLocation);
    _aiLabelController = TextEditingController(text: product?.aiLabel);
    _category = _categories.contains(product?.category)
        ? product!.category
        : _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();
    _leadTimeDaysController.dispose();
    _barcodeController.dispose();
    _shelfController.dispose();
    _aiLabelController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (image == null || !mounted) return;
      setState(() {
        _newPhotoPath = image.path;
        _removePhoto = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto belum dapat dipilih. Coba lagi.')),
      );
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final productId = widget.product?.id ?? const Uuid().v4();
    final barcode = _blankToNull(_barcodeController.text);
    try {
      if (barcode != null &&
          !await widget.repository.isBarcodeAvailable(
            widget.storeId,
            barcode,
            excludingProductId: widget.product?.id,
          )) {
        throw DuplicateProductBarcode(barcode);
      }
      var photoUri = _removePhoto ? null : widget.product?.photoUri;
      final newPhotoPath = _newPhotoPath;
      if (newPhotoPath != null) {
        photoUri = await _persistPhoto(newPhotoPath, productId);
      }
      await widget.repository.saveProduct(
        ProductEntity(
          id: productId,
          storeId: widget.storeId,
          name: _nameController.text.trim(),
          category: _category,
          purchasePrice: int.parse(_purchasePriceController.text),
          sellingPrice: int.parse(_sellingPriceController.text),
          stock: int.parse(_stockController.text),
          minimumStock: int.parse(_minimumStockController.text),
          leadTimeDays: int.parse(_leadTimeDaysController.text),
          barcode: barcode,
          photoUri: photoUri,
          shelfLocation: _blankToNull(_shelfController.text),
          aiLabel: _blankToNull(_aiLabelController.text),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on DuplicateProductBarcode catch (error) {
      setState(() => _errorMessage = error.toString());
    } catch (_) {
      setState(() {
        _errorMessage = 'Produk gagal disimpan. Periksa data lalu coba lagi.';
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<String> _persistPhoto(String sourcePath, String productId) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(path.join(root.path, 'product_photos'));
    await directory.create(recursive: true);
    final extension = path.extension(sourcePath).isEmpty
        ? '.jpg'
        : path.extension(sourcePath);
    final destination = path.join(
      directory.path,
      '$productId-${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    return (await File(sourcePath).copy(destination)).path;
  }

  @override
  Widget build(BuildContext context) {
    final photoPath = _removePhoto
        ? null
        : (_newPhotoPath ?? widget.product?.photoUri);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Text(
          _isEditing ? 'Edit produk' : 'Produk baru',
          style: AppTextStyles.editorialTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            _PhotoPicker(
              photoPath: photoPath,
              onPick: _isSaving ? null : _pickPhoto,
              onRemove: photoPath == null || _isSaving
                  ? null
                  : () => setState(() {
                      _newPhotoPath = null;
                      _removePhoto = true;
                    }),
            ),
            const SizedBox(height: 32),
            const _FormSectionTitle(
              title: 'Informasi produk',
              description: 'Nama yang mudah dicari mempercepat transaksi.',
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('product-name'),
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Nama produk',
                hintText: 'Contoh: Air mineral 600 ml',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama produk wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(growable: false),
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() => _category = value ?? _category),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Divider(height: 1),
            ),
            const _FormSectionTitle(
              title: 'Harga dan stok',
              description: 'Semua nominal disimpan dalam rupiah.',
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _NumberField(
                    fieldKey: const ValueKey('purchase-price'),
                    controller: _purchasePriceController,
                    label: 'Harga beli',
                    prefixText: 'Rp ',
                    allowZero: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    fieldKey: const ValueKey('selling-price'),
                    controller: _sellingPriceController,
                    label: 'Harga jual',
                    prefixText: 'Rp ',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _stockController,
                    label: 'Stok saat ini',
                    allowZero: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    controller: _minimumStockController,
                    label: 'Stok pengaman',
                    allowZero: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NumberField(
              fieldKey: const ValueKey('lead-time-days'),
              controller: _leadTimeDaysController,
              label: 'Waktu tunggu pemasok',
              suffixText: ' hari',
              helperText:
                  'Perkiraan sejak pesan sampai barang diterima (1–365 hari).',
              maximum: 365,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Divider(height: 1),
            ),
            const _FormSectionTitle(
              title: 'Identitas dan lokasi',
              description: 'Barcode harus unik untuk setiap produk.',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Barcode (opsional)',
                hintText: 'Ketik atau pindai barcode',
                prefixIcon: Icon(Icons.qr_code_2_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _shelfController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Lokasi rak (opsional)',
                hintText: 'Contoh: Rak A, tingkat 2',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _aiLabelController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Label model AI (opsional)',
                hintText: 'Contoh: air_mineral_600ml',
                prefixIcon: Icon(Icons.auto_awesome_outlined),
              ),
            ),
            if (_errorMessage case final error?) ...[
              const SizedBox(height: 16),
              _FormError(message: error),
            ],
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: FilledButton.icon(
            key: const ValueKey('save-product'),
            onPressed: _isSaving ? null : _submit,
            icon: _isSaving
                ? const AppSpinner(size: 18, color: Colors.white)
                : const Icon(Icons.check_rounded),
            label: Text(_isSaving ? 'Menyimpan…' : 'Simpan produk'),
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photoPath,
    required this.onPick,
    required this.onRemove,
  });

  final String? photoPath;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    final hasPhoto = path != null && path.isNotEmpty && File(path).existsSync();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 88,
                height: 88,
                child: hasPhoto
                    ? Image.file(File(path), fit: BoxFit.cover)
                    : const ColoredBox(
                        color: AppColors.slate50,
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 34,
                          color: AppColors.slate600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasPhoto ? 'Foto produk' : 'Tambahkan foto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Foto membantu kasir mengenali produk lebih cepat.',
                    style: TextStyle(color: AppColors.muted, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: onPick,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(hasPhoto ? 'Ganti' : 'Pilih foto'),
                      ),
                      if (hasPhoto)
                        TextButton(
                          onPressed: onRemove,
                          child: const Text('Hapus'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            color: AppColors.ink,
            fontSize: 20,
            height: 1.2,
            letterSpacing: -.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: AppColors.muted, height: 1.4),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    this.fieldKey,
    required this.controller,
    required this.label,
    this.prefixText,
    this.suffixText,
    this.helperText,
    this.allowZero = false,
    this.maximum,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String label;
  final String? prefixText;
  final String? suffixText;
  final String? helperText;
  final bool allowZero;
  final int? maximum;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        suffixText: suffixText,
        helperText: helperText,
      ),
      validator: (value) {
        final number = int.tryParse(value ?? '');
        if (number == null) return 'Wajib diisi';
        if (number < 0 || (!allowZero && number == 0)) return 'Tidak valid';
        if (maximum case final limit? when number > limit) {
          return 'Maksimal $limit';
        }
        return null;
      },
    );
  }
}

class _FormError extends StatelessWidget {
  const _FormError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _blankToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
