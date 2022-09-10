import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class ArtistsFetchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ArtistsFetch extends ArtistsFetchEvent {}