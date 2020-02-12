import 'package:flutter/material.dart';
import 'package:sinoniza_app/modules/synonym/synonym.dart';
import '../styles.dart';

class SynonymBox extends StatefulWidget {
  final Synonym synonym;

  SynonymBox({this.synonym});

  @override
  _SynonymBoxState createState() => _SynonymBoxState();
}

class _SynonymBoxState extends State<SynonymBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Text(
          'here...',
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.orange,
            border: Border.all(
              color: Colors.black,
              width: 2.0,
            ),
          ),
          child: FlatButton(
            textColor: Colors.white,
            child: Container(
              child: Text(
                'Random',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            onPressed: this._setRandomPhrase,
          ),
        ),
      ],
    ));
  }
}
