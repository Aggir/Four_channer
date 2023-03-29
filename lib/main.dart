import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/favorite_boards_screen.dart';
import './screens/boards_screen.dart';
import './screens/threads_screen.dart';
import './screens/thread_screen.dart';
import './screens/thread_images_screen.dart';
import './providers/boards.dart';
import './providers/threads.dart';
import './providers/thread_posts.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Boards(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Threads(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ThreadPosts(),
        ),
      ],
      child: MaterialApp(
        title: 'Four Channer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white.withOpacity(0.87),
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: Colors.indigo,
                secondary: Colors.indigoAccent,
              ),
          // fontFamily: 'Lato',
        ),
        routes: {
          '/': (ctx) => const FavoriteBoardScreen(),
          BoardsScreen.routeName: (ctx) => const BoardsScreen(),
          ThreadsScreen.routeName: (ctx) => const ThreadsScreen(),
          ThreadScreen.routeName: (ctx) => const ThreadScreen(),
          ThreadImagesScreen.routeName: (ctx) => const ThreadImagesScreen(),
        },

      ),
    );
  }
}
