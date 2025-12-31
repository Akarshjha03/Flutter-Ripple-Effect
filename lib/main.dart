import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PhotoRippleApp());
}

class PhotoRippleApp extends StatelessWidget {
  const PhotoRippleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Ripple',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            fontFamily: 'Inter', // Or system default
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            color: Colors.white,
          ),
        ),
      ),
      home: const RippleScreen(),
    );
  }
}

class RippleScreen extends StatefulWidget {
  const RippleScreen({super.key});

  @override
  State<RippleScreen> createState() => _RippleScreenState();
}

class RippleModel {
  final Offset position;
  final double startTime;
  final double power;

  RippleModel(this.position, this.startTime, this.power);
}

class _RippleScreenState extends State<RippleScreen>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  ui.Image? _image;
  late Ticker _ticker;
  double _elapsedTime = 0.0;
  final List<RippleModel> _ripples = [];

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      setState(() {
        _elapsedTime = elapsed.inMilliseconds / 1000.0;
        // Clean up old ripples (older than 3 seconds)
        _ripples.removeWhere((r) => (_elapsedTime - r.startTime) > 3.0);
      });
    });
    _ticker.start();
  }

  Future<void> _loadAssets() async {
    // Load Shader
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/ripple.frag');
      
      // Load Image
      final imageData = await rootBundle.load('assets/image.png');
      final imageCodec = await ui.instantiateImageCodec(
        imageData.buffer.asUint8List(),
      );
      final frameInfo = await imageCodec.getNextFrame();
      
      setState(() {
        _program = program;
        _image = frameInfo.image;
      });
    } catch (e) {
      debugPrint('Error loading assets: $e');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _addRipple(Offset normalizedPos) {
    if (_ripples.length >= 5) {
      _ripples.removeAt(0); // Remove oldest
    }
    _ripples.add(RippleModel(
      normalizedPos,
      _elapsedTime,
      1.0, // Default power
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Photo\nRipple',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: _program == null || _image == null
                      ? const CircularProgressIndicator(color: Colors.white24)
                      : AspectRatio(
                          aspectRatio: _image!.width / _image!.height,
                          child: Listener(
                            onPointerDown: (event) {
                              // We use a LayoutBuilder logic via the CustomPaint size,
                              // but here we need to map local coordinates to 0-1.
                              // Listener > GestureDetector for instant feedback on 'down'
                            },
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return GestureDetector(
                                  onTapDown: (details) {
                                    final renderBox = context.findRenderObject() as RenderBox;
                                    final localPos = renderBox.globalToLocal(details.globalPosition);
                                    final width = constraints.maxWidth;
                                    final height = constraints.maxHeight;
                                    
                                    // Normalize to 0-1
                                    final nx = localPos.dx / width;
                                    final ny = localPos.dy / height;
                                    
                                    _addRipple(Offset(nx, ny));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: CustomPaint(
                                      painter: RipplePainter(
                                        program: _program!,
                                        image: _image!,
                                        ripples: _ripples,
                                        time: _elapsedTime,
                                      ),
                                      size: Size(constraints.maxWidth, constraints.maxHeight),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ui.Image image;
  final List<RippleModel> ripples;
  final double time;

  RipplePainter({
    required this.program,
    required this.image,
    required this.ripples,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();

    // Uniform index tracking
    int uIndex = 0;

    // uResolution (vec2)
    shader.setFloat(uIndex++, size.width);
    shader.setFloat(uIndex++, size.height);

    // uTime (float)
    shader.setFloat(uIndex++, time);

    // uRipples (vec4[5])
    // Each ripple: x, y, startTime, power
    for (int i = 0; i < 5; i++) {
        if (i < ripples.length) {
            final r = ripples[i];
            shader.setFloat(uIndex++, r.position.dx);
            shader.setFloat(uIndex++, r.position.dy);
            shader.setFloat(uIndex++, r.startTime);
            shader.setFloat(uIndex++, r.power);
        } else {
            // Empty slot
            shader.setFloat(uIndex++, 0.0);
            shader.setFloat(uIndex++, 0.0);
            shader.setFloat(uIndex++, 0.0);
            shader.setFloat(uIndex++, 0.0);
        }
    }

    // uImage (sampler)
    shader.setImageSampler(0, image);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return oldDelegate.time != time || 
           oldDelegate.ripples != ripples ||
           oldDelegate.image != image;
  }
}
