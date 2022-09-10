import 'package:equatable/equatable.dart';
import 'package:fresh_music_radar/models/duration_filters.dart';
import 'package:intl/intl.dart';
import 'package:spotify/spotify.dart';

enum AlbumsStatus { initial, loading, success, failure }

class AlbumsState extends Equatable {
  final AlbumsStatus status;
  final List<Album> albums;
  final DurationFilter filter;
  final double percentage;

  AlbumsState({
    this.status = AlbumsStatus.initial,
    this.albums = const [],
    this.filter = DurationFilter.ofMonth1,
    this.percentage = 0,
  });

  final Map<DatePrecision, String> _datePrecisions = {
    DatePrecision.day : "y-M-d",
    DatePrecision.month: "y-M",
    DatePrecision.year: "y",
  };

  List<Album> get filteredAlbums {
    return albums.where((album) {
      var dateTimeThreshold = DateTime.now().subtract(filter.duration);

      String dateFormat = _datePrecisions[album.releaseDatePrecision!]!;

      var releaseDate = DateFormat(dateFormat).parse(album.releaseDate!);

      return releaseDate.compareTo(dateTimeThreshold) >= 0;
    }).toList();
  }

  AlbumsState copyWith({
    AlbumsStatus Function()? status,
    List<Album> Function()? albums,
    DurationFilter Function()? filter,
    double Function()? percentage,
  }) {
    return AlbumsState(
      status: status != null ? status() : this.status,
      albums: albums != null ? albums() : this.albums,
      filter: filter != null ? filter() : this.filter,
      percentage: percentage != null ? percentage() : this.percentage,
    );
  }

  @override
  List<Object> get props => [status, albums.length, filter, percentage];
}
















