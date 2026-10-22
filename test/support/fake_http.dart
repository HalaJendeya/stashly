import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../tool/fake_backend/fake_backend.dart';

/// An `http.Client` that serves requests from the in-memory [FakeStashlyBackend].
http.Client fakeHttpClient(FakeStashlyBackend backend) {
  return MockClient((request) async {
    final path = request.url.path.replaceFirst('/api/v1', '');
    final response = backend.handle(
      FakeRequest(
        method: request.method,
        path: path,
        query: request.url.queryParameters,
        headers: {
          for (final entry in request.headers.entries)
            entry.key.toLowerCase(): entry.value,
        },
        body: request.body,
      ),
    );
    return http.Response(
      response.body,
      response.status,
      headers: {'content-type': 'application/json', ...response.headers},
    );
  });
}
