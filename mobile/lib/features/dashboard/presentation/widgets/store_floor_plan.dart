import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/store_layout_entities.dart';

class StoreFloorPlan extends StatelessWidget {
  const StoreFloorPlan({
    required this.fixtures,
    required this.isEditing,
    required this.selectedFixtureId,
    required this.onFixtureSelected,
    required this.onFixtureMoveStarted,
    required this.onFixtureMoved,
    super.key,
  });

  final List<StoreFixture> fixtures;
  final bool isEditing;
  final String? selectedFixtureId;
  final ValueChanged<String> onFixtureSelected;
  final VoidCallback onFixtureMoveStarted;
  final void Function(String id, double deltaX, double deltaY) onFixtureMoved;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 2.5,
        panEnabled: !isEditing,
        scaleEnabled: !isEditing,
        child: AspectRatio(
          aspectRatio: .78,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFCFE),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: _GridPainter()),
                    ),
                    Positioned(
                      left: constraints.maxWidth * .43,
                      bottom: 0,
                      width: constraints.maxWidth * .18,
                      height: 18,
                      child: const _EntranceMarker(),
                    ),
                    for (final fixture in fixtures)
                      _PositionedFixture(
                        fixture: fixture,
                        canvasSize: constraints.biggest,
                        isEditing: isEditing,
                        isSelected: fixture.id == selectedFixtureId,
                        onSelected: () => onFixtureSelected(fixture.id),
                        onMoveStarted: onFixtureMoveStarted,
                        onMoved: (delta) => onFixtureMoved(
                          fixture.id,
                          delta.dx / constraints.maxWidth,
                          delta.dy / constraints.maxHeight,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PositionedFixture extends StatelessWidget {
  const _PositionedFixture({
    required this.fixture,
    required this.canvasSize,
    required this.isEditing,
    required this.isSelected,
    required this.onSelected,
    required this.onMoveStarted,
    required this.onMoved,
  });

  final StoreFixture fixture;
  final Size canvasSize;
  final bool isEditing;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onMoveStarted;
  final ValueChanged<Offset> onMoved;

  @override
  Widget build(BuildContext context) {
    final style = _fixtureStyle(fixture.type);
    return Positioned(
      left: fixture.x * canvasSize.width,
      top: fixture.y * canvasSize.height,
      width: fixture.width * canvasSize.width,
      height: fixture.height * canvasSize.height,
      child: Semantics(
        button: true,
        label:
            '${style.typeLabel} ${fixture.label}, ${fixture.productIds.length} produk',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSelected,
          onPanStart: isEditing
              ? (_) {
                  onSelected();
                  onMoveStarted();
                }
              : null,
          onPanUpdate: isEditing ? (details) => onMoved(details.delta) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.primary : style.border,
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x24565C9D),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(style.icon, color: style.foreground, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    fixture.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: style.foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (fixture.productIds.isNotEmpty)
                    Text(
                      '${fixture.productIds.length} produk',
                      maxLines: 1,
                      style: TextStyle(color: style.foreground, fontSize: 10),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntranceMarker extends StatelessWidget {
  const _EntranceMarker();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.slate50,
        border: Border(top: BorderSide(color: AppTheme.muted, width: 2)),
      ),
      child: Center(
        child: Text(
          'PINTU',
          style: TextStyle(
            color: AppTheme.muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFECECF3)
      ..strokeWidth = 1;
    const spacing = 24.0;
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

typedef _FixtureStyle = ({
  Color background,
  Color border,
  Color foreground,
  IconData icon,
  String typeLabel,
});

_FixtureStyle _fixtureStyle(StoreFixtureType type) => switch (type) {
  StoreFixtureType.shelf => (
    background: const Color(0xFFECECF8),
    border: const Color(0xFFB8BBDE),
    foreground: const Color(0xFF3E4378),
    icon: Icons.view_column_outlined,
    typeLabel: 'Rak',
  ),
  StoreFixtureType.cabinet => (
    background: const Color(0xFFF2EEFA),
    border: const Color(0xFFC8BDE2),
    foreground: const Color(0xFF5F4F87),
    icon: Icons.door_sliding_outlined,
    typeLabel: 'Lemari',
  ),
  StoreFixtureType.refrigerator => (
    background: const Color(0xFFE9F2F8),
    border: const Color(0xFFA8C6D8),
    foreground: const Color(0xFF365E75),
    icon: Icons.kitchen_outlined,
    typeLabel: 'Kulkas',
  ),
  StoreFixtureType.cashier => (
    background: const Color(0xFFEEF0F8),
    border: const Color(0xFFAFB5CE),
    foreground: const Color(0xFF424965),
    icon: Icons.point_of_sale_outlined,
    typeLabel: 'Meja kasir',
  ),
  StoreFixtureType.display => (
    background: const Color(0xFFF6EDF5),
    border: const Color(0xFFD5BBD0),
    foreground: const Color(0xFF75526E),
    icon: Icons.inventory_2_outlined,
    typeLabel: 'Etalase',
  ),
};
