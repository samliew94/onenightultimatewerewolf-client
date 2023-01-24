import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MayorTokenView extends StatefulWidget {
  final dynamic tokens;

  const MayorTokenView({super.key, required this.tokens});

  @override
  State<MayorTokenView> createState() => _MayorTokenViewState();
}

class _MayorTokenViewState extends State<MayorTokenView> {
  dynamic yesno, maybe, soclose, waywayoff;

  @override
  void initState() {
    for (var token in widget.tokens) {
      if (token["tokenId"] == 1) yesno = token;
      if (token["tokenId"] == 2) maybe = token;
      if (token["tokenId"] == 3) soclose = token;
      if (token["tokenId"] == 4) waywayoff = token;
    }
    super.initState();
  }

  Widget tokenCard(token) {
    return SizedBox(
        width: 200,
        height: 200,
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(token["tokenName"],
                style: Theme.of(context).textTheme.headline5),
            Text(token["tokenCount"].toString(),
                style: Theme.of(context).textTheme.headline4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  splashRadius: 1,
                  icon: const Icon(
                    size: 32,
                    FontAwesomeIcons.circleMinus,
                    color: Colors.red,
                  ),
                  onPressed: () => setState(() {
                    token["tokenCount"] -= 1;
                    if (token["tokenCount"] < 0) token["tokenCount"] = 0;
                  }),
                ),
                IconButton(
                  splashRadius: 1,
                  icon: const Icon(FontAwesomeIcons.circlePlus,
                      size: 32, color: Colors.green),
                  onPressed: () => setState(() {
                    token["tokenCount"] += 1;
                    if (token["tokenCount"] > 99) token["tokenCount"] = 99;
                  }),
                ),
              ],
            )
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tokenCard(yesno),
                tokenCard(maybe),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tokenCard(soclose),
                tokenCard(waywayoff),
              ],
            ),
          )
        ],
      ),
    );
  }
}
