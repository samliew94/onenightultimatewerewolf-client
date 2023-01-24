import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:onuwweb/extensions.dart';

class TempWidget extends StatefulWidget {
  dynamic data;
  TempWidget({this.data, super.key});

  @override
  State<TempWidget> createState() => _TempWidgetState();
}

class _TempWidgetState extends State<TempWidget> {
  @override
  Widget build(BuildContext context) {
    var data = widget.data;

    double top = data["top"] ?? 0;
    String title = data["title"];
    var color =
        data["color"] == null ? Colors.white : HexColor.fromHex(data["color"]);
    var textStyle = _textStyle(data["size"]);

    return Column(
      children: [
        SizedBox(height: top),
        Text(title.capitalize(),
            style: textStyle.apply(color: color), textAlign: TextAlign.center),
      ],
    );
  }

  TextStyle _textStyle(size) {
    var textTheme = Theme.of(context).textTheme;
    TextStyle textStyle = textTheme.headline3!; // default

    if (size == 1) {
      return Theme.of(context).textTheme.headline1!;
    } else if (size == 2) {
      return Theme.of(context).textTheme.headline2!;
    } else if (size == 4) {
      return Theme.of(context).textTheme.headline4!;
    } else if (size == 5) {
      return Theme.of(context).textTheme.headline5!;
    } else if (size == 6) {
      return Theme.of(context).textTheme.headline6!;
    }

    return textStyle;
  }
}
