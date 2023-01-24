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

class SeerCenterDoneView extends StatefulWidget {
  const SeerCenterDoneView({super.key});

  @override
  State<SeerCenterDoneView> createState() => _SeerCenterDoneViewState();
}

class _SeerCenterDoneViewState extends State<SeerCenterDoneView> {
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
                            .apply(color: Colors.blueAccent),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: [
                          _centerCard(data, 0),
                          _centerCard(data, 1),
                          _centerCard(data, 2),
                        ],
                      )
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
    var index1 = data["index1"];
    var index2 = data["index2"];
    var roleName1 = data["roleName1"];
    var roleName2 = data["roleName2"];
    var color1 = data["color1"];
    var color2 = data["color2"];

    String content = "Card ${index + 1}";

    Color color = Colors.grey;
    if (index == index1) {
      content = roleName1;
      color = HexColor.fromHex(color1);
    } else if (index == index2) {
      content = roleName2;
      color = HexColor.fromHex(color2);
    }

    if (content == "troublemaker") content = "trouble\nmaker";

    return Expanded(
      child: Card(
        color: color,
        elevation: 5,
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(content,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .apply(color: Colors.white)),
        )),
      ),
    );
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
