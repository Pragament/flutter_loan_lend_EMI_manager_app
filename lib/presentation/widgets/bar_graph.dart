import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

class CustomBarLineChart extends StatelessWidget {
  final List<double> principalAmounts;
  final List<double> interestAmounts;
  final List<double> balances;
  final List<int> years;

  const CustomBarLineChart({
    super.key,
    required this.principalAmounts,
    required this.interestAmounts,
    required this.balances,
    required this.years,
  });

  @override
  Widget build(BuildContext context) {
    const double barWidth = 25;
    const double spacing = 25;
    final totalWidth = years.length * (barWidth + spacing) + spacing + 40;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Chart with scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: max(totalWidth, MediaQuery.of(context).size.width),
            height: 300,
            child: BarLineChart(
              principalAmounts: principalAmounts,
              interestAmounts: interestAmounts,
              balances: balances,
              years: years,
            ),
          ),
        ),

        const SizedBox(height: 8),

        /// Legends row
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: Colors.green,
              label: 'Principal',
              isCircle: true,
            ),
            SizedBox(width: 16),
            _LegendItem(
              color: Colors.orange,
              label: 'Interest',
              isCircle: true,
            ),
            SizedBox(width: 16),
            _LegendItem(
              color: Colors.redAccent,
              label: 'Balance',
              isLine: true,
            ),
          ],
        ),
      ],
    );
  }
}

class BarLineChart extends StatefulWidget {
  final List<double> principalAmounts;
  final List<double> interestAmounts;
  final List<double> balances;
  final List<int> years;

  const BarLineChart({
    super.key,
    required this.principalAmounts,
    required this.interestAmounts,
    required this.balances,
    required this.years,
  });

  @override
  State<BarLineChart> createState() => _BarLineChartState();
}

class _BarLineChartState extends State<BarLineChart> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final totalWidth = widget.years.length * 50.0; // adjust spacing/barWidth

    return GestureDetector(
      onTapDown: (details) async {
        final dx = details.localPosition.dx;
        final barIndex = (dx / 50).floor(); // adjust for bar spacing
        if (barIndex >= 0 && barIndex < widget.years.length) {
          // Add a Timer? _tooltipTimer; at the top of your State class
          Timer? _tooltipTimer;

// Inside your onTapUp:
          setState(() {
            selectedIndex = barIndex;
          });

// Start new timer to clear after x seconds
          _tooltipTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                selectedIndex = null;
              });
            }
          });
        }
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: CustomPaint(
          size: Size(totalWidth, 250),
          painter: BarLineChartPainter(
            principalAmounts: widget.principalAmounts,
            interestAmounts: widget.interestAmounts,
            balances: widget.balances,
            years: widget.years,
            selectedIndex: selectedIndex,
          ),
        ),
      ),
    );
  }
}

class BarLineChartPainter extends CustomPainter {
  final List<double> principalAmounts;
  final List<double> interestAmounts;
  final List<double> balances;
  final List<int> years;
  final int? selectedIndex;

  BarLineChartPainter({
    required this.principalAmounts,
    required this.interestAmounts,
    required this.balances,
    required this.years,
    required this.selectedIndex,
  });

  final barWidth = 20.0;
  final barSpacing = 50.0;
  final leftPadding = 40.0;
  final topPadding = 20.0;
  final bottomPadding = 30.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final maxPayment = principalAmounts.isNotEmpty
        ? principalAmounts.reduce(max) + interestAmounts.reduce(max)
        : 0;
    final maxBalance = balances.isNotEmpty ? balances.reduce(max) : 0;
    final maxValue = max(maxPayment, maxBalance) * 1.1;

    final chartHeight = size.height - topPadding - bottomPadding;

    // Draw left & right borders
    paint.color = Colors.black;
    paint.strokeWidth = 1;
    canvas.drawLine(Offset(leftPadding, topPadding),
        Offset(leftPadding, size.height - bottomPadding), paint);
    final rightBorderX =
        leftPadding + (years.length - 1) * barSpacing + barWidth + 6;
    canvas.drawLine(
      Offset(rightBorderX, topPadding),
      Offset(rightBorderX, size.height - bottomPadding),
      paint,
    );
// Draw top border (lighter)
    paint.color = Colors.grey.withOpacity(0.4); // lighter top line
    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(rightBorderX, topPadding),
      paint,
    );

// Draw bottom border
    canvas.drawLine(
      Offset(leftPadding, size.height - bottomPadding),
      Offset(rightBorderX, size.height - bottomPadding),
      paint,
    );

    // Y tiles (left: balance)
    final yTiles = 5;
    final textPainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    for (int i = 0; i <= yTiles; i++) {
      final value = maxValue * (i / yTiles);
      final y = size.height - bottomPadding - (chartHeight * (i / yTiles));
      textPainter.text = TextSpan(
          text: '${(value / 1000).round()}K',
          style: const TextStyle(fontSize: 10, color: Colors.black));
      textPainter.layout(minWidth: leftPadding - 4, maxWidth: leftPadding - 4);
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // X tiles (years)
    for (int i = 0; i < years.length; i++) {
      final x = leftPadding + i * barSpacing + barWidth / 2;
      textPainter.text = TextSpan(
          text: years[i].toString(),
          style: const TextStyle(fontSize: 10, color: Colors.black));
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x - textPainter.width / 2, size.height - bottomPadding + 4));
    }

    // Draw bars & line
    final linePath = Path();
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < years.length; i++) {
      final x = leftPadding + i * barSpacing;
      final principal = principalAmounts[i];
      final interest = interestAmounts[i];
      //final total = principal + interest;

      final principalHeight = chartHeight * (principal / maxValue);
      final interestHeight = chartHeight * (interest / maxValue);

      final barBottom = size.height - bottomPadding;

      // principal part
      paint.color = Colors.green;
      canvas.drawRect(
          Rect.fromLTWH(
              x, barBottom - principalHeight, barWidth, principalHeight),
          paint);

      // interest part
      paint.color = Colors.orange;
      canvas.drawRect(
          Rect.fromLTWH(x, barBottom - principalHeight - interestHeight,
              barWidth, interestHeight),
          paint);

      // balance dot & line
      final balance = balances[i];
      final balanceY = barBottom - (balance / maxValue) * chartHeight;
      final balanceX = x + barWidth / 2;

      if (i == 0) {
        linePath.moveTo(balanceX, balanceY);
      } else {
        linePath.lineTo(balanceX, balanceY);
      }

      paint.color = Colors.red;
      canvas.drawCircle(Offset(balanceX, balanceY), 3, paint);
    }

    // draw line
    paint.color = Colors.redAccent;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(linePath, paint);

// tooltip
    if (selectedIndex != null && selectedIndex! < years.length) {
      final x = leftPadding + selectedIndex! * barSpacing + barWidth / 2;

      final principal = principalAmounts[selectedIndex!];
      final interest = interestAmounts[selectedIndex!];
      final total = principal + interest;

      final totalY =
          size.height - bottomPadding - (total / maxValue) * chartHeight;

      final balance = balances[selectedIndex!];

      final tooltipText = 'Yr ${years[selectedIndex!]}:\n'
          'P: ${principal.round()}\n'
          'I: ${interest.round()}\n'
          'B: ${balance.round()}';

      textPainter.text = TextSpan(
          text: tooltipText,
          style: const TextStyle(fontSize: 10, color: Colors.white));
      textPainter.layout();

      final tooltipWidth = textPainter.width + 8;
      final tooltipHeight = textPainter.height + 4;

      // Position tooltip above the bar
      final tooltipRect = Rect.fromLTWH(
        x - tooltipWidth / 2,
        totalY - tooltipHeight - 8,
        tooltipWidth,
        tooltipHeight,
      );

      paint.color = Colors.black87;
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(tooltipRect, const Radius.circular(4)),
        paint,
      );
      textPainter.paint(
          canvas, Offset(tooltipRect.left + 4, tooltipRect.top + 2));
    }
    // Draw left Y-axis title ("Balance")
    textPainter.text = const TextSpan(
      text: 'Balance',
      style: TextStyle(
          fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
    );
    textPainter.layout();

// Rotate and draw vertically centered
    canvas.save();
    canvas.translate(12, size.height / 2 + textPainter.width / 2);
    canvas.rotate(-pi / 2);
    textPainter.paint(canvas, Offset(0, -textPainter.height / 2));
    canvas.restore();

// Draw right Y-axis title ("EMI Payment / Year")
    textPainter.text = const TextSpan(
      text: 'EMI Payment / Year',
      style: TextStyle(
          fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
    );
    textPainter.layout();

// Move to right of the right border
    canvas.save();
    canvas.translate(rightBorderX + textPainter.height + 4,
        size.height / 2 - textPainter.width / 2);
    canvas.rotate(pi / 2);
    textPainter.paint(canvas, Offset(0, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isCircle;
  final bool isLine;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isCircle = false,
    this.isLine = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (isLine) {
      icon = Container(
        width: 16,
        height: 2,
        color: color,
        margin: const EdgeInsets.only(right: 8),
      );
    } else if (isCircle) {
      icon = Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    } else {
      // fallback to square
      icon = Container(
        width: 12,
        height: 12,
        color: color,
        margin: const EdgeInsets.only(right: 8),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
