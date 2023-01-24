import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:onuwweb/awaitingresult.dart';
import 'package:onuwweb/custombackbutton.dart';
import 'package:onuwweb/extensions.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'endgamebutton.dart';

class SeerPlayerDoneView extends StatefulWidget {
  const SeerPlayerDoneView({super.key});

  @override
  State<SeerPlayerDoneView> createState() => _SeerPlayerDoneViewState();
}

class _SeerPlayerDoneViewState extends State<SeerPlayerDoneView> {
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
        body: FutureBuilder<dynamic>(
          future: _viewAction(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;

              String targetUsername = data["targetUsername"];
              String targetRoleName = data["targetRoleName"];
              String targetColor = data["targetColor"];

              return Padding(
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
                        "Seer",
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .apply(color: HexColor.fromHex("6495ED")),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Text("$targetUsername is",
                          style: Theme.of(context).textTheme.headline4),
                      Text(
                        targetRoleName,
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .apply(color: HexColor.fromHex(targetColor)),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const AwaitingResult();
          },
        ));
  }

  _viewAction() async {
    Response res;
    var uri =
        Uri.parse('${Config.getServerIp()}/actionhistory/viewaction/$username');

    try {
      res = await http.get(uri).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return http.Response('Server did not respond at\n$uri', 408);
        },
      );
    } on Exception catch (e) {
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (res.statusCode != 200) {
      // AlertOk.showAlert(context, res.body);
      return;
    }

    return jsonDecode(res.body);
  }
}
