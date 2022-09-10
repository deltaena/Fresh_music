import 'dart:convert';

import 'package:spotify/spotify.dart';

abstract class BaseTransformer {
  String encodeList(List<dynamic>? list);
  List<dynamic> decodeList(String encodedList);

  List<Map<String, dynamic>> mapList(List<dynamic> list);
  List<dynamic> unmapList(List<Map<String, dynamic>> mappedList);

  String encodeSingle(dynamic object) {
    if(object == null) return "";

    return jsonEncode(object);
  }
  Map<String, dynamic> decodeSingle(String encodedObject) {
    if(encodedObject == "") return {};

    return jsonDecode(encodedObject);
  }
}

abstract class BasicTransformer extends BaseTransformer{
  @override
  List decodeList(String encodedList) {
    List<String> listOfString = jsonDecode(encodedList);

    return List.generate(listOfString.length, (index) => unmapSingle(jsonDecode(listOfString[index])));
  }

  @override
  String encodeList(List? list) {
    if(list == null) return "";

    List<String> listOfString = List.generate(list.length, (index) => jsonEncode(mapSingle(list[index])));

    return jsonEncode(listOfString);
  }

  @override
  List<Map<String, dynamic>> mapList(List list) {
    return List.generate(list.length, (index) => mapSingle(list[index]));
  }

  @override
  List unmapList(List<Map<String, dynamic>> mappedList) => List.generate(mappedList.length, (index) => unmapSingle(mappedList[index]));

  dynamic unmapSingle(Map<String, dynamic> mappedObject);
  Map<String, dynamic> mapSingle(dynamic object);
}

class ArtistTransformer extends BasicTransformer {

  ExternalUrlsTransformer externalUrlsTransformer = ExternalUrlsTransformer();
  ImageTransformer imageTransformer = ImageTransformer();

  @override
  Map<String, dynamic> mapSingle(object){
    var artist = object as Artist;

    return {
      'id' : artist.id,
      'external_urls' : externalUrlsTransformer.encodeSingle(artist.externalUrls),
      'href' : artist.href,
      'name' : artist.name,
      'type' : artist.type,
      'uri' : artist.uri,
      'followers' : jsonEncode({ "href" : artist.followers?.href, "total" : artist.followers?.total }),
      'genres' : jsonEncode(artist.genres),
      'images' : imageTransformer.encodeList(artist.images),
      'popularity' : artist.popularity
    };
  }

  @override
  Artist unmapSingle(Map<String, dynamic> mappedObject){
    var artistJson =  {
      'id' : mappedObject['id'],
      'external_urls' : externalUrlsTransformer.decodeSingle(mappedObject['external_urls']),
      'href' : mappedObject['href'],
      'name' : mappedObject['name'],
      'type' : mappedObject['type'],
      'uri' : mappedObject['uri'],
      'followers' : jsonDecode(mappedObject['followers']),
      'genres' : jsonDecode(mappedObject['genres']),
      'images' : imageTransformer.decodeList(mappedObject['images']),
      'popularity' : mappedObject['popularity']
    };

    return Artist.fromJson(artistJson);
  }
}

class AlbumTransformer extends BasicTransformer{

  ExternalUrlsTransformer externalUrlsTransformer = ExternalUrlsTransformer();
  ImageTransformer imageTransformer = ImageTransformer();
  ExternalIdsTransformer externalIdsTransformer = ExternalIdsTransformer();
  ArtistSimpleTransformer artistSimpleTransformer = ArtistSimpleTransformer();

  @override
  Map<String, dynamic> mapSingle(object) {
    var album = object as Album;

    return {
      "id" : album.id,
      "external_ids" : externalIdsTransformer.encodeSingle(album.externalIds),
      "genres" : jsonEncode(album.genres),
      "label" : album.label,
      "album_type" : album.albumType,
      "artists" : artistSimpleTransformer.encodeList(album.artists),
      "available_markets" : jsonEncode(album.availableMarkets),
      "external_urls" : externalUrlsTransformer.encodeSingle(album.externalUrls?.spotify),
      "href" : album.href,
      "images" : imageTransformer.encodeList(album.images),
      "name" : album.name,
      "release_date" : album.releaseDate,
      "release_date_precision" : album.releaseDatePrecision.toString(),
      "type" : album.type,
      "uri" : album.uri,
      "tracks" : album.tracks,
    };
  }

  @override
  Album unmapSingle(Map<String, dynamic> mappedObject) {
    var albumJson = {
      "id" : mappedObject["id"],
      "external_ids" : externalIdsTransformer.decodeSingle(mappedObject["external_ids"]),
      "genres" : jsonDecode(mappedObject["genres"]),
      "label" : mappedObject["label"],
      "album_type" : mappedObject["album_type"],
      "artists" : artistSimpleTransformer.decodeList(mappedObject["artists"]),
      "available_markets" : jsonDecode(mappedObject["available_markets"]),
      "external_urls" : externalUrlsTransformer.decodeSingle(mappedObject["external_urls"]),
      "href" : mappedObject["href"],
      "images" : imageTransformer.decodeList(mappedObject["images"]),
      "name" : mappedObject["name"],
      "release_date" : mappedObject["releaseDate"],
      "release_date_precision" : mappedObject["releaseDatePrecision"],
      "type" : mappedObject["type"],
      "uri" : mappedObject["uri"],
      "tracks" : mappedObject["tracks"],
    };

    return Album.fromJson(albumJson);
  }
}

class ImageTransformer extends BasicTransformer{
  @override
  Map<String, dynamic> mapSingle(object) {
    var image = object as Image;

    return {
      "url" : image.url,
      "width" : image.width,
      "height" : image.height,
    };
  }

  @override
  unmapSingle(Map<String, dynamic> mappedObject) {
    Image.fromJson(mappedObject);
  }
}

class ArtistSimpleTransformer extends BasicTransformer{
  ExternalUrlsTransformer externalUrlsTransformer = ExternalUrlsTransformer();

  @override
  Map<String, dynamic> mapSingle(object) {
    var artist = object as ArtistSimple;

    return {
      "id" : artist.id,
      "href" : artist.href,
      "type" : artist.type,
      "name" : artist.name,
      "external_urls" : externalUrlsTransformer.encodeSingle(externalUrlsTransformer.mapSingle(artist.externalUrls)),
      "uri" : artist.uri,
    };
  }

  @override
  ArtistSimple unmapSingle(Map<String, dynamic> mappedObject) {
    var artistJson = {
      "id" : mappedObject["id"],
      "href" : mappedObject["href"],
      "type" : mappedObject["type"],
      "name" : mappedObject["name"],
      "external_urls" : externalUrlsTransformer.decodeSingle(mappedObject["external_urls"]),
      "uri" : mappedObject["uri"],
    };

    return ArtistSimple.fromJson(artistJson);
  }

}

class TrackTransformer extends BasicTransformer {
  ExternalUrlsTransformer externalUrlsTransformer = ExternalUrlsTransformer();
  ArtistTransformer artistTransformer = ArtistTransformer();
  ExternalIdsTransformer externalIdsTransformer = ExternalIdsTransformer();

  @override
  Map<String, dynamic> mapSingle(object) {
    var track = object as Track;

    return {
      "uri" : track.uri,
      "type" : track.type,
      "name" : track.name,
      "href" : track.href,
      "external_urls" : externalUrlsTransformer.encodeSingle(track.externalUrls),
      "available_markets" : jsonEncode(track.availableMarkets),
      "artists" : artistTransformer.encodeList(track.artists),
      "id" : track.id,
      "album" : track.album,
      "external_ids" : externalIdsTransformer.encodeSingle(track.externalIds),
      "popularity" : track.popularity,
      "discNumber" : track.discNumber,
      "durationMs" : track.durationMs,
      "explicit" : track.explicit,
      "isPlayable" : track.isPlayable,
      "linkedFrom" : track.linkedFrom,
      "previewUrl" : track.previewUrl,
      "trackNumber" : track.trackNumber,
    };
  }

  @override
  Track unmapSingle(Map<String, dynamic> mappedObject) {
    var trackJson = {
      "uri" : mappedObject["uri"],
      "type" : mappedObject["type"],
      "name" : mappedObject["name"],
      "href" : mappedObject["href"],
      "external_urls" : externalUrlsTransformer.decodeSingle(mappedObject["externalUrls"]),
      "available_markets" : jsonDecode(mappedObject["availableMarkets"]),
      "artists" : artistTransformer.encodeList(mappedObject["artists"]),
      "id" : mappedObject["id"],
      "album" : mappedObject["album"],
      "external_ids" : externalIdsTransformer.decodeSingle(mappedObject["externalIds"]),
      "popularity" : mappedObject["popularity"],
      "discNumber" : mappedObject["discNumber"],
      "durationMs" : mappedObject["durationMs"],
      "explicit" : mappedObject["explicit"],
      "isPlayable" : mappedObject["isPlayable"],
      "linkedFrom" : mappedObject["linkedFrom"],
      "previewUrl" : mappedObject["previewUrl"],
      "trackNumber" : mappedObject["trackNumber"],
    };

    return Track.fromJson(trackJson);
  }
}

class ExternalUrlsTransformer extends BasicTransformer{
  @override
  Map<String, dynamic> mapSingle(object) {
    var externalUrls = object as ExternalUrls;

    return {
      "spotify" : externalUrls.spotify
    };
  }

  @override
  ExternalUrls unmapSingle(Map<String, dynamic> mappedObject) => ExternalUrls.fromJson(mappedObject);
}

class ExternalIdsTransformer extends BasicTransformer{
  @override
  Map<String, dynamic> mapSingle(object) {
    var externalIds = object as ExternalIds;

    return {
      "ean" : externalIds.ean,
      "isrc" : externalIds.isrc,
      "upc" : externalIds.upc
    };
  }

  @override
  unmapSingle(Map<String, dynamic> mappedObject) => ExternalIds.fromJson(mappedObject);
}

class Transformers {
  ArtistTransformer ofArtist = ArtistTransformer();
  AlbumTransformer ofAlbum = AlbumTransformer();
  ImageTransformer ofImage = ImageTransformer();
  ArtistSimpleTransformer ofArtistSimple = ArtistSimpleTransformer();
  TrackTransformer ofTrack = TrackTransformer();

  ExternalUrlsTransformer ofExternalUrls = ExternalUrlsTransformer();
  ExternalIdsTransformer ofExternalIds = ExternalIdsTransformer();
}






















