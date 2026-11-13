import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/mileage_reading.dart';

class MileageChart extends StatelessWidget {
  const MileageChart({super.key, required this.readings});

  final List<MileageReading> readings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<MileageReading>.from(readings)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sorted.length < 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.show_chart,
                size: 32,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'Se necesitan al menos 2 lecturas para graficar',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Evolución del kilometraje',
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: CustomPaint(
                painter: _MileageChartPainter(
                  readings: sorted,
                  lineColor: theme.colorScheme.primary,
                  gridColor: theme.colorScheme.outlineVariant,
                  surfaceColor: theme.colorScheme.surfaceContainer,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MileageChartPainter extends CustomPainter {
  _MileageChartPainter({
    required this.readings,
    required this.lineColor,
    required this.gridColor,
    required this.surfaceColor,
  });

  final List<MileageReading> readings;
  final Color lineColor;
  final Color gridColor;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.length < 2) return;

    final minMileage = readings
        .map((reading) => reading.mileage)
        .reduce(math.min)
        .toDouble();
    final maxMileage = readings
        .map((reading) => reading.mileage)
        .reduce(math.max)
        .toDouble();
    final range = (maxMileage - minMileage).abs() < 1
        ? 1.0
        : maxMileage - minMileage;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < readings.length; i++) {
      final x = readings.length == 1
          ? 0.0
          : size.width * i / (readings.length - 1);
      final normalized = (readings[i].mileage - minMileage) / range;
      final y = size.height - normalized * (size.height - 12) - 6;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = lineColor.withValues(alpha: 0.10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    final dotPaint = Paint()..color = lineColor;
    final surfacePaint = Paint()..color = surfaceColor;
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 2, surfacePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MileageChartPainter oldDelegate) {
    return oldDelegate.readings != readings ||
        oldDelegate.lineColor != lineColor;
  }
}
