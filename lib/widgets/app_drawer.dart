import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../screens/boards_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  void initMyLibrary() {
    LicenseRegistry.reset();
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(<String>['Test'], '''
      هذا البرنامج تم كتابته لغرض تعليمي فقط وهو نسخة من تطبيق\n
      4Channer                    
  ''');
    });
  }

  @override
  void initState() {
    super.initState();
    this.initMyLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: buildDrawerIcon(Icons.bookmarks),
                title: buildDrawerText('Favorite Boards'),
                onTap: () {
                  if (ModalRoute.of(context)!.settings.name != '/') {
                    Navigator.of(context).pushReplacementNamed('/');
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: buildDrawerIcon(Icons.dashboard),
                title: buildDrawerText('Boards List'),
                onTap: () {
                  if (ModalRoute.of(context)!.settings.name !=
                      BoardsScreen.routeName) {
                    Navigator.of(context)
                        .pushReplacementNamed(BoardsScreen.routeName);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: buildDrawerIcon(Icons.info),
                title: buildDrawerText('About'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationIcon: Image.asset(
                      'assets/images/logo.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    applicationName: '4Chan',
                    applicationVersion: '0.0.1',
                    children: [
                      Text(
                        '.تم كتابة هذا التطبيق للتدريب و التعلم فقط وهو نسخة من برنامج اخر ولكن مع بعض الاضافات الشخصية',
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Text buildDrawerText(String text) => Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 24),
      );

  Icon buildDrawerIcon(IconData icon) => Icon(
        icon,
        color: Colors.white,
        size: 26,
      );
}
