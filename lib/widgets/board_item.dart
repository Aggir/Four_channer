import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/board_class.dart';
import '../providers/boards.dart';
import '../screens/threads_screen.dart';
import '../widgets/my_snack_bar.dart';

class BoardItem extends StatelessWidget {
  const BoardItem(this._isFavoriteScreen, {Key? key}) : super(key: key);
  final bool _isFavoriteScreen;

  void deleteFunction(BuildContext context, BoardClass board) async {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Delete /${board.tag}/ from favorites?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ],
          );
        }).then((value) {
      if (value == null) {
        return;
      }
      if (value) {
        Provider.of<Boards>(context, listen: false).deleteFavoriteBoard(board);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          mySnackBar('/${board.tag}/ Deleted from favorites'),
        );
      }
    });
  }

  void addFunction(BuildContext context, BoardClass board) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Add /${board.tag}/ to favorites?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'ADD',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ],
          );
        }).then((value) {
      if (value == null) {
        return;
      }
      if (value) {
        Provider.of<Boards>(context, listen: false).addFavoriteBoard(board.tag);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          mySnackBar('/${board.tag}/ Added to favorites'),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final board = Provider.of<BoardClass>(context, listen: false);
    return Container(
      height: 200,
      width: double.infinity,
      child: InkWell(
        onLongPress: () {
          _isFavoriteScreen
              ? deleteFunction(context, board)
              : addFunction(context, board);
        },
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: board.color,
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        '/${board.tag}/',
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          board.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!board.isSafeForWork)
                        Text(
                          'NSFW',
                          style:
                              TextStyle(fontSize: 12, color: Colors.deepOrange),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed(ThreadsScreen.routeName, arguments: board.tag);
        },
      ),
    );
  }
}
