import 'package:flutter/material.dart';
import 'dart:async';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    required this.hundreds,
    required this.seconds,
    required this.minutes,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle =
      const TextStyle(fontSize: 70.0, fontFamily: "Bebas Neue");
  final Stopwatch stopwatch = Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class TimerPage extends StatefulWidget {
  TimerPage({Key? key}) : super(key: key);

  @override
  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  final Dependencies dependencies = Dependencies();

  void leftButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        print("${dependencies.stopwatch.elapsedMilliseconds}");
      } else {
        dependencies.stopwatch.reset();
      }
    });
  }

  void rightButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
      } else {
        dependencies.stopwatch.start();
      }
    });
  }

  Widget buildFloatingButton(String text, VoidCallback callback) {
    TextStyle roundTextStyle =
        const TextStyle(fontSize: 16.0, color: Colors.white);
    return FloatingActionButton(
      child: Text(text, style: roundTextStyle),
      onPressed: callback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stopwatch'),
       // icon: Icon(Icons.timer_sharp),
      ),
      body: ListView(
        children: <Widget>[
          TimerText(dependencies: dependencies),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildFloatingButton(
                    dependencies.stopwatch.isRunning ? "lap" : "reset",
                    leftButtonPressed),
                buildFloatingButton(
                    dependencies.stopwatch.isRunning ? "stop" : "start",
                    rightButtonPressed),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimerText extends StatefulWidget {
  TimerText({required this.dependencies});

  final Dependencies dependencies;

  @override
  TimerTextState createState() => TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({required this.dependencies});

  final Dependencies dependencies;
  late Timer timer;
  int milliseconds = 0;

  @override
  void initState() {
    timer = Timer.periodic(
      Duration(milliseconds: dependencies.timerMillisecondsRefreshRate),
      callback,
    );
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      setState(() {
        milliseconds = dependencies.stopwatch.elapsedMilliseconds;
        final int hundreds = (milliseconds / 10).truncate();
        final int seconds = (hundreds / 100).truncate();
        final int minutes = (seconds / 60).truncate();
        final ElapsedTime elapsedTime = ElapsedTime(
          hundreds: hundreds,
          seconds: seconds,
          minutes: minutes,
        );
        for (final listener in dependencies.timerListeners) {
          listener(elapsedTime);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RepaintBoundary(
          child: SizedBox(
            height: 72.0,
            child: MinutesAndSeconds(dependencies: dependencies),
          ),
        ),
        RepaintBoundary(
          child: SizedBox(
            height: 72.0,
            child: Hundreds(dependencies: dependencies),
          ),
        ),
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({required this.dependencies});

  final Dependencies dependencies;

  @override
  MinutesAndSecondsState createState() =>
      MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({required this.dependencies});

  final Dependencies dependencies;
  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes || elapsed.seconds != seconds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return Text('$minutesStr:$secondsStr.', style: dependencies.textStyle);
  }
}

class Hundreds extends StatefulWidget {
  Hundreds({required this.dependencies});

  final Dependencies dependencies;

  @override
  HundredsState createState() => HundredsState(dependencies: dependencies);
}

class HundredsState extends State<Hundreds> {
  HundredsState({required this.dependencies});

  final Dependencies dependencies;
  int hundreds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.hundreds != hundreds) {
      setState(() {
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return Text(hundredsStr, style: dependencies.textStyle);
  }
}
