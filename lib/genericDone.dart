import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:onuwweb/awaitingresult.dart';
import 'package:onuwweb/extensions.dart';
import 'package:onuwweb/tempwidget.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'custombackbutton.dart';
import 'endgamebutton.dart';

class GenericDoneView extends StatefulWidget {
  const GenericDoneView({super.key});

  @override
  State<GenericDoneView> createState() => _GenericDoneViewState();
}

class _GenericDoneViewState extends State<GenericDoneView> {
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
              var datas = snapshot.data as List;

              var widgets = <Widget>[];
              for (var data in datas) {
                widgets.add(TempWidget(data: data));
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        username.capitalize(),
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      ...widgets
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
