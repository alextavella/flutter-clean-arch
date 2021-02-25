import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:cleanarch/domain/helpers/helpers.dart';
import 'package:cleanarch/data/http/http.dart';
import 'package:cleanarch/data/usecases/usecases.dart';
import 'package:cleanarch/domain/usecases/usecases.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late RemoteAuthentication sut;
  late HttpClientSpy httpClient;
  late String url;
  late AuthenticationParams params;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(
        httpClient: httpClient, url: url); // System under test

    params = AuthenticationParams(
        email: faker.internet.email(), password: faker.internet.password());
  });

  test('should call HttpClient with correct values', () async {
    await sut.auth(params);

    verify(httpClient.request(
        url: url,
        method: 'get',
        body: {'email': params.email, 'password': params.password}));
  });

  test('should throw UnexpectedError if HttpClient return 400', () async {
    when(httpClient.request(url: url, method: 'get', body: anyNamed('body')))
      .thenThrow(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 404', () async {
    when(httpClient.request(url: url, method: 'get', body: anyNamed('body')))
      .thenThrow(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 500', () async {
    when(httpClient.request(url: url, method: 'get', body: anyNamed('body')))
      .thenThrow(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}
