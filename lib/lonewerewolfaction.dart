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

class LoneWerewolfActionView extends StatefulWidget {
  const LoneWerewolfActionView({super.key});

  @override
  State<LoneWerewolfActionView> createState() => _LoneWerewolfActionViewState();
}

class _LoneWerewolfActionViewState extends State<LoneWerewolfActionView> {
  String username = "";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    username = args["username"];

    return Scaffold(
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
                  "Lone Werewolf",
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .apply(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Tap to see ONE card from center:",
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _centerCard(0),
                      _centerCard(1),
                      _centerCard(2),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _centerCard(index) {
    return Expanded(
      child: InkWell(
        onTap: () => _completeAction(index),
        child: Card(
          color: Colors.red,
          elevation: 5,
          child: Center(
              child: Text("Card ${index + 1}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .apply(color: Colors.white))),
        ),
      ),
    );
  }

  _completeAction(index) async {
    Response res;
    var uri = Uri.parse('${Config.getServerIp()}/actionhistory/completeaction');

    try {
      res = await http
          .post(uri,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({"username": username, "targetIndex": index}))
          .timeout(
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

    var body = jsonDecode(res.body);

    Navigator.pushNamed(context, '/${body['route']}',
        arguments: {'username': username});
  }
}
