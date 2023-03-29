import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HelperFunctions {
  static const String _sharedPreferenceFavoritesListTags = 'favorites';
  // static const String _sharedPreferenceSettingsValues = 'settings';
  static const String _sharedPreferenceBoardsMap = 'settings';


  static Future<bool> addFavoritesSharedPreference(String tag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesTagsList =
        prefs.getStringList(_sharedPreferenceFavoritesListTags);
    if (favoritesTagsList == null) {
      favoritesTagsList = [tag];
    } else {
      if(!favoritesTagsList.contains(tag)) {
        favoritesTagsList.add(tag);
      }
    }
    return await prefs.setStringList(
        _sharedPreferenceFavoritesListTags, favoritesTagsList);
  }

  static Future<List<String>?> getFavoritesSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_sharedPreferenceFavoritesListTags);
  }

  static Future deleteFavoritesSharedPreference(String tag) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesTagsList =
    prefs.getStringList(_sharedPreferenceFavoritesListTags);
    if (favoritesTagsList == null) {
      return ;
    } else {
        favoritesTagsList.removeWhere((listTag) => listTag == tag);
    }
    return await prefs.setStringList(
        _sharedPreferenceFavoritesListTags, favoritesTagsList);

  }


  static Future<void> addBoardsSharedPreference(Map<String,dynamic> decodedBoardsMap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String,dynamic> _fetchedBoards = decodedBoardsMap ;
    var jsonBoards = jsonEncode(_fetchedBoards);
    prefs.setString(_sharedPreferenceBoardsMap, jsonBoards);
  }

  static Future<String?> getBoardsSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sharedPreferenceBoardsMap);
  }
}
