import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_music_radar/blocs/events/spotify_auth_event.dart';

import 'package:fresh_music_radar/services/spotify_service.dart';
import 'package:fresh_music_radar/states/spotify_auth_states.dart';

class SpotifyBloc extends Bloc<SpotifyAuthEvent, SpotifyAuthState>{
  final SpotifyService _spotifyRepository;

  SpotifyBloc(this._spotifyRepository) : super(SpotifyAuthNotStarted()){
    on<SpotifyAuthorize>((event, emit) async {
      var initialized = await _spotifyRepository.initializeWithCredentials();

      if(initialized) { emit(SpotifyAuthSuccessful()); }
      else {
        var errorMessage = "Can't authorize use with existing credentials";
        emit(SpotifyAuthFailed(message: errorMessage, authorizationUrl: _spotifyRepository.getAuthUri().toString())); }
    });

    on<SpotifyFirstAuthorization>((event, emit) async {
      await _spotifyRepository.initializeWithResponse(event.authorizationUrl);
      emit(SpotifyAuthSuccessful());
    });
  }
}