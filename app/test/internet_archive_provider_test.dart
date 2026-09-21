import 'package:flutter_test/flutter_test.dart';
import 'package:the_only/core/providers/internet_archive_provider.dart';

void main() {
  test('search keeps only openly licensed movie results', () async {
    late Uri requested;
    final provider = InternetArchiveProvider(fetchJson: (uri) async {
      requested = uri;
      return {
        'response': {
          'docs': [
            {
              'identifier': 'open-film',
              'title': 'Open Film',
              'description': 'A Creative Commons movie',
              'year': '2014',
              'licenseurl': 'https://creativecommons.org/licenses/by/4.0/',
            },
            {
              'identifier': 'unknown-rights',
              'title': 'Unknown Rights',
              'licenseurl': 'https://example.com/terms',
            },
          ],
        },
      };
    });

    final results = await provider.search('open film');

    expect(requested.host, 'archive.org');
    expect(requested.path, '/advancedsearch.php');
    expect(requested.queryParameters['q'], contains('mediatype:movies'));
    expect(results, hasLength(1));
    expect(results.single.id, 'open-film');
    expect(results.single.title, 'Open Film');
    expect(results.single.year, 2014);
    expect(results.single.posterUrl, contains('/services/img/open-film'));
  });

  test('sources expose direct MP4 only after license re-check', () async {
    final provider = InternetArchiveProvider(fetchJson: (uri) async {
      expect(uri.path, '/metadata/open-film');
      return {
        'metadata': {
          'licenseurl': 'https://creativecommons.org/publicdomain/mark/1.0/',
        },
        'files': [
          {'name': 'movie_1080p.mp4', 'format': 'MPEG4'},
          {'name': 'poster.jpg', 'format': 'JPEG'},
          {'name': 'movie.webm', 'format': 'WebM'},
        ],
      };
    });

    final items = await InternetArchiveProvider(
      fetchJson: (_) async => {
        'response': {
          'docs': [
            {
              'identifier': 'open-film',
              'title': 'Open Film',
              'licenseurl': 'https://creativecommons.org/licenses/by/4.0/',
            }
          ],
        },
      },
    ).search('open film');

    final result = await provider.sourcesFor(items.single);
    expect(result.providerId, 'internet-archive-open');
    expect(result.sources, hasLength(1));
    expect(result.sources.single.uri.toString(),
        'https://archive.org/download/open-film/movie_1080p.mp4');
    expect(result.sources.single.quality, '1080p');
  });

  test('sources fail closed when item license is not open', () async {
    final provider = InternetArchiveProvider(fetchJson: (_) async => {
      'metadata': {'licenseurl': 'https://example.com/terms'},
      'files': [
        {'name': 'movie.mp4', 'format': 'MPEG4'},
      ],
    });

    final item = (await InternetArchiveProvider(fetchJson: (_) async => {
      'response': {
        'docs': [
          {
            'identifier': 'open-film',
            'title': 'Open Film',
            'licenseurl': 'https://creativecommons.org/licenses/by/4.0/',
          }
        ],
      },
    }).search('open')).single;

    final result = await provider.sourcesFor(item);
    expect(result.sources, isEmpty);
  });
}
