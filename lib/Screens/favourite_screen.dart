import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mymovies_app/Models/movies_model.dart';
import 'package:mymovies_app/Screens/home_screen.dart';
import 'package:mymovies_app/Services/movie_provider.dart';
import 'package:provider/provider.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final favourites = movieProvider.favourites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Movies'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: favourites.isEmpty
          ? const Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.grey,
                    size: 120,
                  ),
                  Text(
                    'No favourites added yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favourites.length,
              itemBuilder: (context, index) {
                final movie = favourites[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image(
                          image: _getImageProvider(movie),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        )),
                    title: Text(
                      movie.title.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('IMDb: ${movie.imdbId}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () =>
                          movieProvider.toggleFavourite(movie, context),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
          child: const Icon(Icons.add)),
    );
  }

  ImageProvider _getImageProvider(MoviesModel movie) {
    if (movie.localPosterPath != null && movie.localPosterPath!.isNotEmpty) {
      final file = File(movie.localPosterPath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return NetworkImage(movie.posterURL.toString());
  }
}
