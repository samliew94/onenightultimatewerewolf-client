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

class FinalRoleView extends StatefulWidget {
  const FinalRoleView({super.key});

  @override
  State<FinalRoleView> createState() => _FinalRoleViewState();
}

class _FinalRoleViewState extends State<FinalRoleView> {
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
          child: FutureBuilder<dynamic>(
            future: _getFinalRole(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;

                var roleName = data["roleName"];
                var color = data["color"];

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Final Role",
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
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
                    ],
                  ),
                );
              }
              return const AwaitingResult();
            },
          ),
        ));
  }

  _getFinalRole() async {
    Response res;
    var uri = Uri.parse('${Config.getServerIp()}/roles/finalrole/$username');

    try {
      res = await http.get(uri).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return http.Response('Server did not respond at\n$uri', 408);
        },
      );
    } on Exception catch (e) {
      Navigator.pop(context);
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (res.statusCode != 200) {
      Navigator.pop(context);
      AlertOk.showAlert(context, res.body);
      return;
    }

    return jsonDecode(res.body);
  }
}
