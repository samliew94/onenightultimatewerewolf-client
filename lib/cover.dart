import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'extensions.dart';

class CoverView extends StatefulWidget {
  const CoverView({super.key});

  @override
  State<CoverView> createState() => _CoverViewState();
}

class _CoverViewState extends State<CoverView> {
  String playerName = "";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    playerName = args["username"];

    return Scaffold(
        appBar: AppBar(
          title: const Text("See Hidden Role"),
          // backgroundColor: Colors.green,
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        body: Card(
          clipBehavior: Clip.hardEdge,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(12),
          elevation: 5,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/role',
                arguments: {'username': playerName}),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [
                    HexColor.fromHex("#b80000"),
                    HexColor.fromHex("#00495c"),
                  ])),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Tap to See',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .apply(color: Colors.white),
                      ),
                      const Icon(
                        FontAwesomeIcons.userSecret,
                        color: Colors.white,
                        size: 128,
                      ),
                      Text(
                        'Secret Role',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .apply(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Colors.red, Colors.blue],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 300, 70.0));
}
