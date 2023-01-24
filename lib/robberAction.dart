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

class RobberActionView extends StatefulWidget {
  const RobberActionView({super.key});

  @override
  State<RobberActionView> createState() => _RobberActionViewState();
}

class _RobberActionViewState extends State<RobberActionView> {
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
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        username,
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Robber",
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .apply(color: HexColor.fromHex("6495ED")),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Rob a Player",
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
    print("robberAction _getAllExceptRequestor");
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

  _completeAction(targetUsername) async {
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
      AlertOk.showAlert(context, res.body);
      return;
    }

    var body = jsonDecode(res.body);

    Navigator.pushNamed(context, '/${body['route']}',
        arguments: {'username': username});
  }

  Widget _playerList(data) {
    return SizedBox(
      height: 150,
      child: Center(
        child: GridView.builder(
          itemCount: data.length,
          // itemCount: 9,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / 4),
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => _completeAction(data[index]),
              child: Card(
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
