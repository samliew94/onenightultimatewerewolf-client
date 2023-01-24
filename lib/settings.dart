import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:onuwweb/awaitingresult.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'extensions.dart';
import 'rpgicon.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  var isActives = {};

  _showSnackBar(msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(msg),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<dynamic>(
        future: _refRolesAll(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data as List;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                var map = data[index];
                var refRoleId = map["refRoleId"];
                var roleName = map["roleName"];
                var count = map["count"];
                var color = map["color"];

                return Card(
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(
                            color: HexColor.fromHex(color),
                            RpgIconUtil.toIcon(roleName)),
                        const SizedBox(width: 20),
                        Text(roleName,
                            style: Theme.of(context).textTheme.headline5),
                      ],
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      IconButton(
                          splashRadius: 1,
                          onPressed: () => _editRefRole(refRoleId, -1),
                          icon: const Icon(
                            FontAwesomeIcons.circleMinus,
                            color: Colors.red,
                          )),
                      IconButton(
                          splashRadius: 1,
                          onPressed: () => _editRefRole(refRoleId, 1),
                          icon: const Icon(FontAwesomeIcons.circlePlus,
                              color: Colors.green))
                    ]),
                  ),
                );
              },
            );
          }

          return const AwaitingResult();
        },
      ),
    );
  }

  Future _editRefRole(refRoleId, operation) async {
    Response res;
    try {
      res = await http.put(
        Uri.parse('${Config.getServerIp()}/refroles/edit'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'refRoleId': refRoleId, 'operation': operation}),
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

    setState(() {});
  }

  Future _editToken(tokenId, operation) async {
    Response res;
    try {
      res = await http.put(
        Uri.parse('${Config.getServerIp()}/settings/edit/token'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'tokenId': tokenId, 'operation': operation}),
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

    setState(() {});
  }

  Future _editTimer(operation) async {
    Response res;
    try {
      res = await http.put(
        Uri.parse('${Config.getServerIp()}/settings/edit/timer'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'operation': operation}),
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

    setState(() {});
  }

  _refRolesAll() async {
    Response res;
    try {
      res = await http.get(Uri.parse('${Config.getServerIp()}/refroles/all'));
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
    int totalPlayers = body["totalPlayers"];
    int totalRoles = body["totalRoles"];

    _showSnackBar("Players=Roles : $totalPlayers=$totalRoles");

    return body["results"];
  }
}
