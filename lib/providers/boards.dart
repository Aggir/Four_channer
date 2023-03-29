import 'package:flutter/material.dart';
import 'package:four_channer/providers/thread_class.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';
import '../models/helper_functions.dart';
import '../values/boards_colors.dart';
import 'board_class.dart';

class Boards with ChangeNotifier {
  List<BoardClass> _boards = [
    // Board(title: 'test', tag: 'hmh'),
    // Board(title: 'test2', tag: 'mah'),
    // Board(title: 'test3', tag: 'h'),
  ];

  List<BoardClass> _favoriteBoards = [];

  List<BoardClass> get boards {
    return _boards;
  }

  List<BoardClass> get favoriteBoards {
    return _favoriteBoards;
  }

  Future<void> fetchAndSetBoards({bool refresh = false}) async {
    String? encodedBoardsMap =
        await HelperFunctions.getBoardsSharedPreference();
    final url = Uri.parse('https://a.4cdn.org/boards.json');
    try {
      var _extractedData;
      if (encodedBoardsMap == null || refresh) {
        final response = await http.get(url);
        _extractedData = json.decode(response.body) as Map<String, dynamic>;
        HelperFunctions.addBoardsSharedPreference(_extractedData);
      } else {
        _extractedData = json.decode(encodedBoardsMap);
      }
      final extractedData = _extractedData as Map<String,dynamic>;
      // print('printed : ${extractedData.values}');
      List<BoardClass> loadedBoards = [];
      int index = 0;
      loadedBoards =
          (extractedData.values.expand((l) => l).toList()).map((item) {
        bool isSafeForWork = item['ws_board'] == 1;
        BoardClass tempBoard = BoardClass(
          title: item['title'],
          tag: item['board'],
          isSafeForWork: isSafeForWork,
          color: BoardsColors.list[index],
        );
        index++;
        return tempBoard;
      }).toList();
      _boards = loadedBoards;
      _boards.removeWhere((element) => element.tag == 'f');
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> setFavoriteBoards() async {
    final loadedTagsList = await HelperFunctions.getFavoritesSharedPreference();
    if (loadedTagsList != null) {
      for (String tag in loadedTagsList) {
        if (_favoriteBoards.where((element) => element.tag == tag).isEmpty) {
          _favoriteBoards.add(findBoardByTag(tag));
        }
      }
      notifyListeners();
    }
  }

  void addFavoriteBoard(String tag) {
    print(_boards.where((element) => element.tag == tag).isEmpty);
    if (_boards.where((element) => element.tag == tag).isEmpty) {
      throw HttpException('Board doesn\'t exist');
    }
    BoardClass board = findBoardByTag(tag);
    if (_favoriteBoards.contains(board)) {
      throw HttpException('The board exists in the favorites');
    }
    _favoriteBoards.add(board);
    HelperFunctions.addFavoritesSharedPreference(board.tag);
    notifyListeners();
  }

  void deleteFavoriteBoard(BoardClass board) {
    HelperFunctions.deleteFavoritesSharedPreference(board.tag);
    final existingBoardIndex =
        _favoriteBoards.indexWhere((element) => element == board);
    _favoriteBoards.removeAt(existingBoardIndex);
    notifyListeners();
  }

  BoardClass findBoardByTag(String tag) {
    final BoardClass _board = _boards.firstWhere((board) => board.tag == tag);
    return _board;
  }

  String findBoardNameByTag(String tag) {
    final BoardClass _board = _boards.firstWhere((board) => board.tag == tag);
    return _board.title;
  }
}
