import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class GridPainter extends CustomPainter {
  final int squaresAcross;
  Paint gridPaint;
  GridPainter({this.squaresAcross, Color gridColor, double strokeWidth = 1.0}) {
    gridPaint = Paint();
    gridPaint.color = gridColor;
    gridPaint.strokeWidth = strokeWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Figure out the square width
    var squareWidth = size.width / squaresAcross;

    // Figure out how many squares fit vertically at that size
    var squaresDown = size.height / squareWidth;

    // Horizontal lines
    for (int i = 0; i < squaresAcross + 1; i++) {
      canvas.drawLine(
        Offset(i * squareWidth, 0.0),
        Offset(i * squareWidth, size.height),
        gridPaint,
      );
    }

    // Vertical lines
    for (int j = 0; j < squaresDown + 1; j++) {
      canvas.drawLine(
        Offset(0.0, j * squareWidth),
        Offset(size.width, j * squareWidth),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(GridPainter oldDelegate) => false;
}
