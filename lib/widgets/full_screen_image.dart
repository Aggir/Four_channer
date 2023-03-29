import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gif_view/gif_view.dart';

import '../models/functions.dart';
import '../providers/thread_class.dart';
import '../widgets/my_snack_bar.dart';

class FullScreenImage extends StatefulWidget {
  final ThreadClass post;


  const FullScreenImage({Key? key, required this.post})
      : super(key: key);

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  final _transformationController = TransformationController();
  TapDownDetails _doubleTapDetails = TapDownDetails();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }

  void _appBarPopupMenu(appBarPopupMenuValue value) {
    switch (value) {
      case appBarPopupMenuValue.save:
        // Functions.saveImage(widget.post);
        Functions.saveNetworkImage(widget.post.attachmentUrl).then((value){
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
        break;
      case appBarPopupMenuValue.share:
        Functions.share(widget.post.attachmentUrl);
        break;
      case appBarPopupMenuValue.show_message:
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(mySnackBar('Soon!'));
        break;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Stack(
          children: [
            if(widget.post.fileType != '.gif')
            GestureDetector(
              onDoubleTapDown: _handleDoubleTapDown,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(maxScale: 15,
                transformationController: _transformationController,
                child: Center(
                  child: Hero(
                    tag: widget.post.attachmentUrl,
                    child: CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.contain,
                      imageUrl: widget.post.attachmentUrl,
                    ),
                  ),
                ),
              ),
            ),
            if(widget.post.fileType == '.gif')
              GestureDetector(            onDoubleTapDown: _handleDoubleTapDown,
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  maxScale: 15,
                  child: Center(
                    child: Hero(
                      tag: widget.post.attachmentUrl,
                      child: GifView.network(widget.post.attachmentUrl,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.contain,
                        progress: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
              ),
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: Colors.white,
                    ),
                    tooltip: 'Back',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  PopupMenuButton(
                    color: Colors.grey.shade900,
                    onSelected: (selectedValue) {
                      _appBarPopupMenu(selectedValue as appBarPopupMenuValue);
                    },
                    itemBuilder: (context) => [...popupItems],
                    icon: Icon(Icons.more_vert,color: Colors.white,size: 24,),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  List<PopupMenuItem> popupItems = [
    PopupMenuItem(
      value: appBarPopupMenuValue.save,
      child: Row(
        children: [
          Icon(Icons.download,color: Colors.white,),
          SizedBox(
            width: 10,
          ),
          Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: appBarPopupMenuValue.share,
      child: Row(
        children: [
          Icon(Icons.share,color: Colors.white,),
          SizedBox(
            width: 10,
          ),
          Text(
            'Share',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: appBarPopupMenuValue.show_message,
      child: Row(
        children: [
          Icon(Icons.open_in_new,color: Colors.white,),
          SizedBox(
            width: 10,
          ),
          Text(
            'Show message',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  ];
}
enum appBarPopupMenuValue {
  save,
  share,
  show_message,
}