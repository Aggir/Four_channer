import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_rich_text.dart';

import '../screens/thread_screen.dart';
import '../screens/thread_images_screen.dart';
import '../providers/thread_class.dart';
import '../providers/threads.dart';
import './my_snack_bar.dart';

class ThreadsItem extends StatefulWidget {
  const ThreadsItem({Key? key}) : super(key: key);

  @override
  State<ThreadsItem> createState() => _ThreadsItemState();
}

class _ThreadsItemState extends State<ThreadsItem> {
  bool _isLoading = false;
  bool _dead = false;

  @override
  Widget build(BuildContext context) {
    final thread = Provider.of<ThreadClass>(context, listen: false);
    _dead = thread.dead;
    return LayoutBuilder(builder: (ctx, constraint) {
      return IgnorePointer(
        ignoring: _dead,
        child: InkWell(
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            bool isThreadStillAlive = true;
            try{
              isThreadStillAlive = await Provider.of<Threads>(context, listen: false)
                  .isThreadStillAlive(thread);
            }catch(error){
            }
            if (isThreadStillAlive) {
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context)
                  .pushNamed(ThreadScreen.routeName, arguments: thread);
            } else {
              setState(() {
                _isLoading = false;
                Provider.of<ThreadClass>(context, listen: false).threadIsDead();
                _dead = true;
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context)
                  .showSnackBar(mySnackBar('Thread is dead'));
            }
          },
          onLongPress: () async {
            setState(() {
              _isLoading = true;
            });
            bool isThreadStillAlive = true;
            try{
              isThreadStillAlive = await Provider.of<Threads>(context, listen: false)
                  .isThreadStillAlive(thread);
            }catch(error){
            }
            if (isThreadStillAlive) {
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context)
                  .pushNamed(ThreadImagesScreen.routeName, arguments: thread);
            } else {
              setState(() {
                _isLoading = false;
                Provider.of<ThreadClass>(context, listen: false).threadIsDead();
                _dead = true;
              });

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context)
                  .showSnackBar(mySnackBar('Thread is dead'));
            }
          },
          child: Hero(
            tag: thread.id,
            child: Card(
              elevation: 4.0,
              child: Container(
                foregroundDecoration: _dead
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.black45,
                        backgroundBlendMode: BlendMode.darken)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: constraint.maxHeight * 0.12,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      color: Theme.of(context).colorScheme.primary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                            child: Text(
                              '${thread.replies}r',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          if (_isLoading)
                            FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          FittedBox(
                            child: Text(
                              '${thread.images}i',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: constraint.maxHeight * 0.50,
                      width: double.infinity,
                      child: thread.imageUrlSmall == ''
                          ? Image.asset(
                              'assets/images/no-image.png',
                              color: Colors.grey,
                            )
                          : Image.network(
                              thread.imageUrlSmall,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: MyRichText(thread),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
