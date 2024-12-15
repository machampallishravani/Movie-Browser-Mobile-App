class MoviesModel {
  int? id;
  String? title;
  String? posterURL;
  String? imdbId;
  String? localPosterPath;

  MoviesModel(
      {this.id, this.title, this.posterURL, this.imdbId, this.localPosterPath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterURL': posterURL,
      'imdbId': imdbId,
      'localPosterPath': localPosterPath,
    };
  }

  factory MoviesModel.fromMap(Map<String, dynamic> map) {
    return MoviesModel(
      id: map['id'],
      title: map['title'],
      posterURL: map['posterURL'],
      imdbId: map['imdbId'],
      localPosterPath: map['localPosterPath'] ?? '',
    );
  }
}
