import 'package:fresh_music_radar/secrets.dart';
import 'package:tuple/tuple.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart';
import 'package:oauth2/oauth2.dart';

abstract class SpotifyService{
  Uri getAuthUri();

  Future<void> initializeWithResponse(String response);
  Future<bool> initializeWithCredentials();

  Future<Iterable<Artist>?> getFollowingArtists();
  Future<Iterable<Album>> getFollowingAlbums(Artist artist);
  Future<Stream<Tuple3<List<Album>, int, int>>> getFollowingArtistsAlbumsStream();
}

class SpotifyServiceImpl extends SpotifyService {
  static final SpotifyServiceImpl _singleton = SpotifyServiceImpl._internal();

  factory SpotifyServiceImpl() {
    return _singleton;
  }

  SpotifyServiceImpl._internal();

  final redirectUri = 'https://open.spotify.com/';
  final scopes = ['user-follow-read'];

  late SpotifyApiCredentials credentials;
  late AuthorizationCodeGrant authorizationCodeGrant;

  late SpotifyApi spotifyApi;

  @override
  Uri getAuthUri(){
    credentials = SpotifyApiCredentials(Secrets.clientId, Secrets.clientSecret);
    authorizationCodeGrant = SpotifyApi.authorizationCodeGrant(credentials);

    return authorizationCodeGrant.getAuthorizationUrl(
      Uri.parse(redirectUri),
      scopes: scopes,
    );
  }

  Future<bool> isAuthorized() async {
    var prefs = await SharedPreferences.getInstance();

    return prefs.getBool("isAuthorized")??false;
  }

  @override
  Future<void> initializeWithResponse(String response) async {
    spotifyApi = SpotifyApi.fromAuthCodeGrant(authorizationCodeGrant, response);

    var credentials = await spotifyApi.getCredentials();
    _saveCredentials(credentials);

    var prefs = await SharedPreferences.getInstance();
    prefs.setBool("isAuthorized", true);
  }
  @override
  Future<bool> initializeWithCredentials() async {
    bool authorized = await isAuthorized();

    if(!authorized) { return false; }

    var credentials = await _getCredentials();
    SpotifyApiCredentials refreshedCredentials;

    try {
      spotifyApi = SpotifyApi(credentials);

      refreshedCredentials = await spotifyApi.getCredentials();

      _saveCredentials(refreshedCredentials);
    } on AuthorizationException {
      return false;
    }

    return true;
  }

  @override
  Future<Iterable<Artist>?> getFollowingArtists() async => await spotifyApi.me.following(FollowingType.artist).all();

  final List<String> _includeGroups = List.from(["album", "single"]);
  final String _country = "ES";
  @override
  Future<Iterable<Album>> getFollowingAlbums(Artist artist) => spotifyApi.artists.albums(artist.id!, country: _country, includeGroups: _includeGroups).all();

  @override
  Future<Stream<Tuple3<List<Album>, int, int>>> getFollowingArtistsAlbumsStream() async{
    var followingArtists = await getFollowingArtists();

    if(followingArtists == null) return const Stream.empty();

    Stream<Tuple3<List<Album>, int, int>> artistAlbumsStream() async*{
      List<Album> albums = List.empty(growable: true);

      int i=0;

      for(var artist in followingArtists){
        await Future.delayed(const Duration(milliseconds: 100));
        var artistAlbums = await getFollowingAlbums(artist);

        albums.addAll(artistAlbums);

        i++;
        yield Tuple3(albums, i, followingArtists.length);
      }
    }

    return artistAlbumsStream();
  }

  Future<void> _saveCredentials(SpotifyApiCredentials credentials) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setString("clientId",  credentials.clientId!);
    prefs.setString("clientSecret", credentials.clientSecret!);
    prefs.setString("accessToken", credentials.accessToken!);
    prefs.setString("refreshToken", credentials.refreshToken!);
    prefs.setStringList("scopes", credentials.scopes!);
    prefs.setString("expiration", credentials.expiration!.toString());
  }
  Future<SpotifyApiCredentials> _getCredentials() async {
    var prefs = await SharedPreferences.getInstance();

    return SpotifyApiCredentials(
      prefs.getString("clientId")!,
      prefs.getString("clientSecret")!,
      accessToken: prefs.getString("accessToken")!,
      refreshToken: prefs.getString("refreshToken")!,
      scopes: prefs.getStringList("scopes")!,
      expiration: DateTime.parse(prefs.getString("expiration")!),
    );
  }
}





















