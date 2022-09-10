import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../models/duration_filters.dart';

@immutable
abstract class AlbumsEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class AlbumsFetchRequested extends AlbumsEvent{}

class AlbumsFilterChanged extends AlbumsEvent{
  final DurationFilter filter;

  AlbumsFilterChanged({required this.filter});

  @override
  List<Object> get props => [filter];
}