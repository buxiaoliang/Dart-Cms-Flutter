import 'package:flutter/material.dart';
// clause
import '../../components/userClause.dart' show buildUserClause;

class Declare extends StatefulWidget {
  Map args;
  Declare({Key key, this.args}) : super(key: key);

  @override
  _DeclareState createState() => _DeclareState(args);
}

class _DeclareState extends State<Declare> {
  Map args;
  _DeclareState(this.args);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('免责申明'),
      ),
      body: buildUserClause(),
    );
  }
}
