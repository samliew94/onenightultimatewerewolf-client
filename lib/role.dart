import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'extensions.dart';
import 'rpgicon.dart';

class RoleView extends StatefulWidget {
  const RoleView({super.key});

  @override
  State<RoleView> createState() => _RoleViewState();
}

class _RoleViewState extends State<RoleView> {
  String playerName = "";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    playerName = args["username"];

    return Scaffold(
        appBar: AppBar(
          title: const Text("See Role"),
          // backgroundColor: Colors.green,
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        body: FutureBuilder(
          future: _seeRole(playerName),
          builder: (context, snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              Map data = snapshot.data as Map;

              var gameId = data["gameId"];
              String roleName = data["roleName"];
              var isMayor = data["isMayor"];
              var magicWord = data["magicWord"];
              var roleColor = roleName == "werewolf" ? Colors.red : Colors.blue;
              return Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.all(12),
                elevation: 5,
                child: Stack(
                  children: [
                    Center(
                      child: Icon(RpgIconUtil.toIcon(roleName),
                          size: 400.0, color: roleColor.withOpacity(0.15)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Game ID : $gameId",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .apply(color: Colors.grey)),
                            const SizedBox(height: 20),
                            Text(playerName.capitalize(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .apply(color: Colors.black)),
                            Text(
                                isMayor == 1
                                    ? "Mayor-${roleName.capitalize()}"
                                    : roleName.capitalize(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .apply(color: roleColor)),
                            _magicWord(magicWord),
                            _werewolves(data),
                            _mayorButton(isMayor)
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              );
            } else {
              children = const <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                ),
              ];
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            );
          },
        ));
  }

  Widget _werewolves(data) {
    var roleName = data["roleName"];

    if (roleName == "werewolf") {
      var otherWerewolves = data["otherWerewolves"] as List;

      if (otherWerewolves.isEmpty) {
        return Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Text("You Are The Only Werewolf",
                style: Theme.of(context).textTheme.headline5),
          ],
        );
      }

      var texts = <Text>[];
      for (var e in otherWerewolves) {
        texts.add(Text(
          e,
          style:
              Theme.of(context).textTheme.headline5!.apply(color: Colors.red),
        ));
      }

      return Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Text("Other Werewolves:",
              style: Theme.of(context).textTheme.headline5),
          ...texts
        ],
      );
    }

    return const SizedBox();
  }

  Widget _mayorButton(isMayor) {
    return isMayor == 1
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
            child: IconButton(
                onPressed: () => Navigator.pushNamed(context, '/mayor'),
                icon: const Icon(
                  FontAwesomeIcons.crown,
                  color: Colors.green,
                )),
          )
        : const SizedBox();
  }

  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Colors.red, Colors.blue],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 300, 70.0));

  Widget _magicWord(magicWord) {
    if (magicWord != null && magicWord.toString().isNotEmpty) {
      return Column(children: [
        Text(
          'The Magic Word is:',
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(magicWord,
            style: Theme.of(context)
                .textTheme
                .headline4!
                .apply(color: Colors.black)),
      ]);
    }

    return const SizedBox();
  }

  _seeRole(username) async {
    Response response;
    var uri = Uri.parse('${Config.getServerIp()}/game/seerole/$username');

    try {
      response = await http.get(uri).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return http.Response('Server did not respond at\n$uri', 408);
        },
      );
    } catch (e) {
      AlertOk.showAlert(context, e.toString());
      Navigator.pop(context); // returns to /cover
      return;
    }

    if (!mounted) return;

    if (response.statusCode != 200) {
      // Navigator.popUntil(context, ModalRoute.withName('/cover'));
      Navigator.pop(context);
      AlertOk.showAlert(
        context,
        response.body,
      );
      return;
    }

    return jsonDecode(response.body);
  }

  Future<int> getIsMayor(username) async {
    Response response;
    var uri = Uri.parse('${Config.getServerIp()}/game/seerole/$username');

    try {
      response = await http.get(uri).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return http.Response('Server did not respond at\n$uri', 408);
        },
      );
    } catch (e) {
      AlertOk.showAlert(context, e.toString());
      return -1;
    }

    if (!mounted) return -1;

    if (response.statusCode != 200) {
      AlertOk.showAlert(context, response.body);
      return -1;
    }

    return jsonDecode(response.body);
  }
}
