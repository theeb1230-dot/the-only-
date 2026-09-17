import '../domain/models.dart';

abstract interface class StreamResolver {
  String get id;

  bool supports(Uri uri);

  Future<List<StreamSource>> resolve(Uri uri);
}
