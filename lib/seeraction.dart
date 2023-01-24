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

class SeerActionView extends StatefulWidget {
  const SeerActionView({super.key});

  @override
  State<SeerActionView> createState() => _SeerActionViewState();
}

class _SeerActionViewState extends State<SeerActionView> {
  String username = "";
  var targetIndexes = [];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    username = args["username"];

    return Scaffold(
        appBar: AppBar(
          title: const Text(""),
          leading: const CustomBackButton(),
        ),
        body: FutureBuilder<dynamic>(
          future: _getAllExceptRequestor(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var d = snapshot.data;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
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
                      Text(
                        "View a Player's Card",
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                      _playerList(snapshot.data),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "or",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        "View TWO cards from Center:",
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
              );
            }

            return const AwaitingResult();
          },
        ));
  }

  Widget _centerCard(index) {
    Color color = Colors.blueAccent;
    if (targetIndexes.contains(index)) {
      color = Colors.green;
    }

    return Expanded(
      child: InkWell(
        onTap: () => _seerSelectCenterCards(index),
        child: Card(
          color: color,
          elevation: 5,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Card ${index + 1}",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .apply(color: Colors.white)),
          )),
        ),
      ),
    );
  }

  _getAllExceptRequestor() async {
    Response res;
    var uri = Uri.parse(
        '${Config.getServerIp()}/players/allexceptrequestor/$username');

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

  _seerSelectCenterCards(index) async {
    setState(() {
      if (targetIndexes.contains(index)) {
        targetIndexes.remove(index);
      } else {
        targetIndexes.add(index);
      }
    });

    if (targetIndexes.length < 2) return;

    targetIndexes.sort();

    Response res;
    var uri = Uri.parse('${Config.getServerIp()}/actionhistory/completeaction');

    try {
      res = await http
          .post(uri,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                "username": username,
                "targetIndex1": targetIndexes[0],
                "targetIndex2": targetIndexes[1],
              }))
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
      AlertOk.showAlert(context, res.body);
      return;
    }

    var body = jsonDecode(res.body);

    Navigator.pushNamed(context, '/${body['route']}',
        arguments: {'username': username});
  }

  _seerSelectPlayer(targetUsername) async {
    Response res;
    var uri = Uri.parse('${Config.getServerIp()}/actionhistory/completeaction');

    try {
      res = await http
          .post(uri,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(
                  {"username": username, "targetUsername": targetUsername}))
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

  Widget _playerList(data) {
    return Expanded(
      child: GridView.builder(
        itemCount: data.length,
        // itemCount: 9,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 5),
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _seerSelectPlayer(data[index]),
            child: Card(
              elevation: 5,
              child: Center(
                  child: Text(
                data[index],
                // index.toString(),
                // "Michael Jackson",
                textAlign: TextAlign.center,
              )),
            ),
          );
        },
      ),
    );
  }
}
