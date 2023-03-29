import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/boards.dart';
import '../widgets/app_drawer.dart';
import '../widgets/board_item.dart';

class BoardsScreen extends StatefulWidget {
  const BoardsScreen({Key? key}) : super(key: key);
  static const String routeName = '/boards';

  @override
  State<BoardsScreen> createState() => _BoardsScreenState();
}

class _BoardsScreenState extends State<BoardsScreen> {
  void refresh(){
    Provider.of<Boards>(context, listen: false)
        .fetchAndSetBoards(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text('Boards List'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            refresh();
          });
        },
        child: Consumer<Boards>(builder: (ctx, boardsData, child) {
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
                  value: boardsData.boards[index],
                  child: const BoardItem(false),
                );
              },
              itemCount: boardsData.boards.length,
            ),
          );
        }),
      ),
    );
  }
}
