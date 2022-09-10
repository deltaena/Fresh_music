import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_music_radar/blocs/albums_bloc.dart';

import 'package:fresh_music_radar/blocs/events/albums_fetch_event.dart';
import 'package:fresh_music_radar/blocs/events/spotify_auth_event.dart';
import 'package:fresh_music_radar/blocs/spotify_bloc.dart';
import 'package:fresh_music_radar/models/duration_filters.dart';
import 'package:fresh_music_radar/states/albums_state.dart';

import 'package:fresh_music_radar/states/spotify_auth_states.dart';

import 'package:spotify/spotify.dart' as spotify;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewAlbumsView extends StatelessWidget{
  const NewAlbumsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Fresh albums"),
          actions: [
            BlocBuilder<SpotifyBloc, SpotifyAuthState>(
              builder: (context, state){
                if(state is SpotifyAuthSuccessful){
                  return PopupMenuButton<DurationFilter>(
                      icon: Image.network("https://pic.onlinewebfonts.com/svg/img_491417.png"),
                      itemBuilder: (BuildContext context) =>
                        <PopupMenuItem<DurationFilter>>[
                          PopupMenuItem<DurationFilter>(
                            value: DurationFilter.ofMonth1,
                            child: Text("Set threshold ${DurationFilter.ofMonth1.name} days ago"),
                          ),
                          PopupMenuItem<DurationFilter>(
                            value: DurationFilter.ofMonth2,
                            child: Text("Set threshold ${DurationFilter.ofMonth2.name} days ago"),
                          ),
                          PopupMenuItem<DurationFilter>(
                            value: DurationFilter.ofMonth3,
                            child: Text("Set threshold ${DurationFilter.ofMonth3.name} days ago"),
                          ),
                       ],
                      onSelected: (filter) {
                        context.read<AlbumsBloc>().add(AlbumsFilterChanged(filter: filter));

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Filter applied! showing albums from the last ${filter.value} days")));
                      },
                  );
                }

                return const SizedBox.shrink();
              }
            ),
          ],
      ),
      body: BlocBuilder<SpotifyBloc, SpotifyAuthState>(
        builder: (context, state){
          if(state is SpotifyAuthNotStarted) {
            context.read<SpotifyBloc>().add(SpotifyAuthorize());
            return spotifyLogoWithText("Initializing...");
          }

          if(state is SpotifyAuthSuccessful) { return getAlbumsBlocBuilder(); }

          if(state is SpotifyAuthFailed) { return getWebView(context, state.authorizationUrl); }

          return const Center(
            child: Text(
              "Something went wrong...",
              style: TextStyle(fontSize: 20),
            ),
          );
        })
      );
  }

  WebView getWebView(BuildContext context, String authorizationUrl){
    return WebView(
      initialUrl: authorizationUrl,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (navReq) {
        if (navReq.url.startsWith('https://www.google.com/')) {
          context.read<SpotifyBloc>().add(SpotifyFirstAuthorization(navReq.url));

          return NavigationDecision.prevent;
        }

        return NavigationDecision.navigate;
      },
    );
  }

  BlocBuilder getAlbumsBlocBuilder(){
    return BlocBuilder<AlbumsBloc, AlbumsState>(
      builder: (BuildContext context, state) {

        if(state.status == AlbumsStatus.initial){
          context.read<AlbumsBloc>().add(AlbumsFetchRequested());
          return spotifyLogoWithText("Initializing...");
        }

        if(state.status == AlbumsStatus.loading){ return showLoader(state.percentage); }

        if(state.status == AlbumsStatus.success){
          var filteredAlbums = state.filteredAlbums;

          return showListView(context, filteredAlbums);
        }

        return const Center(
          child: Text(
            "Something went wrong...",
            style: TextStyle(fontSize: 20),
          ),
        );
      },
    );
  }

  Column showListView(BuildContext context, List<spotify.Album> albums){
    return
      Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 50),
                  child: Divider(color: Theme.of(context).colorScheme.secondary),
                ),
                itemCount: albums.length,
                itemBuilder: (context, int index) => getInkWell(context, albums, index)
            ),
          )
        ],
      );
  }

  InkWell getInkWell(BuildContext context, List<spotify.Album> albums, int index){
    return InkWell(
      onTap: () async =>
      {
        if(!await launchUrl(Uri.parse(albums[index].uri!))) {
          ScaffoldMessenger
              .of(context)
              .showSnackBar(const SnackBar(content: Text("No app can open the selected item")))
        }
      },
      child: getAlbumRow(albums, index),
    );
  }

  Row getAlbumRow(List<spotify.Album> albums, int index){
    var artistsNames = "Unknown";

    var artists = albums[index].artists;

    if(artists != null && artists.isNotEmpty) artistsNames = artists.map((artist) => "${artist.name}").join(", ");

    return Row(
        children: <Widget>[
          getAlbumCoverPadding(albums, index),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      "${albums[index].name}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16)
                  ),
                  Text(
                    artistsNames,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Color.fromRGBO(59, 59, 59, 100)),
                  ),
                  Text(
                    "release date: ${albums[index].releaseDate}",
                    style: const TextStyle(fontSize: 14, color: Color.fromRGBO(59, 59, 59, 100)))
                ],
              ),
            ),
          ),
        ]
    );
  }

  Padding getAlbumCoverPadding(List<spotify.Album> albums, int index){
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
      child: getAlbumCoverImage(albums, index),
    );
  }

  Image getAlbumCoverImage(List<spotify.Album> albums, int index) {
    return Image.network("${albums[index].images?[1].url}", width: 55);
  }

  Widget showLoader(double percentage) {
    var turns = percentage / 10;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${percentage.toStringAsFixed(2)}% fresh albums loaded",
            style: const TextStyle(fontSize: 20),
          ),
          AnimatedRotation(
            turns: turns,
            duration: const Duration(seconds: 1),
            child: spotifyLogo()
          )
        ],
      )
    );
  }

  Widget spotifyLogoWithText(text){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 20),
          ),
          spotifyLogo()
        ],
      ),
    );
  }

  Widget spotifyLogo(){
    return const Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: Image(
              image: AssetImage('assets/images/spotify_icon_green.png')
          ),
        )
    );
  }
}




















