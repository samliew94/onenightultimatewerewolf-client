import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import 'alert_ok.dart';
import 'config.dart';

// ignore: must_be_immutable
class EndGameButton extends StatefulWidget {
  String username;
  Map<dynamic, dynamic>? optionalData;

  EndGameButton(this.username, {this.optionalData, super.key});

  @override
  State<EndGameButton> createState() => _EndGameButtonState();
}

class _EndGameButtonState extends State<EndGameButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.play_arrow),
      onPressed: () => _endGame(),
    );
  }

  _endGame() async {
    Response res;
    var uri = Uri.parse('${Config.getServerIp()}/game/end');

    var data = {"username": widget.username};

    if (widget.optionalData != null && widget.optionalData!.isNotEmpty) {
      widget.optionalData!.forEach((key, value) {
        data.putIfAbsent(key, () => value);
      });
    }

    try {
      res = await http
          .post(uri,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(data))
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

    Navigator.pushNamed(context, '/${body["route"]}',
        arguments: {'username': widget.username});
  }
}
