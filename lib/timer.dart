import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onuwweb/endgamebutton.dart';

class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  int defSeconds = 600; // 10 minutes
  int secRemaining = 600; // 10 minutes
  bool isPlay = false;
  bool isPause = true;
  String username = "";

  @override
  void initState() {
    _beginCountdown();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    username = args["username"];

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: EndGameButton(
        username,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(minToStr(), style: Theme.of(context).textTheme.headline1),
            _createAddMinus(),
            _createPlayButton(),
            _createPauseResumeButton(),
            _createResetButton(),
          ],
        ),
      ),
    );
  }

  _createResetButton() {
    return isPlay
        ? _createButton(FontAwesomeIcons.arrowsRotate, "Reset", Colors.blue,
            () {
            setState(() {
              isPlay = false;
              secRemaining = defSeconds;
            });
          })
        : const SizedBox();
  }

  _createAddMinus() {
    if (isPlay) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () => _addTimer(-60),
            icon: const Icon(
              FontAwesomeIcons.circleMinus,
              color: Colors.red,
            )),
        IconButton(
            onPressed: () => _addTimer(60),
            icon: const Icon(
              FontAwesomeIcons.circlePlus,
              color: Colors.green,
            )),
      ],
    );
  }

  _createPlayButton() {
    return isPlay
        ? const SizedBox()
        : _createButton(FontAwesomeIcons.play, "Start", Colors.green, () {
            setState(() {
              isPlay = true;
              isPause = false;
            });
          });
  }

  _createPauseResumeButton() {
    if (!isPlay) return const SizedBox();

    if (isPause) {
      return _createButton(FontAwesomeIcons.play, "Resume", Colors.redAccent,
          () => setState(() => isPause = false));
    } else {
      return _createButton(FontAwesomeIcons.pause, "Pause", Colors.redAccent,
          () => setState(() => isPause = true));
    }
  }

  Widget _createButton(icon, msg, bgColor, onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          ),
          onPressed: () => onPressed.call(),
          icon: Icon(icon, size: 32),
          label: Text(
            msg,
            style: Theme.of(context).textTheme.headline5,
          )),
    );
  }

  String minToStr() {
    int sec = secRemaining % 60;
    int min = (secRemaining / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  void _beginCountdown() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      if (!isPlay || isPause) continue;
      setState(() {
        secRemaining -= 1;
      });
    }
  }

  _addTimer(int i) {
    setState(() {
      secRemaining += i;
    });
  }
}
