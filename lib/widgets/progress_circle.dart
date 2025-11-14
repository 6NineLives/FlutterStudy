import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Circular progress indicator widget
/// Shows mastery level or progress percentage
class ProgressCircle extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? child;

  const ProgressCircle({
    Key? key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.color,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? _getColorForProgress(progress);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: 1.0,
              color: Colors.grey[200]!,
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress circle
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: progress,
              color: progressColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // Center content
          if (child != null)
            child!
          else
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
        ],
      ),
    );
  }

  Color _getColorForProgress(double progress) {
    if (progress < 0.3) {
      return const Color(0xFFE57373); // Red
    } else if (progress < 0.7) {
      return const Color(0xFFFFB74D); // Orange
    } else {
      return const Color(0xFF81C784); // Green
    }
  }
}

/// Custom painter for circular progress
class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw arc
    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Mastery level widget with label
class MasteryWidget extends StatelessWidget {
  final double masteryLevel; // 0.0 to 1.0
  final String label;

  const MasteryWidget({
    Key? key,
    required this.masteryLevel,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressCircle(
          progress: masteryLevel,
          size: 80,
          child: Icon(
            Icons.star,
            size: 32,
            color: _getColorForMastery(masteryLevel),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _getMasteryLabel(masteryLevel),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getColorForMastery(double mastery) {
    if (mastery < 0.3) {
      return const Color(0xFFE57373); // Red
    } else if (mastery < 0.7) {
      return const Color(0xFFFFB74D); // Orange
    } else {
      return const Color(0xFF81C784); // Green
    }
  }

  String _getMasteryLabel(double mastery) {
    if (mastery < 0.2) {
      return 'New';
    } else if (mastery < 0.5) {
      return 'Learning';
    } else if (mastery < 0.8) {
      return 'Good';
    } else {
      return 'Mastered';
    }
  }
}
