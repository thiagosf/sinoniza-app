import 'dart:math';

class Synonym {
  List<SynonymItem> list;
  String originalPhrase;
  String suggestPhrase;

  Synonym({
    this.list,
    this.originalPhrase,
    this.suggestPhrase,
  });

  factory Synonym.fromJson(Map<String, dynamic> json) {
    var list = new List<SynonymItem>();
    if (json['list'] != null) {
      json['list'].forEach((v) {
        list.add(SynonymItem.fromJson(v));
      });
    }
    return Synonym(
      list: list,
      originalPhrase: json['original_phrase'],
      suggestPhrase: json['suggest_phrase'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['list'] = this.list.map((v) => v.toJson()).toList();
    data['original_phrase'] = this.originalPhrase;
    data['suggest_phrase'] = this.suggestPhrase;
    return data;
  }

  String getRandomPhrase() {
    return this.list.map((SynonymItem item) {
      String output = item.value;
      if (item.synonyms.isEmpty == false) {
        var randomizer = new Random();
        int random = randomizer.nextInt(item.synonyms.length);
        output = item.synonyms[random].value;
      }
      return output;
    }).join(' ');
  }
}

class SynonymItem {
  int position;
  String value;
  List<SynonymItemWord> synonyms;

  SynonymItem({
    this.position,
    this.value,
    this.synonyms,
  });

  factory SynonymItem.fromJson(Map<String, dynamic> json) {
    var synonyms = new List<SynonymItemWord>();
    if (json['synonyms'] != null) {
      json['synonyms'].forEach((v) {
        synonyms.add(SynonymItemWord.fromJson(v));
      });
    }
    return SynonymItem(
      position: json['position'],
      value: json['value'],
      synonyms: synonyms,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['position'] = this.position;
    data['value'] = this.value;
    data['synonyms'] = this.synonyms.map((v) => v.toJson()).toList();
    return data;
  }
}

class SynonymItemWord {
  int id;
  String value;

  SynonymItemWord({
    this.id,
    this.value,
  });

  factory SynonymItemWord.fromJson(Map<String, dynamic> json) {
    return SynonymItemWord(
      id: json['id'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['value'] = this.value;
    return data;
  }
}
