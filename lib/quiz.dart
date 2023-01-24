import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:onuwweb/custombackbutton.dart';

import 'alert_ok.dart';
import 'config.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  var counter = 0;
  var max = 0;
  var random = Random.secure();
  String username = "";

  @override
  void initState() {
    max = random.nextInt(8) + 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    username = args["username"];

    return Scaffold(
        appBar: AppBar(
          leading: const CustomBackButton(),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Press the buttons\nin Ascending Order",
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 8.0,
                  children: [..._createButtons()]),
            ),
          ],
        ));
  }

  _createButtons() {
    var buttons = [];
    for (var i = 0; i < max; i++) {
      buttons.add(_createButton(i));
    }
    buttons.shuffle(random);

    return buttons;
  }

  Widget _createButton(i) {
    var c = random.nextInt(3);
    Color cardColor = Colors.grey;

    if (c == 0) {
      cardColor = Colors.red;
    } else if (c == 1) {
      cardColor = Colors.blue;
    } else if (c == 2) {
      cardColor = Colors.green;
    }

    return InkWell(
      onTap: () => counter == i ? _onClickButton(i) : null,
      child: Card(
          color: cardColor,
          elevation: 5,
          child: Center(
            child: Text(
              counter > i ? "" : i.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .apply(color: Colors.white),
            ),
          )),
    );
  }

  _onClickButton(i) async {
    if (counter != i) {
      return;
    }

    setState(() {
      counter += 1;
    });

    if (counter != max) return;

    Response res;
    var uri = Uri.parse('${Config.getServerIp()}/actionhistory/completeaction');

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

    var body = jsonDecode(res.body);

    Navigator.pushNamed(context, '/${body['route']}',
        arguments: {'username': username});
  }
}
