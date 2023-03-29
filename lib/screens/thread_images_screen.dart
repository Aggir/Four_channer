import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/thread_class.dart';
import '../providers/thread_posts.dart';
import '../widgets/images_grid_item.dart';
import '../widgets/my_snack_bar.dart';

class ThreadImagesScreen extends StatefulWidget {
  const ThreadImagesScreen({Key? key}) : super(key: key);
  static const String routeName = '/thread-images';

  @override
  State<ThreadImagesScreen> createState() => _ThreadImagesScreenState();
}

class _ThreadImagesScreenState extends State<ThreadImagesScreen> {
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

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }

  Future clearCache() async {
    if (_posts != null)
      for (var post in _posts) {
        if (post.fileType == '.png' || post.fileType == '.jpg')
          PaintingBinding.instance!.imageCache!.clear();
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

  bool fetchError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${thread.boardTag}/gal/${thread.id} - ${thread.title == '' ? thread.filteredDescription : thread.title}',
            maxLines: 1),
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
                    builder: (ctx, _postsData, child) {
                      List<ThreadClass> temp = [];
                      for (var post in _postsData.threadPosts) {
                        if (post.fileType == '.jpg' ||
                            post.fileType == '.png' ||
                            post.fileType == '.gif' ||
                            post.fileType == '.webm') {
                          temp.add(post);
                        }
                      }
                      List<ThreadClass> postsData = temp;
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 150,
                            childAspectRatio: 0.80,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemBuilder: (cx, index) {
                            return ChangeNotifierProvider.value(
                              value: postsData[index],
                              child: ImagesGridItem(),
                            );
                          },
                          itemCount: postsData.length,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
