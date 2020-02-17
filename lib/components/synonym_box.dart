import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sinoniza_app/modules/synonym/synonym.dart';
import '../styles.dart';

class SynonymBox extends StatefulWidget {
  final Synonym synonym;
  final Function onTalk;
  final Function onNotificate;

  SynonymBox({
    this.synonym,
    this.onTalk,
    this.onNotificate,
  });

  @override
  _SynonymBoxState createState() => _SynonymBoxState();
}

class _SynonymBoxState extends State<SynonymBox> {
  String _randomPhrase = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
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
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: this._getPhraseSeparated(),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: this._speak,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: this._copy,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.content_copy,
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
      final wordColor = item.locked ? Colors.lightBlue : Colors.lightGreen;
      final color = item.synonyms.length > 0 ? wordColor : Colors.white;
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
    if (item.synonyms.length > 0) {
      String lastMeaning;
      final textToggleLock =
          item.locked ? 'Desbloquear palavra' : 'Travar palavra';
      showDialog(
        context: context,
        child: SimpleDialog(
          titlePadding: EdgeInsets.all(20),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 32,
                  color: AppColors.blue,
                ),
              ),
              SizedBox(height: 5.0),
              InkWell(
                onTap: () {
                  setState(() {
                    if (!item.locked) {
                      item.lock();
                    } else {
                      item.unlock();
                    }
                    _randomPhrase = widget.synonym.getRandomPhrase();
                    widget.onTalk(_randomPhrase);
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  color: AppColors.yellow,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(textToggleLock),
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                'Troque o sinônimo',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          children: item.synonymsSortedMeaning().map((synonym) {
            final meaning = synonym.meaning != null ? synonym.meaning : '---';
            bool showMeaning = lastMeaning != meaning;
            lastMeaning = meaning;
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  item.selectSynonym(synonym);
                  _randomPhrase = widget.synonym.getRandomPhrase();
                  widget.onTalk(_randomPhrase);
                });
                Navigator.pop(context);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  showMeaning
                      ? Text(
                          meaning,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        )
                      : SizedBox(),
                  showMeaning
                      ? SizedBox(
                          height: 10.0,
                        )
                      : SizedBox(),
                  Row(
                    children: <Widget>[
                      synonym.selected
                          ? Icon(
                              Icons.check,
                              color: AppColors.orange,
                            )
                          : SizedBox(),
                      Text(
                        synonym.value,
                        style: TextStyle(
                          color: synonym.selected
                              ? AppColors.orange
                              : Colors.black,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  void _speak() {
    widget.onTalk(_randomPhrase);
  }

  void _copy() {
    print(_randomPhrase);
    Clipboard.setData(new ClipboardData(text: _randomPhrase));
    widget.onNotificate('Texto copiado!');
  }
}
