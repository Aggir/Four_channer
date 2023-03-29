import 'package:flutter/material.dart';

class AppBarPopupButton extends StatelessWidget {
  const AppBarPopupButton( {required this.appBarPopupMenu,required this.popupItems, Key? key}) : super(key: key);
  final appBarPopupMenu ;
  final List<PopupMenuEntry> popupItems;
  @override
  Widget build(BuildContext context) {
    return           PopupMenuButton(
      color: Theme.of(context).colorScheme.primary,
      onSelected: (selectedValue) {
        appBarPopupMenu(selectedValue);
      },
      itemBuilder: (context) => [...popupItems],
      icon: Icon(Icons.more_vert),
    );
  }

}