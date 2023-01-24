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

class TroublemakerActionView extends StatefulWidget {
  const TroublemakerActionView({super.key});

  @override
  State<TroublemakerActionView> createState() => _TroublemakerActionViewState();
}

class _TroublemakerActionViewState extends State<TroublemakerActionView> {
  String username = "";
  var targetUsernames = [];

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
                        "Troublemaker",
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .apply(color: HexColor.fromHex("6495ED")),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Select and Swap\nTWO players",
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                      _playerList(snapshot.data),
                    ],
                  ),
                ),
              );
            }

            return const AwaitingResult();
          },
        ));
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
      Navigator.pop(context);
      AlertOk.showAlert(context, res.body);
      return;
    }

    return jsonDecode(res.body);
  }

  _completeAction(targetUsername) async {
    setState(() {
      if (targetUsernames.contains(targetUsername)) {
        targetUsernames.remove(targetUsername);
      } else {
        targetUsernames.add(targetUsername);
      }
    });

    if (targetUsernames.length < 2) return;

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
                "targetUsername1": targetUsernames[0],
                "targetUsername2": targetUsernames[1],
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
      // AlertOk.showAlert(context, res.body);
      return;
    }

    var body = jsonDecode(res.body);

    Navigator.pushNamed(context, '/${body['route']}',
        arguments: {'username': username});
  }

  Widget _playerList(List data) {
    return SizedBox(
      height: 150,
      child: Center(
        child: GridView.builder(
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / 4),
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => _completeAction(data[index]),
              child: Card(
                color: targetUsernames.contains(data[index])
                    ? Colors.green
                    : Colors.grey,
                elevation: 5,
                child: Center(
                    child: Text(
                  data[index],
                  textAlign: TextAlign.center,
                )),
              ),
            );
          },
        ),
      ),
    );
  }
}
