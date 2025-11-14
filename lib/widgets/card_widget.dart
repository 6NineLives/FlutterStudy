import 'package:flutter/material.dart';

/// Reusable card widget with pastel color scheme
/// Used throughout the app for consistent design
class CardWidget extends StatelessWidget {
  final Widget child;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;

  const CardWidget({
    Key? key,
    required this.child,
    this.color,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? 2,
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: card,
        ),
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: card,
    );
  }
}

/// Study kit card widget
class StudyKitCard extends StatelessWidget {
  final String title;
  final String? description;
  final int flashcardCount;
  final int quizCount;
  final VoidCallback? onTap;

  const StudyKitCard({
    Key? key,
    required this.title,
    this.description,
    required this.flashcardCount,
    required this.quizCount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      color: const Color(0xFFE8F5E9), // Pastel green
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBadge(
                icon: Icons.style,
                label: '$flashcardCount cards',
                color: const Color(0xFF1976D2),
              ),
              const SizedBox(width: 12),
              _buildBadge(
                icon: Icons.quiz,
                label: '$quizCount quizzes',
                color: const Color(0xFFE91E63),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
