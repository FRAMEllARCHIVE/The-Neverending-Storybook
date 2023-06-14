import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async' show Timer;
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loading.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class BookScreen extends StatefulWidget {
  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  List<String> pastStories = [];
  List<String> availableStories = [];
  String? currentStory;

  Future<String> loadStory(String storyPath) async {
    return await rootBundle.loadString(storyPath);
  }

  Future<void> loadAvailableStories() async {
    String storyContent = await loadStory('assets/storybook.txt');
    List<String> stories = storyContent.split('---');
    availableStories = List.from(stories)..removeAt(0);
    if (pastStories.length >= 10) {
      availableStories.insert(0, stories[0]);
    }
  }

  void selectRandomStory() {
    if (availableStories.isEmpty) {
      return;
    }
    Random random = Random();
    int index = random.nextInt(availableStories.length);
    currentStory = availableStories[index]!;
    pastStories.add(currentStory!);
    availableStories.removeAt(index);
    if (pastStories.length >= 10 && availableStories.length < 2) {
      availableStories.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    loadAvailableStories().then((_) {
      setState(() {
        selectRandomStory();
      });
    });
  }

  void changeStory() {
    selectRandomStory();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();

    @override
    void dispose() {
      _scrollController.dispose(); // Dispose the ScrollController
      super.dispose();
    }

    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! < -1000) {
            // Swiped up
            _scrollController.animateTo(
              0,
              duration: const Duration(
                  milliseconds:
                      300), // Set the duration for the scroll animation
              curve: Curves.easeInOut, // Set the animation curve
            );
            changeStory();
          }
        },
        child: SingleChildScrollView(
          controller:
              _scrollController, // Provide the ScrollController to the SingleChildScrollView
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Stack(
            children: [
              Image.asset(
                'assets/book.jpg',
                fit: BoxFit.fitHeight,
                height: MediaQuery.of(context).size.height,
              ),
              Positioned(
                bottom: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).size.width) /
                    2.4,
                right: 60,
                child: Container(
                  width: 8000,
                  height: 500,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: FutureBuilder(
                        future: loadStory('assets/storybook.txt'),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error loading story'));
                            } else {
                              return Text(
                                currentStory!,
                                style: TextStyle(
                                  fontSize: 42,
                                  color: Color.fromARGB(184, 49, 34, 30),
                                  fontFamily: 'PeatBrown',
                                ),
                              );
                            }
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
