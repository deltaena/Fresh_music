import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class SpotifyAuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SpotifyAuthorize extends SpotifyAuthEvent {}
class SpotifyFirstAuthorization extends SpotifyAuthEvent {
  final String authorizationUrl;

  SpotifyFirstAuthorization(this.authorizationUrl);
}