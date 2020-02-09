import 'dart:convert';
import 'package:sinoniza_app/helpers/api.dart';
import 'package:sinoniza_app/modules/synonym/synonym.dart';

class SynonymApi {
  static Future<Synonym> getSynonyms(Object data) async {
    final path = 'synonyms';
    final response = await Api.get(path, data);
    final responseJson = json.decode(response.body);
    if (responseJson['success']) {
      return Synonym.fromJson(responseJson['data']);
    } else {
      throw ApiException(responseJson['message']);
    }
  }
}
