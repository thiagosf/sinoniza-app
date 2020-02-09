import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sinoniza_app/modules/synonym/synonym.dart';
import 'package:speech_recognition/speech_recognition.dart';
import '../modules/synonym/synonym_api.dart';

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
  String _randomPhrase = '';
  bool _showSpinner = false;
  Synonym _synonym;
  bool _autoPlay = true;

  @override
  void initState() {
    super.initState();
    _setTts();
    _activateSpeechRecognizer();
  }

  void _setTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage(_ttsLocale);
  }

  void _activateSpeechRecognizer() {
    _speech = new SpeechRecognition();
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(_onSpeechAvailability);
    _speech.setCurrentLocaleHandler(_onCurrentLocale);
    _speech.setRecognitionStartedHandler(_onRecognitionStarted);
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
      ),
      body: Container(
        color: Colors.yellow,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _formController,
                    ),
                    RaisedButton(
                      child: Text('Enviar'),
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () {
                        this._onSubmit();
                      },
                    ),
                    Text(_randomPhrase),
                    this._getRandomButton(),
                    this._getSpinner(),
                    RaisedButton(
                      child: Text('Talk'),
                      color: Colors.pink,
                      onPressed: this._startListen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    setState(() {
      _showSpinner = true;
    });
    SynonymApi.getSynonyms({'phrase': _formController.text})
        .then((Synonym synonym) {
      setState(() {
        _showSpinner = false;
        _synonym = synonym;
        _setRandomPhrase();
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

  Widget _getSpinner() {
    return _showSpinner
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[CircularProgressIndicator()],
          )
        : SizedBox();
  }

  Widget _getRandomButton() {
    if (_synonym != null) {
      return RaisedButton(
        child: Text('Random'),
        color: Colors.green,
        onPressed: () => this._setRandomPhrase(),
      );
    }
    return SizedBox();
  }

  void _setRandomPhrase() {
    setState(() {
      _randomPhrase = _synonym.getRandomPhrase();
      if (_autoPlay) {
        _flutterTts.speak(_randomPhrase);
      }
    });
  }

  void _startListen() async {
    if (_speechRecognitionAvailable) {
      _speech.listen(locale: _currentLocale).then((result) {
        print(['listen...', result]);
      }).catchError((error) {
        print(error);
      });
    }
  }

  void _onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void _onCurrentLocale(String locale) {
    setState(() => _currentLocale = locale);
  }

  void _onRecognitionStarted() => setState(() => _isListening = true);

  void _onRecognitionResult(String text) =>
      setState(() => _transcription = text);

  void _onRecognitionComplete(String text) {
    _formController.text = _transcription;
    if (_transcription != '') {
      _onSubmit();
    }
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechErrorHandler() => _activateSpeechRecognizer();
}
