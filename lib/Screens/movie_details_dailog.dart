import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mymovies_app/Models/movies_model.dart';

void showMovieDialog(BuildContext context, MoviesModel movie) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Image(
              image: _getImageProvider(movie),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            )),
            const SizedBox(height: 16),
            Text(
              'Title: ${movie.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('IMDb: ${movie.imdbId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
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
