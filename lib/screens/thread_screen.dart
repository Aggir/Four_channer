import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/thread_class.dart';
import '../providers/thread_posts.dart';
import '../screens/thread_images_screen.dart';
import '../widgets/posts_item.dart';
import '../widgets/my_snack_bar.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({Key? key}) : super(key: key);
  static const String routeName = '/thread';

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  bool _isInit = true;
  bool _loading = false;
  var _posts;
  ThreadClass thread = ThreadClass(
    id: 0,
    name: '',
    title: '',
    replies: 0,
    images: 0,
    description: '',
    imageUrlSmall: '',
    attachmentUrl: '',
    filteredDescription: '',
    boardTag: '',
    timestamp: 0,
    fileName: '',
    fileType: '',
    imageHeight: 0,
    fileSize: '',
    imageWidth: 0,
    dateAndTime: '',
    opId: 0,
    lastReplyTimestamp: 0,
    postReplies: {},
  );
  ScrollController _listScrollController = ScrollController();

  @override
  void dispose() {
    _listScrollController.dispose();
    clearCache();
    super.dispose();
  }

  Future clearCache() async {
    if (_posts != null)
      for (var post in _posts) {
        if (post.fileType == '.png' || post.fileType == '.jpg'
            // || post.fileType == '.gif'
            ) PaintingBinding.instance!.imageCache!.clear();
        await CachedNetworkImage.evictFromCache(post.attachmentUrl)
            .catchError((onError) {
          print('error');
        });
      }
    // DefaultCacheManager manager = new DefaultCacheManager();
    // manager.emptyCache(); //clears all data in cache.
    // final Directory tempDir = await getTemporaryDirectory();
    // final Directory libCacheDir = new Directory("${tempDir.path}/libCachedImageData");
    // await libCacheDir.delete(recursive: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      thread = ModalRoute.of(context)!.settings.arguments as ThreadClass;

      _isInit = false;
      _refreshThreadPosts();
    }
  }

  Future<void> _refreshThreadPosts() async {
    setState(() {
      _loading = true;
    });
    try {
      await Provider.of<ThreadPosts>(context, listen: false)
          .fetchAndSetThreadPosts(thread.boardTag, thread.id);
      _posts = Provider.of<ThreadPosts>(context, listen: false).threadPosts;
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

  void _appBarPopupMenu(appBarPopupMenuValue value) async {
    switch (value) {
      case appBarPopupMenuValue.top:
        _listScrollController.jumpTo(
          _listScrollController.position.minScrollExtent,
        );
        break;
      case appBarPopupMenuValue.refresh:
        _refreshThreadPosts();
        break;
      case appBarPopupMenuValue.saveThread:
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(mySnackBar('Soon!'));
        break;
      case appBarPopupMenuValue.saveAllPics:
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(mySnackBar('Soon!'));
        break;
      case appBarPopupMenuValue.openInBrowser:
        final url = Uri.parse(
            'https://boards.4chan.org/${thread.boardTag}/thread/${thread.id}');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context)
              .showSnackBar(mySnackBar('Could not launch $url'));
        }
        break;
      case appBarPopupMenuValue.bottom:
        _listScrollController.jumpTo(
          _listScrollController.position.maxScrollExtent,
        );
        break;
    }
  }

  bool fetchError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${thread.boardTag}/${thread.id} - ${thread.title == '' ? thread.filteredDescription : thread.title}',
            maxLines: 1),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(ThreadImagesScreen.routeName, arguments: thread);
            },
            icon: Icon(Icons.photo_library),
          ),
          PopupMenuButton(
            color: Theme.of(context).colorScheme.primary,
            onSelected: (selectedValue) {
              _appBarPopupMenu(selectedValue as appBarPopupMenuValue);
            },
            itemBuilder: (context) => [...popupItems],
            icon: Icon(Icons.more_vert),
          ),
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
                      _refreshThreadPosts();
                    },
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () {
                    return _refreshThreadPosts();
                  },
                  child: Consumer<ThreadPosts>(
                    builder: (ctx, postsData, child) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          controller: _listScrollController,
                          itemBuilder: (cx, index) {
                            return ChangeNotifierProvider.value(
                              value: postsData.threadPosts[index],
                              child: PostsItem(),
                            );
                          },
                          itemCount: postsData.threadPosts.length,
                        ),
                      );
                    },
                  ),
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
      value: appBarPopupMenuValue.saveThread,
      child: Row(
        children: [
          Icon(Icons.favorite),
          SizedBox(
            width: 10,
          ),
          Text(
            'Save Thread',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: appBarPopupMenuValue.saveAllPics,
      child: Row(
        children: [
          Icon(Icons.archive),
          SizedBox(
            width: 10,
          ),
          Text(
            'Save All Pics',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: appBarPopupMenuValue.openInBrowser,
      child: Row(
        children: [
          Icon(Icons.open_in_browser),
          SizedBox(
            width: 10,
          ),
          Text(
            'Open in Browser',
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

enum appBarPopupMenuValue {
  top,
  refresh,
  saveThread,
  saveAllPics,
  openInBrowser,
  bottom,
}
