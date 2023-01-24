import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:onuwweb/awaitingresult.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'extensions.dart';

class LobbyView extends StatefulWidget {
  const LobbyView({super.key});

  static const routeName = '/lobby';

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  String username = "";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    username = args["username"];

    return Scaffold(
        appBar: AppBar(
          title: const Text("Lobby"),
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                  heroTag: "btnRefresh",
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Icon(Icons.refresh)),
              FloatingActionButton(
                  heroTag: "btnSettings",
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  child: const Icon(Icons.settings)),
              FloatingActionButton(
                  heroTag: "btnStart",
                  onPressed: () => _startGame(),
                  child: const Icon(Icons.play_arrow))
            ],
          ),
        ),
        body: FutureBuilder(
            future: _futurePlayersAll(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List players = snapshot.data as List;

                var listView = Expanded(
                  child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: ((context, index) {
                        String u = players[index]["username"];
                        bool isSelf = username == u;

                        return Card(
                          child: ListTile(
                            title: Text(
                                "${index + 1}. ${players[index]["username"].toString().capitalize()}",
                                style: Theme.of(context).textTheme.headline5),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: "Remove",
                                  child: IconButton(
                                    splashRadius: 1,
                                    icon: Icon(FontAwesomeIcons.circleMinus,
                                        color:
                                            isSelf ? Colors.grey : Colors.red),
                                    onPressed:
                                        isSelf ? null : () => _delPlayer(u),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      })),
                );

                return Column(
                  children: [listView],
                );
              }

              return const AwaitingResult();
            }));
  }

  _futurePlayersAll() async {
    Response res;
    var uri = Uri.parse('${Config.getServerIp()}/players/all');

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
      AlertOk.showAlert(context, res.body);
      return;
    }

    return jsonDecode(res.body);
  }

  void _delPlayer(targetUsername) async {
    Response response;
    var uri = '${Config.getServerIp()}/players/del';

    try {
      response = await http
          .delete(Uri.parse(uri),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                "username": username,
                "targetUsername": targetUsername,
              }))
          .timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return http.Response('Server did not respond at\n$uri', 408);
        },
      );
    } catch (e) {
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (response.statusCode != 200) {
      AlertOk.showAlert(context, response.body);
      return;
    }

    setState(() {});
  }

  void _startGame() async {
    Response res;
    var uri = Uri.parse('${Config.getServerIp()}/game/start');

    try {
      res = await http
          .post(uri,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({"username": username}))
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

    var route = jsonDecode(res.body)["route"];

    Navigator.pushNamed(context, '/$route', arguments: {'username': username});
  }
}
