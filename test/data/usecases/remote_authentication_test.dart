import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
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
        email: faker.internet.email(),
        password: faker.internet.password());
  });

  test('should call HttpClient with correct values', () async {
    when(httpClient)
      .calls(#request)
      .withArgs(named: {#url: url, #method: 'get', #body: any })
      .thenAnswer((_) async => {
        'accessToken': faker.guid.guid(),
        'name': faker.person.name()
      });

    await sut.auth(params);

    verify(httpClient)
    .called(#request)
    .withArgs(named: {
        #url: url,
        #method: 'get',
        #body: {'email': params.email, 'password': params.password}
    });
  });

  test('should throw UnexpectedError if HttpClient return 400', () async {
    when(httpClient)
      .calls(#request)
      .withArgs(named: {#url: url, #method: 'get', #body: any})
      .thenThrow(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 404', () async {
    when(httpClient)
      .calls(#request)
      .withArgs(named: {#url: url, #method: 'get', #body: any})
      .thenThrow(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 500', () async {
    when(httpClient)
      .calls(#request)
      .withArgs(named: {#url: url, #method: 'get', #body: any})
      .thenThrow(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 401', () async {
    when(httpClient)
      .calls(#request)
      .withArgs(named: {#url: url, #method: 'get', #body: any})
      .thenThrow(HttpError.unauthorizaed);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('should throw Account if HttpClient return 200', () async {
    final accessToken = faker.guid.guid();

    when(httpClient)
      .calls(#request)
      .withArgs(named: {#url: url, #method: 'get', #body: any })
      .thenAnswer((_) async => {
        'accessToken': accessToken,
        'name': faker.person.name()
      });

    final account = await sut.auth(params);

    expect(account.token, accessToken);
  });
}
