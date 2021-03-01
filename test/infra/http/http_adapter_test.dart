import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class HttpClientSpy extends Mock implements Client {}

class HttpAdapter {
  final Client client;

  HttpAdapter(this.client);

  Future<void> request(
      {required String url, required String method, Map? body}) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json'
    };
    await this.client.post(Uri.parse(url), headers: headers);
  }
}

void main() {
  group('post', () {
    test('should call POST with correct values', () async {
      final httpClient = HttpClientSpy();
      final sut = HttpAdapter(httpClient);
      final url = faker.internet.httpUrl();

      when(httpClient).calls(#post)
        .withArgs(positional: [Uri.parse(url)], named: {#headers: any})
        .thenAnswer((_) async => Response('', 200));

      await sut.request(url: url, method: 'post');

      verify(httpClient).called(#post).once();
    });

    test('should call POST with correct default headers', () async {
      final httpClient = HttpClientSpy();
      final sut = HttpAdapter(httpClient);
      final url = faker.internet.httpUrl();

      when(httpClient).calls(#post)
        .withArgs(positional: [Uri.parse(url)], named: {#headers: any})
        .thenAnswer((_) async => Response('', 200));

      await sut.request(url: url, method: 'post');

      verify(httpClient).called(#post).withArgs(named: {
        #url: url,
        #headers: {
          'content-type': 'application/json',
          'accept': 'application/json'
        }
      });
    });
  });
}
