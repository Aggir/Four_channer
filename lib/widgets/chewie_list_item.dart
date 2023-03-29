import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class ChewieListItem extends StatefulWidget {
  const ChewieListItem({required this.chewieController, Key? key})
      : super(key: key);
  final ChewieController chewieController;

  @override
  State<ChewieListItem> createState() => _ChewieListItemState();
}

class _ChewieListItemState extends State<ChewieListItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Chewie(controller: widget.chewieController),
          SafeArea(
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 24,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
