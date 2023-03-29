import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/board_item.dart';
import '../providers/boards.dart';
import '../widgets/my_snack_bar.dart';
import '../models/http_exception.dart';

class FavoriteBoardScreen extends StatefulWidget {
  const FavoriteBoardScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteBoardScreen> createState() => _FavoriteBoardScreenState();
}

class _FavoriteBoardScreenState extends State<FavoriteBoardScreen> {
  final tagController = TextEditingController();
  bool _isInit = true;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      if (Provider.of<Boards>(context, listen: false).boards.isEmpty) {
        Provider.of<Boards>(context, listen: false)
            .fetchAndSetBoards()
            .then((_) {
          Provider.of<Boards>(context, listen: false).setFavoriteBoards();
        });
      }
    }
  }

  void addFavoriteBoardFunction() async {
    final _boards = Provider.of<Boards>(context, listen: false);
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Add favorite board'),
            content: TextField(
              decoration: InputDecoration(
                hintText: "Board code e.g., lit",
              ),
              controller: tagController,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  tagController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (tagController.text.isEmpty || tagController.text == '') {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop(tagController.text);
                  }
                  tagController.clear();
                },
                child: const Text(
                  'ADD',
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ],
          );
        }).then((tag) {
      if (tag == '' || tag == null) {
        return;
      }
      try {
        _boards.addFavoriteBoard(tag);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          mySnackBar('Board /$tag/ added'),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          mySnackBar(error.toString()),
        );
      }
    });
  }

  void refresh(){
    Provider.of<Boards>(context,listen: false).fetchAndSetBoards(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text('Favorite Boards'),
        actions: [
          IconButton(
            onPressed: addFavoriteBoardFunction,
            icon: Icon(Icons.add),
            tooltip: 'Add to favorites',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ()async {
          setState(() {
            refresh();
          });
        },
        child: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<Boards>(builder: (ctx, boardsData, child) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 170,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (ctx, index) {
                      return ChangeNotifierProvider.value(
                        value: boardsData.favoriteBoards[index],
                        child: BoardItem(
                          true,
                          key: UniqueKey(),
                        ),
                      );
                    },
                    itemCount: boardsData.favoriteBoards.length,
                  ),
                );
              }),
      ),
    );
  }
}
