// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymovies_app/Database/database_helper.dart';
import 'package:mymovies_app/Models/movies_model.dart';
import 'package:path_provider/path_provider.dart';

class MovieProvider with ChangeNotifier {
  List<MoviesModel> _movies = [];
  List<MoviesModel> _favourites = [];
  bool _isLoading = false;

  List<MoviesModel> get movies => _movies;
  List<MoviesModel> get favourites => _favourites;
  bool get isLoading => _isLoading;

  final DBHelper _dbHelper = DBHelper();

  Future<void> fetchMovies() async {
    const url = 'https://api.sampleapis.com/movies/animation';

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _movies = data.map((movie) => MoviesModel.fromMap(movie)).toList();

        //Cache the movies locally
        await _dbHelper.clearMovies();
        for (var movie in _movies) {
          final localPath = await downloadAndSaveImage(
              movie.posterURL.toString(), movie.id.toString());
          movie.localPosterPath = localPath;
          await _dbHelper.insertMovie(movie);
        }
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      debugPrint('Error fetching movies: $e');
      _movies = await _dbHelper.fetchMovies();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFavourites() async {
    _favourites = await _dbHelper.fetchFavourites();
    notifyListeners();
  }

  void addToFavourites(MoviesModel movie) {
    _favourites.add(movie);
    notifyListeners();
  }

  void removeFromFavourites(MoviesModel movie) {
    _favourites.remove(movie);
    notifyListeners();
  }

  bool isFavourite(MoviesModel movie) {
    return _favourites.any((element) => element.id == movie.id);
  }

  void toggleFavourite(MoviesModel movie, BuildContext context) async {
    if (isFavourite(movie)) {
      await _dbHelper.deleteFavourite(movie.id!.toInt());
      _favourites.remove(movie);
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${movie.title} Removed from favourites"),
      ));
    } else {
      await _dbHelper.insertFavourite(movie);
      _favourites.add(movie);
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${movie.title} Added to favourites"),
      ));
    }
    notifyListeners();
  }

  Future<String> downloadAndSaveImage(String url, String movieId) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$movieId.jpg';
    final response = await http.get(Uri.parse(url));
    final file = File(path);
    await file.writeAsBytes(response.bodyBytes);
    return path;
  }
}
