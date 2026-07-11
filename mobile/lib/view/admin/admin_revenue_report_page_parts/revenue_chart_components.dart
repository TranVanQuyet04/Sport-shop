import 'package:flutter/material.dart';

// ── BAR ITEM COMPONENT FOR THE CHART ───────────────────────────────────────
class RevenueBarItem extends StatelessWidget {
  const RevenueBarItem({
    super.key,
    required this.day,
    required this.valueCurrent,
    required this.valuePrev,
    required this.isSelected,
  });

  final String day;
  final double valueCurrent; // 0.0 to 1.0
  final double valuePrev; // 0.0 to 1.0
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const double maxBarHeight = 100;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.03 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 126),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFDBEAFE).withValues(alpha: 0.72)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF93C5FD)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: (maxBarHeight * valuePrev)
                        .clamp(4, maxBarHeight)
                        .toDouble(),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 7,
                    height: (maxBarHeight * valueCurrent)
                        .clamp(4, maxBarHeight)
                        .toDouble(),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [const Color(0xFFD97706), const Color(0xFF2563EB)]
                            : [
                                const Color(0xFF60A5FA),
                                const Color(0xFF2563EB),
                              ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            day,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected
                  ? const Color(0xFF1E293B)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class RevenueLegendItem extends StatelessWidget {
  const RevenueLegendItem({
    super.key,
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}
