import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mymovies_app/Models/movies_model.dart';
import 'package:mymovies_app/Screens/favourite_screen.dart';
import 'package:mymovies_app/Screens/movie_details_dailog.dart';
import 'package:mymovies_app/Services/movie_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      movieProvider.fetchMovies();
      movieProvider.fetchFavourites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final filteredMovies = movieProvider.movies
        .where((movie) => movie.title
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies Browser'),
        backgroundColor: Colors.purple.shade100,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavouritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(6),
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search movies...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          movieProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: filteredMovies.isEmpty
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
                                'No movies found',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: filteredMovies.length,
                          itemBuilder: (context, index) {
                            final movie = filteredMovies[index];
                            return GestureDetector(
                              onTap: () => showMovieDialog(context, movie),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(12)),
                                          child: Image(
                                            image: _getImageProvider(movie),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.broken_image),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            movie.title.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'IMDb: ${movie.imdbId}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                                icon: Icon(
                                                  movieProvider
                                                          .isFavourite(movie)
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: movieProvider
                                                          .isFavourite(movie)
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    movieProvider
                                                        .toggleFavourite(
                                                            movie, context);
                                                  });
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(MoviesModel movie) {
    try {
      if (movie.localPosterPath != null && movie.localPosterPath!.isNotEmpty) {
        final file = File(movie.localPosterPath!);
        if (file.existsSync()) {
          return FileImage(file);
        }
      }
      return NetworkImage(movie.posterURL.toString());
    } catch (e) {
      debugPrint('Error loading image: $e');
      return const AssetImage('assets/logo.png');
    }
  }
}
