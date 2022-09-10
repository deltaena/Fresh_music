import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_music_radar/blocs/albums_bloc.dart';

import 'package:fresh_music_radar/blocs/spotify_bloc.dart';
import 'package:fresh_music_radar/services/spotify_service.dart';
import 'package:fresh_music_radar/views/new_albums_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xffbaf2bb),
            onPrimary: Colors.black,
            secondary: Color(0xfff2bac9),
            onSecondary: Colors.black,
            error: Colors.red,
            onError: Colors.yellow,
            background: Color(0xffbaf2d8),
            onBackground: Colors.black,
            surface: Color(0xffbad7f2),
            onSurface: Colors.black
        ),
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            color: Colors.black,
            overflow: TextOverflow.ellipsis,
            fontSize: 16,
          ),
          displaySmall: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(59, 59, 59, 100)
          ),
        )
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SpotifyBloc(SpotifyServiceImpl())),
          BlocProvider(create: (_) => AlbumsBloc(SpotifyServiceImpl())),
        ],
        child: const NewAlbumsView(),
      )
    );
  }
}



















