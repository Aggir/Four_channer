import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../widgets/chewie_list_item.dart';
import '../providers/thread_class.dart';
import '../widgets/full_screen_image.dart';

class ImagesGridItem extends StatefulWidget {
  const ImagesGridItem({Key? key}) : super(key: key);

  @override
  State<ImagesGridItem> createState() => _ImagesGridItemState();
}

class _ImagesGridItemState extends State<ImagesGridItem> {
  bool _isInit = true;
  var _post;
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(_isInit) {
      _isInit = false;
      _post = Provider.of<ThreadClass>(context, listen: false);
      if ((_post as ThreadClass).fileType == '.webm') {
        _videoPlayerController =
            VideoPlayerController.network((_post as ThreadClass).attachmentUrl)
              ..setVolume(0);
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
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

  @override
  Widget build(BuildContext context) {
    ThreadClass post = Provider.of<ThreadClass>(context, listen: false);

    return InkWell(
      onTap: (){
        if(post.fileType == '.jpg' || post.fileType == '.png'){
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
        }
        if(post.fileType == '.gif'){
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
        }
        if(post.fileType == '.webm'){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChewieListItem(
                chewieController: _chewieController!,
              ),
            ),
          );
        }
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            child: Hero(
              tag: post.attachmentUrl,
              child: Image.network(
                post.imageUrlSmall,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (post.fileType == '.gif' || post.fileType == '.webm')
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                post.fileType.substring(1),
                style: TextStyle(
                  color: Colors.white, shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.5, 1.5),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
