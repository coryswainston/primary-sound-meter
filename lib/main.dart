import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:soundmeter/meter.dart';
import 'package:soundmeter/songs.dart';

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
  double currentLoudness = 0.0;

  Song? currentSong;
  int index = 0;
  double position = 0;
  bool complete = false;

  Timer? timer;

  final songs = [nephisCourage1, nephisCourage2];

  @override
  void initState() {
    setupMicrophone();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showHelpDialog();
    });

    Timer.periodic(const Duration(milliseconds: 250), (timer) {
      updateX(context);
    });

    super.initState();
  }

  void setupMicrophone() async {
    if (await record.hasPermission()) {
      stream = await record.startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits));
      stream!.listen((event) {
        setState(() {
          currentDecibels = calculateDecibels(event);
          currentLoudness = calculateLoudness(event);
        });
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

    return Focus(
      autofocus: true,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space) {
            if (currentSong != null) {
              if (index < currentSong!.lines.length - 1) {
                setState(() {
                  index++;
                });
              } else if (songs.indexOf(currentSong!) < songs.length - 1) {
                setState(() {
                  currentSong = songs[songs.indexOf(currentSong!) + 1];
                  complete = false;
                  index = 0;
                  position = 0.0;
                });
              } else {
                setState(() {
                  currentSong = null;
                  complete = false;
                });
              }
            }

            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: currentSong == null ? null : Text(currentSong!.title),
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
          actions: [
            IconButton(
              onPressed: () {
                showHelpDialog();
              },
              icon: const Icon(Icons.help_outline),
            ),
          ],
        ),
        drawer: Drawer(
          width: 400,
          child: ListView(
            children: [
              const SizedBox(
                height: 200,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF304060),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Sound Meter',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        '“For my soul delighteth in the song of the heart;\n'
                        'yea, the song of the righteous is a prayer unto me,\n'
                        'and it shall be answered with a blessing upon their heads."\n\n'
                        '- Doctrine & Covenants 25:12',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Text('No song'),
                onTap: () {
                  setState(() {
                    currentSong = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
              for (var song in songs)
                ListTile(
                  title: Text(song.title),
                  onTap: () {
                    setState(() {
                      currentSong = song;
                      index = 0;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              const Divider(),
              ListTile(
                title: const Text('Help'),
                onTap: () {
                  showHelpDialog();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
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

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: currentSong != null
                            ? AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Padding(
                                  key: ValueKey(index),
                                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/${currentSong!.pictures[index]}',
                                        height: 250,
                                      ),
                                      const SizedBox(width: 24),
                                      Text(
                                        currentSong!.lines[index],
                                        style: const TextStyle(fontSize: 36),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ),
                      Positioned.fill(
                        child: Stack(
                          children: [
                            Center(child: SemiCircleMeter(value: calculateLoudness(snapshot.data!))),
                            Center(
                              child: Text(
                                getLoudnessText(calculateLoudness(snapshot.data!)),
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentSong == null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Column(
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
                          ),
                        ),
                      if (currentSong != null)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 500),
                          left: position,
                          bottom: 0,
                          child: Image.asset(
                            'assets/${currentSong!.pictures[0]}',
                            height: 200,
                          ),
                        ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: complete ? 1 : 0,
                            duration: const Duration(milliseconds: 500),
                            child: Image.asset(
                              'assets/confetti.gif',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  void updateX(BuildContext context) {
    if (currentSong == null) return;

    final end = MediaQuery.of(context).size.width - 200;
    final amountForQuarterSecond = end / 160;
    final multiplier = currentLoudness * 1.5;
    final amount = amountForQuarterSecond * multiplier;
    setState(() {
      position = position + amount;
      if (position >= end) {
        position = end;
        complete = true;
      }
    });
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
    timer?.cancel();
    super.dispose();
  }
}
