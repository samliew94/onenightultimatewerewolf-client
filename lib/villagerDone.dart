import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:onuwweb/extensions.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'custombackbutton.dart';
import 'endgamebutton.dart';

class VillagerDoneView extends StatefulWidget {
  const VillagerDoneView({super.key});

  @override
  State<VillagerDoneView> createState() => _VillagerDoneViewState();
}

class _VillagerDoneViewState extends State<VillagerDoneView> {
  String username = "";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    username = args["username"];

    return Scaffold(
        floatingActionButton: EndGameButton(username),
        appBar: AppBar(
          title: const Text(""),
          leading: const CustomBackButton(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  username,
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Villager",
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .apply(color: HexColor.fromHex("6495ED")),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ));
  }
}
