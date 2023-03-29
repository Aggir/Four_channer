import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:gif_view/gif_view.dart';

import '../widgets/chewie_list_item.dart';
import '../models/functions.dart';
import '../widgets/my_snack_bar.dart';
import '../providers/thread_class.dart';
import '../providers/threads.dart';
import '../providers/thread_posts.dart';
import '../widgets/full_screen_image.dart';
import '../screens/thread_screen.dart';

// ignore: must_be_immutable
class PostsItem extends StatefulWidget {
  PostsItem({this.importedThread, Key? key}) : super(key: key);
  ThreadClass? importedThread;

  @override
  State<PostsItem> createState() => _PostsItemState();
}

class _PostsItemState extends State<PostsItem> {
  bool hasImage = false;
  bool _isInit = true;
  var _post;
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;

  Widget showAttachment(ThreadClass post,BoxConstraints c) {
    if (post.fileType == '.png' || post.fileType == '.jpg') {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return FullScreenImage(
                  post: post,
                );
              },
            ),
          );
        },
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            child: Hero(
              tag: post.attachmentUrl,
              child: ImagePixels.container(
                imageProvider: NetworkImage(post.attachmentUrl),
                colorAlignment: Alignment.topCenter,
                child: Container(
                  child: FittedBox(
                    child: CachedNetworkImage(
                      key: UniqueKey(),
                      errorWidget: (ctx, _, __) => Container(
                        height: post.imageHeight.toDouble() * 0.60,
                        width: post.imageWidth.toDouble(),
                        color: Colors.grey,
                      ),
                      imageUrl: post.attachmentUrl,
                      width: constraints.maxWidth,
                      fit: BoxFit.fitWidth,
                      placeholder: (ctx, _) => FittedBox(
                        child: Image.network(
                          post.imageUrlSmall,
                          height: post.imageHeight.toDouble(),
                          width: post.imageWidth.toDouble(),
                          fit: BoxFit.fitWidth,
                          errorBuilder: (ctx, _, __) => Container(
                            height: post.imageHeight.toDouble() * 0.60,
                            width: constraints.maxWidth,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      );
    }
    if (post.fileType == '.webm') {
      return InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChewieListItem(
                chewieController: _chewieController!,
              ),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ImagePixels.container(
              imageProvider: NetworkImage(post.imageUrlSmall),
              colorAlignment: Alignment.topCenter,
              child: Container(
                child: FittedBox(
                  child: Image.network(
                    post.imageUrlSmall,
                    height: post.imageHeight.toDouble() >
                            MediaQuery.of(context).size.height
                        ? post.imageHeight.toDouble() * .9
                        : post.imageHeight.toDouble(),
                    width: post.imageWidth.toDouble(),
                    fit: BoxFit.fitHeight,
                    errorBuilder: (ctx, _, __) => Container(
                      height: post.imageHeight.toDouble() * 0.60,
                      width: post.imageWidth.toDouble(),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Image.asset(
              'assets/images/play.png',
              height: 52,
              width: 52,
            ),
          ],
        ),
      );
    }
    if (post.fileType == '.gif') {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return FullScreenImage(
                  post: post,
                );
              },
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ImagePixels.container(
              imageProvider: NetworkImage(post.imageUrlSmall),
              colorAlignment: Alignment.topCenter,
              child: Container(
                child: FittedBox(
                  child: Image.network(
                    post.imageUrlSmall,
                    height: post.imageHeight.toDouble() >
                        MediaQuery.of(context).size.height
                        ? post.imageHeight.toDouble() * .9
                        : post.imageHeight.toDouble(),
                    width: post.imageWidth.toDouble(),
                    fit: BoxFit.fitHeight,
                    errorBuilder: (ctx, _, __) => Container(
                      height: post.imageHeight.toDouble() * 0.60,
                      width: post.imageWidth.toDouble(),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Text(post.fileType);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      if (widget.importedThread == null) {
        _post = Provider.of<ThreadClass>(context, listen: false);
      } else {
        _post = widget.importedThread;
      }
      if ((_post as ThreadClass).fileType == '.webm') {
        _videoPlayerController =
            VideoPlayerController.network((_post as ThreadClass).attachmentUrl)
              ..setVolume(0);
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          additionalOptions: (context) => [
            OptionItem(
                onTap: () {
                  saveButtonMethod();
                },
                iconData: Icons.download,
                title: 'Save'),
            OptionItem(onTap: () {
              Functions.share(_post.attachmentUrl);
            }, iconData: Icons.share, title: 'Share'),
            OptionItem(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(mySnackBar('Soon!'));
                },
                iconData: Icons.open_in_new,
                title: 'Show message'),
          ],
          // aspectRatio: 16 / 9,
          autoInitialize: true,
          looping: true,
          allowFullScreen: false,
          // fullScreenByDefault: true,
          autoPlay: true,
          startAt: Duration(seconds: 0),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          },
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
  }

  void saveButtonMethod(){
    Functions.saveNetworkVideo(_post.attachmentUrl).then((value){
      if(value == null){
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(mySnackBar('Error'));
      }
      if(value == true){
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(mySnackBar('Image saved'));
      }
      if(value == false){
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(mySnackBar('Couldn\'t save the image'));
      }
    });
  }

  void openPostInDialog(BuildContext context, int id) {
    ThreadClass? thread;
    final posts = Provider.of<ThreadPosts>(context, listen: false).threadPosts;
    for (var post in posts) {
      if (post.id == id) thread = post;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Colors.transparent,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: PostsItem(importedThread: thread),
              )
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0))),
            contentPadding: EdgeInsets.all(0),
          );
        });
  }

  void openPostFromAnotherBoard(
      BuildContext context, String boardTag, int? id) {
    print(boardTag);
    print(id);
  }

  void openPostFromTheSameBoard(BuildContext context, String boardTag, int id) {
    var _threads = Provider.of<Threads>(context, listen: false).threads;
    var _thread;
    for (ThreadClass _tThread in _threads) {
      if (_tThread.id == id) {
        _thread = _tThread;
      }
    }
    if (_thread != null)
      Navigator.of(context)
          .pushNamed(ThreadScreen.routeName, arguments: _thread);
  }

  void clipBoardData(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text)).then(
      (value) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(mySnackBar('Copied!'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // var _post;
    // if (widget.importedThread == null) {
    //   _post = Provider.of<ThreadClass>(context, listen: false);
    // } else {
    //   _post = widget.importedThread;
    // }
    final ThreadClass post = _post!;
    hasImage = (post.fileType == '.png' || post.fileType == '.jpg');
    final bool hasAttachment = post.attachmentUrl != '';
    return LayoutBuilder(
      builder: (context ,c) {
        return Card(
          child: Column(
            children: [
              if (hasAttachment) showAttachment(post,c),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Text(
                            post.name,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          Text(
                            'No. ${post.id}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    ),
                    if (post.title != '')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0, top: 12),
                        child: Text(
                          post.title,
                          style:
                              TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                    if (post.description != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: HtmlWidget(
                          post.description!,
                          textStyle: TextStyle(fontSize: 16),
                          customStylesBuilder: (element) {
                            if (element.classes.contains('deadlink')) {
                              return {
                                'color': 'red',
                                'text-decoration-line': 'line-through'
                              };
                            }
                            if (element.classes.contains('quote')) {
                              return {'color': '#789922'};
                            }
                            return null;
                          },
                          customWidgetBuilder: (element) {
                            if (element.classes.contains('quotelink')) {
                              bool opThread = false;
                              if (post.opId == 0) opThread = true;
                              return GestureDetector(
                                onTap: () {
                                  final text =
                                      element.text.toString().replaceAll('>', '');
                                  int index = text.lastIndexOf('/') + 1;
                                  if (element.text.toString().contains('/')) {
                                    openPostFromAnotherBoard(
                                      context,
                                      Functions.getTextBetween(text, '/', '/'),
                                      int.tryParse(
                                        text.substring(index, text.length),
                                      ),
                                    );
                                  } else {
                                    bool postExistsInTheThread = false;
                                    final posts = Provider.of<ThreadPosts>(context,
                                            listen: false)
                                        .threadPosts;
                                    for (var post in posts) {
                                      if (post.id == int.parse(text)) {
                                        postExistsInTheThread = true;
                                      }
                                    }
                                    if (postExistsInTheThread) {
                                      openPostInDialog(context, int.parse(text));
                                    } else {
                                      openPostFromTheSameBoard(
                                          context, post.boardTag, int.parse(text));
                                    }
                                  }
                                },
                                child: Text(
                                  opThread
                                      ? '${element.text.toString()}'
                                      : element.text
                                              .toString()
                                              .contains(post.opId.toString())
                                          ? '${element.text.toString()} (OP)'
                                          : '${element.text.toString()}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    if (hasAttachment)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '${post.imageWidth}x${post.imageHeight} ~ ${post.fileSize} ~ ${post.fileName}${post.fileType}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    Text(
                      Functions.convertFromTimestampToTimeAgo(post.timestamp),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.black12,
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(mySnackBar('Soon!'));
                          },
                          child: Text(
                            'REPLY',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        PopupMenuButton(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 2),
                            child: Text(
                              'MORE',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                                // fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          tooltip: 'Show More Options',
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              child: Text('Copy Text'),
                              value: 0,
                            ),
                            PopupMenuItem(
                              child: Text('Copy Link'),
                              value: 1,
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 0) {
                              clipBoardData(context, post.filteredDescription);
                            } else {
                              if (post.opId != 0) {
                                clipBoardData(context,
                                    'https://boards.4chan.org/${post.boardTag}/thread/${post.opId}#p${post.id}');
                              } else {
                                clipBoardData(context,
                                    'https://boards.4chan.org/${post.boardTag}/thread/${post.id}');
                              }
                            }
                          },
                        )
                      ],
                    ),
                    if (post.replies > 0)
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          post.replies > 1
                              ? '${post.replies} REPLIES'
                              : '${post.replies} REPLY',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                        ),
                      )
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }
}
