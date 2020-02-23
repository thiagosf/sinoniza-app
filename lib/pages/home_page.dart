import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sinoniza_app/components/synonym_box.dart';
import 'package:sinoniza_app/modules/synonym/synonym.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../modules/synonym/synonym_api.dart';
import '../styles.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formController = TextEditingController();
  SpeechRecognition _speech;
  FlutterTts _flutterTts;
  bool _speechRecognitionAvailable = false;
  String _currentLocale = 'pt-BR';
  String _ttsLocale = 'pt-BR';
  String _transcription;
  bool _isListening = false;
  bool _showSpinner = false;
  Synonym _synonym;
  bool _autoPlay = true;
  String _lastTranscription;
  bool _avoidRepetitiveRequest = true;

  @override
  void initState() {
    super.initState();
    _setTts();
    _requestPermissions();
    // _activateSpeechRecognizer();
  }

  void _setTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage(_ttsLocale);
  }

  void _activateSpeechRecognizer() async {
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(_onSpeechAvailability);
    _speech.setCurrentLocaleHandler(_onCurrentLocale);
    _speech.setRecognitionResultHandler(_onRecognitionResult);
    _speech.setRecognitionCompleteHandler(_onRecognitionComplete);
    _speech.setErrorHandler(_onSpeechErrorHandler);
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Sinoniza'),
        elevation: 2.0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.info,
              color: AppColors.blue,
            ),
            onPressed: this._openAbout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.yellow,
          image: DecorationImage(
            image: AssetImage('assets/images/pattern-bg.png'),
            fit: BoxFit.none,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                onSubmitted: (text) => this._onSubmit(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                                controller: _formController,
                                decoration: InputDecoration(
                                  labelText: 'Digite uma palavra ou frase',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                  focusColor: Colors.black,
                                  fillColor: Colors.red,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: BorderSide(
                                      style: BorderStyle.solid,
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: BorderSide(
                                      style: BorderStyle.solid,
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: this._clearText,
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Icon(
                                          Icons.close,
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
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      child: FlatButton(
                        textColor: Colors.white,
                        child: Container(
                          child: Text(
                            'Enviar',
                            style: TextStyle(fontSize: 24.0),
                          ),
                        ),
                        onPressed: this._onSubmit,
                      ),
                    ),
                    this._getPhrase(),
                    this._getSpinner(),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 70.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: this._startListen,
        child: Icon(
          Icons.mic,
          size: 32.0,
        ),
        backgroundColor: AppColors.blue,
      ),
    );
  }

  void _onSubmit() {
    if (_formController.text != '') {
      if (_lastTranscription != _formController.text &&
          _avoidRepetitiveRequest) {
        _lastTranscription = _formController.text;
        setState(() {
          _showSpinner = true;
        });
        SynonymApi.getSynonyms({'phrase': _formController.text})
            .then((Synonym synonym) {
          setState(() {
            _showSpinner = false;
            _synonym = synonym;
            this._talkPhrase(_synonym.getRandomPhrase());
          });
        }).catchError((error) {
          setState(() {
            _showSpinner = false;
          });
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        });
      }
    }
  }

  Widget _getSpinner() {
    return _showSpinner
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ],
          )
        : SizedBox();
  }

  void _startListen() async {
    if (_speechRecognitionAvailable) {
      if (_isListening) {
        _speech.cancel();
        setState(() {
          _isListening = false;
        });
      } else {
        _speech.listen(locale: _currentLocale).then((result) {
          setState(() {
            _isListening = true;
          });
        }).catchError((error) {
          print(error);
        });
      }
    }
  }

  void _onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void _onCurrentLocale(String locale) {
    setState(() => _currentLocale = locale);
  }

  void _onRecognitionResult(String text) =>
      setState(() => _transcription = text);

  void _onRecognitionComplete(String text) {
    _formController.text = _transcription;
    if (_transcription != '' && _transcription != null) {
      _onSubmit();
    }
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechErrorHandler() => _activateSpeechRecognizer();

  Widget _getPhrase() {
    if (_synonym != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Text(
            'Quem sabe você possa falar:',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          SynonymBox(
            synonym: _synonym,
            onTalk: this._talkPhrase,
            onNotificate: this._onNotificate,
          ),
        ],
      );
    }
    return SizedBox();
  }

  void _talkPhrase(phrase) {
    if (_autoPlay) {
      _flutterTts.speak(phrase);
    }
  }

  void _onNotificate(text) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  void _clearText() {
    _formController.text = '';
  }

  void _openAbout() {
    showDialog(
      context: context,
      child: SimpleDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image(
                image: AssetImage('assets/images/logo-about.png'),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Versão 1.0.0',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Esse aplicativo foi construído com a ajuda de alguns softwares gratuitos, como:',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 10.0),
              ]
                ..addAll(this._getUsedTools())
                ..addAll(this._getGithubRepos()),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getUsedTools() {
    final usedTools = [
      {
        'name': 'Flutter',
        'link': 'https://flutter.dev',
      },
      {
        'name': 'NodeJS',
        'link': 'https://nodejs.org',
      }
    ];
    return usedTools.map((item) {
      return this._getLink(item['name'], item['link']);
    }).toList();
  }

  List<Widget> _getGithubRepos() {
    return [
      SizedBox(
        height: 20.0,
      ),
      Text(
        'O código desse projeto é open source, veja como foi construído:',
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
      SizedBox(height: 10.0),
      this._getLink('Flutter App', 'https://github.com/thiagosf/sinoniza-app'),
      this._getLink('NodeJS API', 'https://github.com/thiagosf/sinoniza-api'),
    ];
  }

  Widget _getLink(text, url) {
    return InkWell(
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              style: BorderStyle.solid,
              color: AppColors.yellow,
              width: 2.0,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 5.0,
            bottom: 5.0,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 22.0,
              color: AppColors.blue,
            ),
          ),
        ),
      ),
    );
  }

  void _requestPermissions() async {
    var permitted = false;

    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);

    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.microphone]);
      permitted =
          permissions[PermissionGroup.microphone] == PermissionStatus.granted;
    }

    if (permitted) {
      this._activateSpeechRecognizer();
    }
  }
}
