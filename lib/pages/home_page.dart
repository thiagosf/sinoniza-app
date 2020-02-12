import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sinoniza_app/components/synonym_box.dart';
import 'package:sinoniza_app/modules/synonym/synonym.dart';
import 'package:speech_recognition/speech_recognition.dart';
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
  String _randomPhrase = '';
  bool _showSpinner = false;
  Synonym _synonym;
  bool _autoPlay = true;
  String _lastTranscription;
  bool _avoidRepetitiveRequest = true;

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
      ),
      body: Container(
        color: AppColors.yellow,
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
                      child: TextField(
                        onSubmitted: (text) => this._onSubmit(),

                        // maxLines: 3,
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
                            style: TextStyle(fontSize: 20.0),
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
      } else {
        this._setRandomPhrase();
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
    if (_randomPhrase != '') {
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: SynonymBox(synonym: _synonym),
            ),
          ),
        ],
      );
    }
    return SizedBox();
  }
}
