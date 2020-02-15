import 'package:flutter/material.dart';
import 'package:sinoniza_app/modules/synonym/synonym.dart';
import '../styles.dart';

class SynonymBox extends StatefulWidget {
  final Synonym synonym;
  final Function onTalk;

  SynonymBox({
    this.synonym,
    this.onTalk,
  });

  @override
  _SynonymBoxState createState() => _SynonymBoxState();
}

class _SynonymBoxState extends State<SynonymBox> {
  String _randomPhrase = '';
  SynonymItem _selectedSynonymItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Wrap(
                children: this._getPhraseSeparated(),
              ),
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
      ),
    );
  }

  void _setRandomPhrase() {
    setState(() {
      widget.synonym.setRandomPhrase();
      _randomPhrase = widget.synonym.getRandomPhrase();
      widget.onTalk(_randomPhrase);
    });
  }

  List<Widget> _getPhraseSeparated() {
    List<Widget> list = widget.synonym.list.map((item) {
      final randomWord = item.selectedRandom();
      final color = item.synonyms.length > 0 ? Colors.lightGreen : Colors.white;
      return Container(
        margin: EdgeInsets.only(right: 3.0),
        decoration: BoxDecoration(
          color: color,
        ),
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: InkWell(
            onTap: () => this._onSelectWord(item),
            child: Text(
              randomWord,
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
          ),
        ),
      );
    }).toList();
    return list;
  }

  void _onSelectWord(SynonymItem item) {
    setState(() {
      _selectedSynonymItem = item;
      // @todo: open modal
    });
  }
}
