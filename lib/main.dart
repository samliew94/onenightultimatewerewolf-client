import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:onuwweb/drunkAction.dart';
import 'package:onuwweb/finalrole.dart';
import 'package:onuwweb/genericDone.dart';
import 'package:onuwweb/lonewerewolfaction.dart';
import 'package:onuwweb/quiz.dart';
import 'package:onuwweb/robberAction.dart';
import 'package:onuwweb/robberDone.dart';
import 'package:onuwweb/seercenterdone.dart';
import 'package:onuwweb/seerplayerdone.dart';
import 'package:onuwweb/seeraction.dart';
import 'package:onuwweb/tempwidget.dart';
import 'package:onuwweb/timer.dart';
import 'package:onuwweb/troublemakerAction.dart';
import 'package:onuwweb/troublemakerDone.dart';
import 'package:onuwweb/villagerDone.dart';
import 'package:onuwweb/werewolvesDone.dart';

import 'alert_ok.dart';
import 'config.dart';
import 'lobby.dart';
import 'lonewerewolfdone.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'One Night Ultimate Werewolf',
        theme: _buildTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const MyHomePage(),
          '/lobby': (context) => const LobbyView(),
          '/settings': (context) => const SettingsView(),
          '/loneWerewolfAction': (context) => const LoneWerewolfActionView(),
          '/seerAction': (context) => const SeerActionView(),
          '/robberAction': (context) => const RobberActionView(),
          '/troublemakerAction': (context) => const TroublemakerActionView(),
          '/drunkAction': (context) => const DrunkActionView(),
          '/genericDone': (context) => const GenericDoneView(),
          '/finalRole': (context) => const FinalRoleView(),
          '/quiz': (context) => const QuizView(),
        });
  }

  ThemeData _buildTheme() {
    var baseTheme = ThemeData(
        brightness: Brightness.dark,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.red, foregroundColor: Colors.white));

    return baseTheme.copyWith(
        textTheme: GoogleFonts.mysteryQuestTextTheme(baseTheme.textTheme));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ipController = TextEditingController();
  final usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    ipController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as dynamic;
    if (args != null) {
      usernameController.text = args["username"];
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("One Night Ultimate Werewolf"),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Stack(
            children: [
              SizedBox.expand(
                child: FittedBox(
                  child: Icon(RpgAwesome.wolf_howl,
                      color: Colors.red.withOpacity(0.50)),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "One Night Ultimate Werewolf",
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .apply(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          textAlign: TextAlign.center,
                          controller: usernameController,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter Your Name',
                              hintStyle:
                                  Theme.of(context).textTheme.labelLarge),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name cannot be empty';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            addPlayer(usernameController.text);
          }
        },
        tooltip: 'Next',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  void addPlayer(String username) async {
    Response response;
    var uri = '${Config.getServerIp()}/players/add';

    try {
      response = await http
          .post(Uri.parse(uri),
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
    } catch (e) {
      AlertOk.showAlert(context, e.toString());
      return;
    }

    if (!mounted) return;

    if (response.statusCode != 200) {
      AlertOk.showAlert(context, response.body);
      return;
    }

    var body = jsonDecode(response.body);

    Navigator.pushNamed(context, '/${body["route"]}',
        arguments: {'username': username});
  }
}
