import 'package:flutter/material.dart';
import 'package:four_channer/providers/thread_class.dart';
import 'package:provider/provider.dart';

import '../providers/threads.dart';
import '../providers/boards.dart';
import '../widgets/threads_item.dart';
import '../widgets/my_snack_bar.dart';
import '../widgets/appbar_popUp_button.dart';

enum appBarPopupMenuValue {
  top,
  addFavorites,
  refresh,
  sort,
  bottom,
}

class ThreadsScreen extends StatefulWidget {
  const ThreadsScreen({Key? key}) : super(key: key);
  static const String routeName = '/threads';

  @override
  State<ThreadsScreen> createState() => _ThreadsScreenState();
}

class _ThreadsScreenState extends State<ThreadsScreen> {
  bool _isInit = true;
  bool _loading = false;
  String boardTag = '';
  List<ThreadClass> _threadsData = [];
  final ScrollController _gridScrollController = ScrollController();

  @override
  void dispose() {
    _gridScrollController.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      boardTag = ModalRoute.of(context)?.settings.arguments as String;
      _isInit = false;
      _refreshThreads();
    }
  }

  Future<void> _refreshThreads() async {
    setState(() {
      _loading = true;
    });
    try {
      await Provider.of<Threads>(context, listen: false)
          .fetchAndSetThreads(boardTag);
      fetchError = false;
    } catch (error) {
      fetchError = true;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(mySnackBar(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _addFavoriteBoard() {
    final _boards = Provider.of<Boards>(context, listen: false);
    try {
      _boards.addFavoriteBoard(boardTag);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        mySnackBar('Board /$boardTag/ added'),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        mySnackBar(error.toString()),
      );
    }
  }

  int _selectedOrder = 1;

  void _selectOrderFunction() async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Choose Order'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                RadioListTile(
                    title: const Text('Bump order'),
                    value: 1,
                    groupValue: _selectedOrder,
                    onChanged: (int? value) {
                      if (value != null) Navigator.of(context).pop(value);
                    }),
                RadioListTile(
                    title: const Text('Reply count'),
                    value: 2,
                    groupValue: _selectedOrder,
                    onChanged: (int? value) {
                      if (value != null) Navigator.of(context).pop(value);
                    }),
                RadioListTile(
                    title: const Text('Image count'),
                    value: 3,
                    groupValue: _selectedOrder,
                    onChanged: (int? value) {
                      if (value != null) Navigator.of(context).pop(value);
                    }),
                RadioListTile(
                    title: const Text('Creation date'),
                    value: 4,
                    groupValue: _selectedOrder,
                    onChanged: (int? value) {
                      if (value != null) Navigator.of(context).pop(value);
                    }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'CANCEL',
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null)
        setState(() {
          _selectedOrder = value;
        });
    });
  }

  void _orderType() {
    if (_selectedOrder == 1) {
      _threadsData
          .sort((a, b) => b.lastReplyTimestamp.compareTo(a.lastReplyTimestamp));
    }
    if (_selectedOrder == 2) {
      _threadsData.sort((a, b) => b.replies.compareTo(a.replies));
    }
    if (_selectedOrder == 3) {
      _threadsData.sort((a, b) => b.images.compareTo(a.images));
    }
    if (_selectedOrder == 4) {
      _threadsData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  void _appBarPopupMenu(appBarPopupMenuValue value) {
    switch (value) {
      case appBarPopupMenuValue.top:
        _gridScrollController.animateTo(
            _gridScrollController.position.minScrollExtent,
            duration: Duration(seconds: 1, milliseconds: 500),
            curve: Curves.fastOutSlowIn);
        break;
      case appBarPopupMenuValue.addFavorites:
        _addFavoriteBoard();
        break;
      case appBarPopupMenuValue.refresh:
        _refreshThreads();
        break;
      case appBarPopupMenuValue.sort:
        _selectOrderFunction();
        break;
      case appBarPopupMenuValue.bottom:
        _gridScrollController.animateTo(
            _gridScrollController.position.maxScrollExtent,
            duration: Duration(seconds: 2),
            curve: Curves.fastOutSlowIn);
        break;
    }
  }

  bool _isSearchOpen = false;
  TextEditingController _searchFieldController = TextEditingController();
  List<ThreadClass> _searchedThreadsData = [];

  void _onChangeSearchField() {
    String? text = _searchFieldController.text;
    if (text.isEmpty || text == '') {
      setState(() {
        _searchedThreadsData = _threadsData;
      });
    } else {
      List<ThreadClass> temp = [];
      for (var thread in _threadsData) {
        if (thread.title.toUpperCase().contains(text.toUpperCase()) ||
            thread.filteredDescription
                .toUpperCase()
                .contains(text.toUpperCase())) {
          temp.add(thread);
        }
      }
      setState(() {
        _searchedThreadsData = temp;
      });
    }
  }

  bool setSearchedDataForTheFirstBuild = true;
  bool fetchError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<Boards>(context, listen: false)
            .findBoardNameByTag(boardTag)),
        actions: [
          if (_isSearchOpen)
            Flexible(
              child: Container(
                child: TextField(
                  cursorColor: Colors.red,
                  controller: _searchFieldController,
                  onChanged: (text) {
                    _onChangeSearchField();
                  },
                  autofocus: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                width: 200,
                margin: EdgeInsets.all(0),
              ),
            ),
          IconButton(
              onPressed: () {
                if (_searchFieldController.text.isEmpty ||
                    _searchFieldController.text == '') {
                  setState(() {
                    _isSearchOpen = !_isSearchOpen;
                  });
                } else {
                  setState(() {
                    _searchFieldController.clear();
                    _onChangeSearchField();
                  });
                }
              },
              icon: _isSearchOpen ? Icon(Icons.close) : Icon(Icons.search)),
          AppBarPopupButton(
              appBarPopupMenu: _appBarPopupMenu, popupItems: popupItems),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : fetchError
              ? Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.primary,
                      size: 48,
                    ),
                    tooltip: 'Refresh',
                    onPressed: () {
                      _refreshThreads();
                    },
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () {
                    return _refreshThreads();
                  },
                  child: Consumer<Threads>(
                      builder: (ctx, originalThreadsData, child) {
                    _threadsData = originalThreadsData.threads;
                    _orderType();

                    if (_threadsData.isNotEmpty) {
                      if (setSearchedDataForTheFirstBuild) {
                        _searchedThreadsData = _threadsData;
                        setSearchedDataForTheFirstBuild = false;
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        controller: _gridScrollController,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 170,
                          childAspectRatio: 0.52,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                        ),
                        itemBuilder: (ctx, index) {
                          return ChangeNotifierProvider.value(
                            value: _isSearchOpen
                                ? _searchedThreadsData[index]
                                : _threadsData[index],
                            child: ThreadsItem(),
                          );
                        },
                        itemCount: _isSearchOpen
                            ? _searchedThreadsData.length
                            : _threadsData.length,
                      ),
                    );
                  }),
                ),
    );
  }

  List<PopupMenuItem> popupItems = [
    PopupMenuItem(
      value: appBarPopupMenuValue.top,
      child: Row(
        children: [
          Icon(Icons.keyboard_arrow_up_outlined),
          SizedBox(
            width: 10,
          ),
          Text(
            'Go to Top',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: appBarPopupMenuValue.addFavorites,
      child: Row(
        children: [
          Icon(Icons.favorite),
          SizedBox(
            width: 10,
          ),
          Text(
            'Add to favorites',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: appBarPopupMenuValue.refresh,
      child: Row(
        children: [
          Icon(Icons.refresh),
          SizedBox(
            width: 10,
          ),
          Text(
            'Refresh',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: appBarPopupMenuValue.sort,
      child: Row(
        children: [
          Icon(Icons.sort),
          SizedBox(
            width: 10,
          ),
          Text(
            'Sort Order',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: appBarPopupMenuValue.bottom,
      child: Row(
        children: [
          Icon(Icons.keyboard_arrow_down_outlined),
          SizedBox(
            width: 10,
          ),
          Text(
            'Go to Bottom',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  ];
}
