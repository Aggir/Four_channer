import 'package:flutter/material.dart';
import '../providers/thread_class.dart';

// ignore: must_be_immutable
class MyRichText extends StatelessWidget {
  MyRichText(this.thread, {Key? key}) : super(key: key);
  final ThreadClass thread;
  String title = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    title = thread.title;
    description = thread.filteredDescription;
    if (title != '') {
      title = title + '\n';
    }
    return RichText(
      maxLines: 4,
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: DefaultTextStyle.of(context).style.copyWith(color: Colors.black, fontWeight: FontWeight.w900),
          ),
          TextSpan(
            text: description,
            style: DefaultTextStyle.of(context).style.copyWith(color: Colors.black,),
          ),
        ],
      ),
    );

    //
    // return EasyRichText(
    //   text,
    //   patternList: [
    //     EasyRichTextPattern(
    //       targetString: description,
    //       style: TextStyle(fontWeight: FontWeight.w900),
    //     )
    //   ],
    //   maxLines: 4,
    // );
  }
}
