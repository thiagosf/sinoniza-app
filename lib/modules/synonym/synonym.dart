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
    Synonym item = Synonym(
      list: list,
      originalPhrase: json['original_phrase'],
      suggestPhrase: json['suggest_phrase'],
    );
    item.setRandomPhrase();
    return item;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['list'] = this.list.map((v) => v.toJson()).toList();
    data['original_phrase'] = this.originalPhrase;
    data['suggest_phrase'] = this.suggestPhrase;
    return data;
  }

  void setRandomPhrase() {
    list = list.map((SynonymItem item) {
      if (item.synonyms.isEmpty == false) {
        var randomizer = new Random();
        int random = randomizer.nextInt(item.synonyms.length);
        int index = 0;
        item.synonyms = item.synonyms.map((value) {
          if (index == random) {
            value.selected = true;
          } else {
            value.selected = false;
          }
          if (item.locked) {
            value.selected = false;
          }
          index++;
          return value;
        }).toList();
      }
      return item;
    }).toList();
  }

  String getRandomPhrase() {
    return this.list.map((SynonymItem item) {
      String output = item.value;
      if (item.synonyms.isEmpty == false && !item.locked) {
        item.synonyms.forEach((item) {
          if (item.selected) {
            output = item.value;
          }
        });
      }
      return output;
    }).join(' ');
  }
}

class SynonymItem {
  int position;
  String value;
  List<SynonymItemWord> synonyms;
  bool locked;

  SynonymItem({
    this.position,
    this.value,
    this.synonyms,
    this.locked,
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
        locked: false);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['position'] = this.position;
    data['value'] = this.value;
    data['synonyms'] = this.synonyms.map((v) => v.toJson()).toList();
    data['locked'] = this.locked;
    return data;
  }

  String selectedRandom() {
    String output = value;
    if (!locked) {
      if (synonyms.length > 0) {
        synonyms.forEach((item) {
          if (item.selected) {
            output = item.value;
          }
        });
      }
    }
    return output;
  }

  void selectSynonym(SynonymItemWord synonym) {
    locked = false;
    synonyms = synonyms.map((child) {
      if (child == synonym) {
        child.selected = true;
      } else {
        child.selected = false;
      }
      return child;
    }).toList();
  }

  List<SynonymItemWord> synonymsSortedMeaning() {
    List<SynonymItemWord> sortedSynonyms = List<SynonymItemWord>.from(synonyms);
    sortedSynonyms
        .sort((a, b) => a.meaning.toString().compareTo(b.meaning.toString()));
    return sortedSynonyms;
  }

  void lock() {
    locked = true;
  }

  void unlock() {
    locked = false;
  }
}

class SynonymItemWord {
  int id;
  String value;
  String meaning;
  bool selected;

  SynonymItemWord({
    this.id,
    this.value,
    this.meaning,
    this.selected,
  });

  factory SynonymItemWord.fromJson(Map<String, dynamic> json) {
    return SynonymItemWord(
      id: json['id'],
      value: json['value'],
      meaning: json['meaning'],
      selected: false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['value'] = this.value;
    data['meaning'] = this.meaning;
    data['selected'] = this.selected;
    return data;
  }
}
