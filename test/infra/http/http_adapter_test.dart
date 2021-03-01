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
  late HttpClientSpy httpClient;
  late HttpAdapter sut;
  late String url;

  setUp(() {
    httpClient = HttpClientSpy();
    sut = HttpAdapter(httpClient);
    url = faker.internet.httpUrl();
  });

  mockRequest() => when(httpClient)
      .calls(#post)
      .withArgs(positional: [Uri.parse(url)], named: {#headers: any});

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => Response(data.toString(), 200));
  }

  group('post', () {
    test('should call POST with correct values', () async {
      mockHttpData({});

      await sut.request(url: url, method: 'post');

      verify(httpClient).called(#post).once();
    });

    test('should call POST with correct default headers', () async {
      mockHttpData({});

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
