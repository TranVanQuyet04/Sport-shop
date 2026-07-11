part of '../admin_sports_page.dart';

class _SportCard extends StatelessWidget {
  const _SportCard({
    required this.sport,
    required this.onEdit,
    required this.onDelete,
  });

  final SportModel sport;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasDescription = sport.description.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SuperSportsTheme.colorSurface,
        borderRadius: SuperSportsTheme.borderRadius,
        border: SuperSportsTheme.borderThin,
        boxShadow: SuperSportsTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SportIcon(name: sport.name),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _toTitleCaseSportName(sport.name).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(
                    color: SuperSportsTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  hasDescription ? sport.description : 'Chưa có mô tả chi tiết',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: hasDescription
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    fontSize: 13,
                    fontStyle: hasDescription
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Tùy chọn môn thể thao',
            icon: const Icon(Icons.chevron_right, color: Color(0xFFA0AEC0)),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Sửa')),
              PopupMenuItem(value: 'delete', child: Text('Xóa')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SportIcon extends StatelessWidget {
  const _SportIcon({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final style = _SportVisualStyle.resolve(name);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: SuperSportsTheme.borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(style.icon, color: style.iconColor, size: 24),
    );
  }
}

class _SportVisualStyle {
  const _SportVisualStyle({required this.icon, required this.iconColor});

  final IconData icon;
  final Color iconColor;

  static _SportVisualStyle resolve(String value) {
    final normalized = value.toLowerCase();
    if (_matches(normalized, ['bóng đá', 'bong da', 'football', 'soccer'])) {
      return const _SportVisualStyle(
        icon: Icons.sports_soccer_outlined,
        iconColor: SuperSportsTheme.colorPrimary,
      );
    }
    if (_matches(normalized, ['quần vợt', 'quan vot', 'tennis'])) {
      return const _SportVisualStyle(
        icon: Icons.sports_tennis_outlined,
        iconColor: SuperSportsTheme.colorAccent,
      );
    }
    if (_matches(normalized, ['cầu lông', 'cau long', 'badminton'])) {
      return const _SportVisualStyle(
        icon: Icons.sports_tennis_rounded,
        iconColor: Color(0xFF2563EB),
      );
    }
    if (_matches(normalized, ['bơi', 'boi', 'swim'])) {
      return const _SportVisualStyle(
        icon: Icons.pool_outlined,
        iconColor: Color(0xFF0891B2),
      );
    }
    if (_matches(normalized, ['chạy', 'chay', 'running', 'run'])) {
      return const _SportVisualStyle(
        icon: Icons.directions_run_outlined,
        iconColor: Color(0xFFF97316),
      );
    }
    if (_matches(normalized, ['đua', 'dua', 'race', 'motorsport', 'racing'])) {
      return const _SportVisualStyle(
        icon: Icons.sports_motorsports_outlined,
        iconColor: Color(0xFFDC2626),
      );
    }
    if (_matches(normalized, ['golf'])) {
      return const _SportVisualStyle(
        icon: Icons.sports_golf_outlined,
        iconColor: Color(0xFF15803D),
      );
    }
    if (_matches(normalized, ['bóng rổ', 'bong ro', 'basketball'])) {
      return const _SportVisualStyle(
        icon: Icons.sports_basketball_outlined,
        iconColor: Color(0xFFEA580C),
      );
    }
    if (_matches(normalized, ['gym', 'fitness'])) {
      return const _SportVisualStyle(
        icon: Icons.fitness_center_rounded,
        iconColor: Color(0xFF0F172A),
      );
    }
    return const _SportVisualStyle(
      icon: Icons.sports_outlined,
      iconColor: Color(0xFF475569),
    );
  }

  static bool _matches(String value, List<String> keywords) {
    return keywords.any(value.contains);
  }
}

String _toTitleCaseSportName(String value) {
  final lower = value.trim().toLowerCase();
  if (lower.isEmpty) {
    return value;
  }

  final buffer = StringBuffer();
  var shouldCapitalize = true;
  for (final rune in lower.runes) {
    final character = String.fromCharCode(rune);
    if (shouldCapitalize &&
        RegExp(r'\p{L}', unicode: true).hasMatch(character)) {
      buffer.write(character.toUpperCase());
      shouldCapitalize = false;
      continue;
    }

    buffer.write(character);
    if (character == '(' || character == '/' || character == '-') {
      shouldCapitalize = true;
    }
  }
  return buffer.toString();
}

class _PremiumAddButton extends StatelessWidget {
  const _PremiumAddButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 76),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled
                ? SuperSportsTheme.colorPrimary
                : AppColors.textSecondary,
            borderRadius: SuperSportsTheme.borderRadius,
            boxShadow: SuperSportsTheme.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: SuperSportsTheme.borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              child: const Center(
                child: Text(
                  'THÊM MÔN THỂ THAO MỚI +',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
