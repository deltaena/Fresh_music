import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotify/spotify.dart';

import '../../models/duration_filters.dart';

@immutable
abstract class FilteredAlbumsChangeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateFilter extends FilteredAlbumsChangeEvent{
  final DurationFilter filter;

  UpdateFilter({required this.filter});
}

class UpdateTodos extends FilteredAlbumsChangeEvent{
  final List<Album> albums;

  UpdateTodos({required this.albums});
}