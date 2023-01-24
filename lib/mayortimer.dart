import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MayorTimerView extends StatefulWidget {
  final int secRemaining;
  const MayorTimerView({super.key, required this.secRemaining});

  @override
  State<MayorTimerView> createState() => _MayorTimerViewState();
}

class _MayorTimerViewState extends State<MayorTimerView> {
  int secRemaining = -1;

  @override
  void initState() {
    super.initState();
    secRemaining = widget.secRemaining;
    // secRemaining = 5; // test
    beginCountdown();
  }

  @override
  Widget build(BuildContext context) {
    // if (secRemaining == -1) {
    //   initTimer();
    // }

    // if (!timerStarted) {
    //   setState(() {
    //     timerStarted = true;
    //     beginCountdown();
    //   });
    // }

    return Column(
      children: [
        Text(
          textAlign: TextAlign.center,
          "Time Remaining To Guess: ",
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(minToStr(), style: Theme.of(context).textTheme.headline1),
      ],
    );
  }

  String minToStr() {
    int sec = secRemaining % 60;
    int min = (secRemaining / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  void beginCountdown() async {
    while (secRemaining > 0) {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        secRemaining -= 1;
      });
    }
  }
}
