import 'package:equatable/equatable.dart';

abstract class SpotifyAuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class SpotifyAuthNotStarted extends SpotifyAuthState {}

class SpotifyAuthSuccessful extends SpotifyAuthState {}

class SpotifyAuthFailed extends SpotifyAuthState {
  final String message;
  final String authorizationUrl;

  SpotifyAuthFailed({required this.message, required this.authorizationUrl});
}