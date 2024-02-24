import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Primary Sound Meter',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const App(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Stream<Uint8List>? stream;
  AudioRecorder record = AudioRecorder();

  double minDecibels = -72.0;
  double maxDecibels = -10.0;
  double currentDecibels = -90.0;

  @override
  void initState() {
    setupMicrophone();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showHelpDialog();
    });

    super.initState();
  }

  void setupMicrophone() async {
    if (await record.hasPermission()) {
      stream = await record.startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits));
      stream!.listen((event) {
        setState(() => currentDecibels = calculateDecibels(event));
      });
      setState(() {});
    }
  }

  double calculateDecibels(Uint8List event) {
    var samples = Int16List.view(event.buffer);

    // Calculate RMS
    double sumOfSquares = 0.0;
    for (var sample in samples) {
      sumOfSquares += math.pow(sample, 2).toDouble();
    }
    double rms = math.sqrt(sumOfSquares / samples.length);
    rms = math.max(rms, 1.0);

    double db = 20 * math.log(rms / 32768.0) / math.ln10;
    db = math.max(db, -80.0);

    return db;
  }

  double calculateLoudness(Uint8List event) {
    final db = calculateDecibels(event);

    double clampedDbfs = db.clamp(minDecibels, maxDecibels);

    double normalized = (clampedDbfs - minDecibels) / (maxDecibels - minDecibels);

    double loudness = math.pow(normalized, 16).toDouble();

    return loudness;
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 700) {
      return const Scaffold(
        backgroundColor: Color(0xFF304060),
        body: Center(
          child: Text('This app is not designed for mobile devices.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF304060),
      body: stream == null
          ? const Center(
              child: Text('Accessing mic...'),
            )
          : StreamBuilder(
              stream: stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No data'),
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Primary Sound Meter',
                                style: TextStyle(fontSize: 22),
                              ),
                              SizedBox(height: 24.0),
                              Text(
                                '“For my soul delighteth in the song of the heart;\n'
                                'yea, the song of the righteous is a prayer unto me,\n'
                                'and it shall be answered with a blessing upon their heads."\n\n'
                                '- Doctrine & Covenants 25:12',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      height: MediaQuery.of(context).size.height * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(80.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: MediaQuery.of(context).size.height * 0.9 * calculateLoudness(snapshot.data!),
                              decoration: BoxDecoration(
                                color: getColor(calculateLoudness(snapshot.data!)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 100,
                            child: Center(
                              child: Text(
                                getLoudnessText(calculateLoudness(snapshot.data!)),
                                style: const TextStyle(fontSize: 56),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showHelpDialog();
                                  },
                                  icon: const Icon(Icons.help_outline),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton.icon(
                                      label: const Text('Set silent'),
                                      onPressed: () {
                                        setState(() => minDecibels = currentDecibels);
                                      },
                                      icon: const Icon(Icons.volume_mute_outlined),
                                    ),
                                    TextButton.icon(
                                      label: const Text('Set loud'),
                                      onPressed: () {
                                        setState(() => maxDecibels = currentDecibels);
                                      },
                                      icon: const Icon(Icons.volume_up_outlined),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Color getColor(double loudness) {
    if (loudness < 0.2) {
      return Colors.lightBlue;
    } else if (loudness < 0.5) {
      return Colors.green;
    } else if (loudness < 0.9) {
      return const Color(0xFFFFA570);
    } else {
      return Colors.red;
    }
  }

  String getLoudnessText(double loudness) {
    if (loudness < 0.02) {
      return 'Silent';
    } else if (loudness < 0.1) {
      return 'Very soft';
    } else if (loudness < 0.35) {
      return 'Soft';
    } else if (loudness < 0.55) {
      return 'Medium';
    } else if (loudness < 0.7) {
      return 'Medium Loud';
    } else if (loudness < 0.85) {
      return 'Loud';
    } else {
      return 'Very loud!';
    }
  }

  showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Welcome!'),
          content: const Text(
            'I made this sound meter to help kids see how loud and soft they\'re singing in primary.\n'
            'It is still in progress! Check back for more updates.\n\n'
            'To get started:\n\n'
            '   \u2022  Have the class be as quiet as possible, and press the "Set silent" button.\n'
            '   \u2022  Have the class sing as loud as possible and press the "Set loud" button.\n\n'
            'This will help the sound meter know how to measure the loudness of the class.\n\n'
            'Have fun!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    record.dispose();
    super.dispose();
  }
}
