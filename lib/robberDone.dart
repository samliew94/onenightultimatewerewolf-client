import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:onuwweb/awaitingresult.dart';
import 'package:onuwweb/extensions.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'custombackbutton.dart';
import 'endgamebutton.dart';

class RobberDoneView extends StatefulWidget {
  const RobberDoneView({super.key});

  @override
  State<RobberDoneView> createState() => _RobberDoneViewState();
}

class _RobberDoneViewState extends State<RobberDoneView> {
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

              var targetUsername = data["targetUsername"];
              var roleName = data["roleName"];
              var color = data["color"];

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
                        roleName,
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .apply(color: HexColor.fromHex(color)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Text(
                        "*You swapped with\n$targetUsername",
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.center,
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

  Widget _centerCard(data, index) {
    var targetIndex = data["targetIndex"];
    var targetRoleName = data["targetRoleName"];
    var targetColor = data["targetColor"];

    Color color = Colors.grey;
    String content = "Card ${index + 1}";

    if (targetIndex == index) {
      content = targetRoleName;
      color = HexColor.fromHex(targetColor);
    }

    return Expanded(
      child: Card(
        color: color,
        elevation: 5,
        child: Center(
            child: Text(content,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .apply(color: Colors.white))),
      ),
    );
  }

  _viewAction() async {
    print("robber done _viewAction");
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
