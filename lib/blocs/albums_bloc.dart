import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fresh_music_radar/blocs/events/albums_fetch_event.dart';
import 'package:fresh_music_radar/services/spotify_service.dart';
import 'package:fresh_music_radar/states/albums_state.dart';

import 'package:spotify/spotify.dart';

class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState>{
  final SpotifyService _spotifyService;

  AlbumsBloc(this._spotifyService) : super(AlbumsState()){
    on<AlbumsFetchRequested>(_onAlbumsFetchRequested);

    on<AlbumsFilterChanged>((event, emit) {
      emit(state.copyWith(filter: () => event.filter));
    });
  }

  FutureOr<void> _onAlbumsFetchRequested(AlbumsFetchRequested event, Emitter<AlbumsState> emit) async {
    try{
      var albumsStream = await _spotifyService.getFollowingArtistsAlbumsStream();

      await emit.forEach(albumsStream, onData: (event) {
        if(event.item2 == event.item3) {
          var notDuplicatedAlbums = clearDuplicatedAlbums(event.item1);
          var sortedAlbums = sortByDate(notDuplicatedAlbums);

          return state.copyWith(
              status: () => AlbumsStatus.success,
              albums: () => sortedAlbums
          );
        }

        var percentage = (100 * event.item2) / event.item3;

        return state.copyWith(
          status: () => AlbumsStatus.loading,
            percentage: () => percentage
        );
      });
    } on Exception {
      emit(state.copyWith(status: () => AlbumsStatus.failure));
    }
  }

  List<Album> clearDuplicatedAlbums(List<Album> albums){
    List<Album> clearedList = List.empty(growable: true);
    List<String> checkedIds = List.empty(growable: true);

    for (var album in albums) {
      var artistsNames = "";

      if(album.artists == null && album.artists!.isNotEmpty) artistsNames = album.artists!.map((artist) => "${artist.name}").join(", ");

      var albumData = "${album.name} - $artistsNames - ${album.releaseDate}";

      if(album.id != null && !checkedIds.contains(albumData)){
        checkedIds.add(albumData);

        clearedList.add(album);
      }
      else{
        log("checked already album: ${album.name} - ${album.artists?.first.name} with id ${album.id} ${album.availableMarkets.toString()}");
      }
    }

    return clearedList;
  }

  List<Album> sortByDate(List<Album> albums){
    albums.sort((album1, album2) {
      if(album1.releaseDate == null) return -1;
      if(album2.releaseDate == null) return 1;

      return album2.releaseDate!.compareTo(album1.releaseDate!);
    });

    return albums;
  }
}




















