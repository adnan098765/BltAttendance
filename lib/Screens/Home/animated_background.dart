import 'dart:math';
import 'package:attendance/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class EnhancedBackground extends StatelessWidget {
  final Widget child;

  const EnhancedBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated background
        Positioned.fill(
          child: AnimatedBackground(),
        ),

        // Floating elements
        Positioned.fill(
          child: FloatingElements(),
        ),

        // Content
        SafeArea(child: child),
      ],
    );
  }
}

// Animated Background with waves and gradients
// These would be changed tomorrow
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..scene(
        begin: const Duration(milliseconds: 0),
        duration: const Duration(milliseconds: 10000),
      )
          .tween(
        'color1',
        ColorTween(
          begin: AppColors.appColor,
          end: AppColors.appColor
        ),
      )
          .tween(
        'color2',
        ColorTween(
          begin:AppColors.appColor,
          end:  AppColors.appColor
        ),
      );

    return CustomAnimationBuilder<Movie>(
      tween: tween,
      duration: tween.duration,
      control: Control.loop,
      builder: (context, value, child) {
        return CustomPaint(
          painter: BackgroundPainter(
            colorTop: value.get('color1'),
            colorBottom: value.get('color2'),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Color colorTop;
  final Color colorBottom;

  BackgroundPainter({
    required this.colorTop,
    required this.colorBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a gradient background
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorTop,
        colorBottom,
      ],
      stops: const [0.0, 1.0],
    );

    final Paint gradientPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, gradientPaint);

    // Draw animated wave shapes
    _drawWaves(canvas, size);

    // Draw decorative patterns
    _drawDecorationElements(canvas, size);
  }

  void _drawWaves(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000;

    final Paint wavePaint1 = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final Paint wavePaint2 = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // First wave
    final Path wavePath1 = Path();
    wavePath1.moveTo(0, size.height * 0.75);

    for (double x = 0; x <= size.width; x++) {
      double y = size.height * (0.75 + 0.04 * sin((x / size.width * 4 * pi) + time));
      wavePath1.lineTo(x, y);
    }

    wavePath1.lineTo(size.width, size.height);
    wavePath1.lineTo(0, size.height);
    wavePath1.close();

    canvas.drawPath(wavePath1, wavePaint1);

    // Second wave (offset)
    final Path wavePath2 = Path();
    wavePath2.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x++) {
      double y = size.height * (0.8 + 0.05 * sin((x / size.width * 3 * pi) + time * 1.2));
      wavePath2.lineTo(x, y);
    }

    wavePath2.lineTo(size.width, size.height);
    wavePath2.lineTo(0, size.height);
    wavePath2.close();

    canvas.drawPath(wavePath2, wavePaint2);
  }

  void _drawDecorationElements(Canvas canvas, Size size) {
    // Draw some decorative circles
    final Paint circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Top left decorative circle
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.1),
      size.width * 0.15,
      circlePaint,
    );

    // Bottom right decorative circle
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.78),
      size.width * 0.2,
      circlePaint,
    );

    // Create a few smaller circles for added depth
    final Paint smallCirclePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.2),
      size.width * 0.08,
      smallCirclePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.5),
      size.width * 0.12,
      smallCirclePaint,
    );
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return oldDelegate.colorTop != colorTop || oldDelegate.colorBottom != colorBottom;
  }
}

// Floating elements with animations
class FloatingElements extends StatefulWidget {
  @override
  _FloatingElementsState createState() => _FloatingElementsState();
}

class _FloatingElementsState extends State<FloatingElements> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // List to store animated elements
  final List<AnimatedElement> _elements = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();

    // Create animated elements
    _createElements();
  }

  void _createElements() {
    final random = Random();

    // Create 10 random floating elements
    for (int i = 0; i < 10; i++) {
      _elements.add(
        AnimatedElement(
          size: 10.0 + random.nextDouble() * 30.0,
          xOffset: random.nextDouble(),
          yOffset: random.nextDouble(),
          shape: random.nextBool() ? ElementShape.circle : ElementShape.rectangle,
          animationOffset: random.nextDouble() * 2 * pi,
          animationSpeed: 0.5 + random.nextDouble() * 1.5,
          color: Colors.white.withOpacity(0.05 + random.nextDouble() * 0.1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ElementsPainter(
            elements: _elements,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

enum ElementShape { circle, rectangle }

class AnimatedElement {
  final double size;
  final double xOffset;
  final double yOffset;
  final ElementShape shape;
  final double animationOffset;
  final double animationSpeed;
  final Color color;

  AnimatedElement({
    required this.size,
    required this.xOffset,
    required this.yOffset,
    required this.shape,
    required this.animationOffset,
    required this.animationSpeed,
    required this.color,
  });
}

class ElementsPainter extends CustomPainter {
  final List<AnimatedElement> elements;
  final double animationValue;

  ElementsPainter({
    required this.elements,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in elements) {
      // Calculate position with slight movement
      final x = size.width * element.xOffset +
          sin((animationValue * 2 * pi * element.animationSpeed) + element.animationOffset) * 30.0;

      final y = size.height * element.yOffset +
          cos((animationValue * 2 * pi * element.animationSpeed) + element.animationOffset) * 30.0;

      final paint = Paint()
        ..color = element.color
        ..style = PaintingStyle.fill;

      if (element.shape == ElementShape.circle) {
        canvas.drawCircle(Offset(x, y), element.size, paint);
      } else {
        // Draw a rounded rectangle
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: element.size * 1.5, height: element.size * 1.5),
            Radius.circular(element.size / 4),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ElementsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}