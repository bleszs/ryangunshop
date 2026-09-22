import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../domain/entities/panorama_entities.dart';
import '../../../../domain/entities/store_layout_entities.dart';
import '../../application/store_panorama_controller.dart';

class StorePanoramaPanel extends StatelessWidget {
  const StorePanoramaPanel({
    required this.controller,
    required this.fixtures,
    required this.canManage,
    required this.onFixtureSelected,
    super.key,
  });

  final StorePanoramaController controller;
  final List<StoreFixture> fixtures;
  final bool canManage;
  final ValueChanged<String> onFixtureSelected;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const SizedBox(
        height: 420,
        child: AppLoadingView(label: 'Memuat foto 360\u00b0\u2026'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.errorMessage case final message?) ...[
          _InlineMessage(message: message, onClose: controller.clearError),
          const SizedBox(height: 12),
        ],
        if (controller.zones.isEmpty)
          _EmptyPanorama(
            canManage: canManage,
            isImporting: controller.isImporting,
            onImport: () => _importPanorama(context),
          )
        else ...[
          _ZoneToolbar(
            controller: controller,
            canManage: canManage,
            onImport: () => _importPanorama(context),
            onDelete: () => _confirmDelete(context),
          ),
          const SizedBox(height: 12),
          if (controller.selectedZone case final zone?)
            _PanoramaViewport(
              key: ValueKey('${zone.id}-${controller.useStaticPreview}'),
              zone: zone,
              fixtures: fixtures,
              canManage: canManage,
              useStaticPreview: controller.useStaticPreview,
              onStaticPreviewChanged: controller.setStaticPreview,
              onRendererFailed: controller.showRendererFallback,
              onFixtureSelected: onFixtureSelected,
              onPlaceHotspot: (longitude, latitude) => _chooseFixture(
                context,
                longitude: longitude,
                latitude: latitude,
              ),
              onRemoveHotspot: (fixtureId) =>
                  controller.removeHotspot(fixtureId),
            ),
        ],
      ],
    );
  }

  Future<void> _importPanorama(BuildContext context) async {
    final name = await _askZoneName(context);
    if (name == null || !context.mounted) return;
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !context.mounted) return;
    final success = await controller.importZone(
      name: name,
      sourceImagePath: image.path,
    );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto 360\u00b0 tersimpan di perangkat.')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final zone = controller.selectedZone;
    if (zone == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus zona?'),
        content: Text(
          'Foto dan hotspot "${zone.name}" akan dihapus dari perangkat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.deleteSelectedZone();
  }

  Future<void> _chooseFixture(
    BuildContext context, {
    required double longitude,
    required double latitude,
  }) async {
    final zone = controller.selectedZone;
    if (!canManage || zone == null) return;
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tautkan lokasi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih rak atau fasilitas untuk titik yang ditekan.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: fixtures.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final fixture = fixtures[index];
                    final exists = zone.hotspots.any(
                      (hotspot) => hotspot.fixtureId == fixture.id,
                    );
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_fixtureIcon(fixture.type)),
                      title: Text(fixture.label),
                      subtitle: Text(
                        exists
                            ? 'Pindahkan hotspot yang sudah ada'
                            : '${fixture.productIds.length} produk tertaut',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pop(context, fixture.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selectedId == null) return;
    await controller.placeHotspot(
      fixtureId: selectedId,
      longitude: longitude,
      latitude: latitude,
    );
  }
}

class _ZoneToolbar extends StatelessWidget {
  const _ZoneToolbar({
    required this.controller,
    required this.canManage,
    required this.onImport,
    required this.onDelete,
  });

  final StorePanoramaController controller;
  final bool canManage;
  final VoidCallback onImport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final zone in controller.zones) ...[
                  ChoiceChip(
                    label: Text(zone.name),
                    selected: controller.selectedZone?.id == zone.id,
                    onSelected: (_) => controller.selectZone(zone.id),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        if (canManage) ...[
          IconButton(
            tooltip: 'Tambah foto 360\u00b0',
            onPressed: controller.isImporting ? null : onImport,
            icon: controller.isImporting
                ? const AppSpinner(size: 20)
                : const Icon(Icons.add_photo_alternate_outlined),
          ),
          IconButton(
            tooltip: 'Hapus zona ini',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ],
    );
  }
}

class _PanoramaViewport extends StatefulWidget {
  const _PanoramaViewport({
    required this.zone,
    required this.fixtures,
    required this.canManage,
    required this.useStaticPreview,
    required this.onStaticPreviewChanged,
    required this.onRendererFailed,
    required this.onFixtureSelected,
    required this.onPlaceHotspot,
    required this.onRemoveHotspot,
    super.key,
  });

  final PanoramaZoneEntity zone;
  final List<StoreFixture> fixtures;
  final bool canManage;
  final bool useStaticPreview;
  final ValueChanged<bool> onStaticPreviewChanged;
  final VoidCallback onRendererFailed;
  final ValueChanged<String> onFixtureSelected;
  final Future<void> Function(double longitude, double latitude) onPlaceHotspot;
  final Future<void> Function(String fixtureId) onRemoveHotspot;

  @override
  State<_PanoramaViewport> createState() => _PanoramaViewportState();
}

class _PanoramaViewportState extends State<_PanoramaViewport> {
  Timer? _loadTimer;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!widget.useStaticPreview) {
      _loadTimer = Timer(const Duration(seconds: 8), () {
        if (mounted && !_imageLoaded) widget.onRendererFailed();
      });
    }
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fixtureById = {
      for (final fixture in widget.fixtures) fixture.id: fixture,
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.surface),
      child: AspectRatio(
        aspectRatio: .82,
        child: ColoredBox(
          color: AppColors.slate900,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.useStaticPreview)
                _StaticPanoramaPreview(zone: widget.zone)
              else
                PanoramaViewer(
                  key: ValueKey(widget.zone.imagePath),
                  animSpeed: 0,
                  minZoom: 1,
                  maxZoom: 4,
                  latSegments: 24,
                  lonSegments: 48,
                  sensorControl: SensorControl.none,
                  onImageLoad: () {
                    _loadTimer?.cancel();
                    if (!mounted) return;
                    setState(() => _imageLoaded = true);
                  },
                  onLongPressEnd: widget.canManage
                      ? (longitude, latitude, _) => widget.onPlaceHotspot(
                          longitude,
                          latitude.clamp(-75, 75),
                        )
                      : null,
                  hotspots: [
                    for (final hotspot in widget.zone.hotspots)
                      if (fixtureById[hotspot.fixtureId] case final fixture?)
                        Hotspot(
                          name: hotspot.fixtureId,
                          longitude: hotspot.longitude,
                          latitude: hotspot.latitude,
                          width: 124,
                          height: 48,
                          widget: _HotspotChip(
                            fixture: fixture,
                            canRemove: widget.canManage,
                            onTap: () => widget.onFixtureSelected(fixture.id),
                            onRemove: () => widget.onRemoveHotspot(fixture.id),
                          ),
                        ),
                  ],
                  child: Image.file(File(widget.zone.imagePath)),
                ),
              if (!widget.useStaticPreview && !_imageLoaded)
                const IgnorePointer(
                  child: ColoredBox(
                    color: AppColors.slate900,
                    child: AppLoadingView(
                      label: 'Menyiapkan panorama\u2026',
                      light: true,
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _GlassLabel(
                        icon: widget.useStaticPreview
                            ? Icons.photo_outlined
                            : Icons.threesixty_rounded,
                        label: widget.useStaticPreview
                            ? 'Preview hemat daya'
                            : 'Geser untuk melihat sekitar',
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ViewerModeButton(
                      useStaticPreview: widget.useStaticPreview,
                      onChanged: widget.onStaticPreviewChanged,
                    ),
                  ],
                ),
              ),
              if (widget.canManage && !widget.useStaticPreview)
                const Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _GlassLabel(
                    icon: Icons.touch_app_outlined,
                    label: 'Tekan lama untuk menambah hotspot rak',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticPanoramaPreview extends StatelessWidget {
  const _StaticPanoramaPreview({required this.zone});
  final PanoramaZoneEntity zone;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 3,
      child: SizedBox.expand(
        child: Image.file(
          File(zone.thumbnailPath),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _BrokenImage(),
        ),
      ),
    );
  }
}

class _ViewerModeButton extends StatelessWidget {
  const _ViewerModeButton({
    required this.useStaticPreview,
    required this.onChanged,
  });

  final bool useStaticPreview;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: useStaticPreview
          ? 'Aktifkan panorama 360\u00b0'
          : 'Mode hemat daya',
      child: Material(
        color: AppColors.slate900.withValues(alpha: .86),
        borderRadius: BorderRadius.circular(12),
        child: IconButton(
          onPressed: () => onChanged(!useStaticPreview),
          color: Colors.white,
          icon: Icon(
            useStaticPreview
                ? Icons.threesixty_rounded
                : Icons.battery_saver_outlined,
          ),
        ),
      ),
    );
  }
}

class _HotspotChip extends StatelessWidget {
  const _HotspotChip({
    required this.fixture,
    required this.canRemove,
    required this.onTap,
    required this.onRemove,
  });

  final StoreFixture fixture;
  final bool canRemove;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buka ${fixture.label}',
      child: Material(
        color: AppColors.slate900.withValues(alpha: .92),
        shape: const StadiumBorder(side: BorderSide(color: AppColors.slate300)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: canRemove ? onRemove : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_fixtureIcon(fixture.type), color: Colors.white, size: 18),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    fixture.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassLabel extends StatelessWidget {
  const _GlassLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.slate900.withValues(alpha: .86),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.slate200, size: 17),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPanorama extends StatelessWidget {
  const _EmptyPanorama({
    required this.canManage,
    required this.isImporting,
    required this.onImport,
  });

  final bool canManage;
  final bool isImporting;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 380),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(AppRadii.surface),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.threesixty_rounded, size: 56, color: Colors.white),
          const SizedBox(height: 18),
          const Text(
            'Belum ada foto 360\u00b0',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canManage
                ? 'Tambahkan foto equirectangular rasio 2:1, lalu tandai posisi rak dan kulkas.'
                : 'Pemilik warung belum menambahkan panorama untuk lokasi ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.slate200, height: 1.45),
          ),
          if (canManage) ...[
            const SizedBox(height: 22),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.slate900,
              ),
              onPressed: isImporting ? null : onImport,
              icon: isImporting
                  ? const AppSpinner(size: 18, color: AppColors.slate900)
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                isImporting ? 'Mengoptimalkan\u2026' : 'Pilih foto 360\u00b0',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, required this.onClose});
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF2F3),
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
            IconButton(
              tooltip: 'Tutup pesan',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.slate900,
      child: Center(
        child: Text(
          'Preview foto tidak tersedia.',
          style: TextStyle(color: AppColors.slate200),
        ),
      ),
    );
  }
}

Future<String?> _askZoneName(BuildContext context) async {
  final textController = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tambah zona 360\u00b0'),
      content: TextField(
        controller: textController,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Nama zona',
          hintText: 'Contoh: Area rak depan',
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) Navigator.pop(context, value.trim());
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final value = textController.text.trim();
            if (value.isNotEmpty) Navigator.pop(context, value);
          },
          child: const Text('Pilih foto'),
        ),
      ],
    ),
  );
  textController.dispose();
  return result;
}

IconData _fixtureIcon(StoreFixtureType type) => switch (type) {
  StoreFixtureType.shelf => Icons.shelves,
  StoreFixtureType.cabinet => Icons.inventory_2_outlined,
  StoreFixtureType.refrigerator => Icons.kitchen_outlined,
  StoreFixtureType.cashier => Icons.point_of_sale_outlined,
  StoreFixtureType.display => Icons.view_in_ar_outlined,
};
