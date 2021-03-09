import 'package:cleanarch/data/http/http.dart';
import 'package:cleanarch/infra/http/http.dart';
import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class HttpClientSpy extends Mock implements Client {}

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

  mockRequestWithBody() => when(httpClient).calls(#post).withArgs(
      positional: [Uri.parse(url)], named: {#headers: any, #body: any});

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => Response("$data", 200));
  }

  group('shared', () {
    test('should throw ServerError if invalid method iss provider', () async {
      mockHttpData({});

      final future = sut.request(url: url, method: 'invalid_method');

      expect(future, throwsA(HttpError.serverError));
    });
  });

  group('post', () {
    void mockResponse(int statusCode,
        {String body = '{"any_key": "any_value"}'}) {
      mockRequest().thenAnswer((_) async => Response(body, statusCode));
    }

    void mockError() {
      mockRequest().thenThrow(Exception());
    }

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

    test('should call POST with body', () async {
      mockRequestWithBody().thenAnswer((_) async => Response("{}", 200));

      await sut
          .request(url: url, method: 'post', body: {'any_key': 'any_value'});

      verify(httpClient).called(#post).withArgs(named: {
        #url: url,
        #headers: {
          'content-type': 'application/json',
          'accept': 'application/json'
        },
        #body: "{'any_key': 'any_value'}"
      });
    });

    test('should return data if post returns 200', () async {
      mockResponse(200, body: '{"any_key": "any_value"}');

      final response = await sut.request(url: url, method: 'post');

      expect(response, {"any_key": "any_value"});
    });

    test('should return data if post returns 200 without data', () async {
      mockResponse(200, body: '');

      final response = await sut.request(url: url, method: 'post');

      expect(response, {});
    });

    test('should return data if post returns 204', () async {
      mockResponse(204, body: '');

      final response = await sut.request(url: url, method: 'post');

      expect(response, {});
    });

    test('should return data if post returns 204 with data', () async {
      mockResponse(204);

      final response = await sut.request(url: url, method: 'post');

      expect(response, {});
    });

    test('should return BadRequestError if post returns 400', () async {
      mockResponse(400);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.badRequest));
    });

    test('should return UnauthorizedError if post returns 401', () async {
      mockResponse(401);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.unauthorized));
    });

    test('should return ForbiddenError if post returns 403', () async {
      mockResponse(403);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.forbidden));
    });

    test('should return NotFoundError if post returns 404', () async {
      mockResponse(404);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.notFound));
    });

    test('should return ServerError if post returns 500', () async {
      mockResponse(500);

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.serverError));
    });

    test('should return ServerError if post throws', () async {
      mockError();

      final future = sut.request(url: url, method: 'post');

      expect(future, throwsA(HttpError.serverError));
    });
  });
}
