// Dev-only local API that implements the Stashly v1 contract in memory, so
// the app can be run on an emulator before the Laravel backend exists.
//
//   dart run tool/fake_api_server.dart            # http://localhost:8000/api/v1
//   flutter run                                    # emulator → http://10.0.2.2:8000
//
// Demo account (test data only, not a real credential):
//   email: demo@stashly.test   password: stashly-demo-1
import 'dart:io';

import 'fake_backend/fake_backend.dart';

const demoEmail = 'demo@stashly.test';
const demoPassword = 'stashly-demo-1';

Future<void> main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8000;
  final backend = FakeStashlyBackend(
    readsUntilMetadataReady: 2,
    googleEnabled: Platform.environment['GOOGLE_ENABLED'] == '1',
    metadataResolver: _demoMetadata,
  );
  _seed(backend);

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln(
    'Stashly fake API on http://localhost:$port/api/v1 (demo: $demoEmail)',
  );
  await for (final request in server) {
    final body = await request
        .cast<List<int>>()
        .transform(const SystemEncoding().decoder)
        .join();
    final path = request.uri.path;
    if (!path.startsWith('/api/v1')) {
      request.response
        ..statusCode = 404
        ..close();
      continue;
    }
    final headers = <String, String>{};
    request.headers.forEach(
      (name, values) => headers[name.toLowerCase()] = values.join(','),
    );
    final response = backend.handle(
      FakeRequest(
        method: request.method,
        path: path.substring('/api/v1'.length),
        query: request.uri.queryParameters,
        headers: headers,
        body: body,
      ),
    );
    stdout.writeln('${request.method} $path -> ${response.status}');
    request.response.statusCode = response.status;
    request.response.headers.contentType = ContentType.json;
    response.headers.forEach(request.response.headers.set);
    request.response.write(response.body);
    await request.response.close();
  }
}

void _seed(FakeStashlyBackend backend) {
  final token = backend.seedUser(
    name: 'Maya Kim',
    email: demoEmail,
    password: demoPassword,
    createdAt: DateTime.utc(2025, 10, 2),
  );
  final travel = backend.seedCollection(
    token,
    'Travel ideas',
    description: 'Places, maps and itineraries',
  );
  final inspiration = backend.seedCollection(
    token,
    'Inspiration',
    description: 'Spaces and objects worth remembering',
  );
  final learning = backend.seedCollection(
    token,
    'Learning',
    description: 'Courses, explainers, and references',
  );
  final recipes = backend.seedCollection(
    token,
    'Weeknight recipes',
    description: 'Reliable meals to make again',
  );
  final now = DateTime.now().toUtc();
  backend
    ..seedLink(
      token,
      'https://www.youtube.com/watch?v=dolomites',
      title: 'A cinematic guide to the Italian Dolomites',
      note: 'Revisit when planning the autumn trip.',
      favorite: true,
      collectionIds: [travel, inspiration],
      tags: ['travel', 'italy', 'film'],
      createdAt: now.subtract(const Duration(hours: 2)),
    )
    ..seedLink(
      token,
      'https://design-milk.com/the-quiet-spaces-shaping-modern-interiors',
      collectionIds: [inspiration],
      tags: ['interiors', 'design'],
      createdAt: now.subtract(const Duration(days: 1)),
    )
    ..seedLink(
      token,
      'https://www.feastingathome.com/miso-roasted-vegetable-bowl',
      title: 'Miso-roasted vegetable bowl with sesame dressing',
      collectionIds: [recipes],
      tags: ['recipe', 'vegetarian'],
      createdAt: now.subtract(const Duration(days: 34)),
    )
    ..seedLink(
      token,
      'https://uxdesign.cc/a-practical-introduction-to-design-tokens',
      favorite: true,
      collectionIds: [learning],
      tags: ['design-systems', 'learning'],
      createdAt: now.subtract(const Duration(days: 37)),
    )
    ..seedLink(
      token,
      'https://notebook.community/understanding-retrieval-augmented-generation',
      collectionIds: [learning],
      tags: ['ai'],
      createdAt: now.subtract(const Duration(days: 44)),
      metadataReady: false,
    );
}

/// Realistic preview data for the demo links; the app only ever stores the
/// external image URL (CLAUDE.md §6).
Map<String, Object?> _demoMetadata(String url) {
  const images = {
    'dolomites':
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
    'quiet-spaces':
        'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=800',
    'miso':
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
  };
  final key = images.keys.where(url.contains).firstOrNull;
  final host = Uri.parse(url).host.replaceFirst('www.', '');
  final slug =
      Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).lastOrNull ?? host;
  final words = slug.replaceAll(RegExp(r'[-_]+'), ' ');
  return {
    'status': 'ready',
    'title': '${words[0].toUpperCase()}${words.substring(1)}',
    'description': key == 'dolomites'
        ? 'A slow cinematic journey through mountain passes, alpine lakes, and quiet villages in Northern Italy.'
        : 'Saved from $host.',
    'site_name': host,
    'favicon_url': null,
    'preview_image_url': key == null ? null : images[key],
  };
}
