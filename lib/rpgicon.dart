import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RpgIconUtil {
  static IconData toIcon(String name) {
    if (name == "werewolf") return RpgAwesome.wolf_head;
    if (name == "seer") return RpgAwesome.crystal_ball;
    if (name == "robber") return RpgAwesome.hand_emblem;
    if (name == "troublemaker") return RpgAwesome.uncertainty;
    if (name == "villager") return RpgAwesome.trident;
    if (name == "tanner") return RpgAwesome.player_despair;
    if (name == "drunk") return RpgAwesome.beer;
    if (name == "hunter") return RpgAwesome.musket;
    if (name == "mason") return RpgAwesome.large_hammer;
    if (name == "minion") return RpgAwesome.snake;

    return FontAwesomeIcons.question;
  }
}
