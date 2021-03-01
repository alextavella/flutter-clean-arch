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

  mockValidData() =>
      {'accessToken': faker.guid.guid(), 'name': faker.person.name()};

  mockRequest() => when(httpClient)
      .calls(#request)
      .withArgs(named: {#url: url, #method: 'get', #body: any});

  void mockHttpData(Map data) {
    mockRequest().thenAnswer((_) async => data);
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(
        httpClient: httpClient, url: url); // System under test

    params = AuthenticationParams(
        email: faker.internet.email(), password: faker.internet.password());
  });

  test('should call HttpClient with correct values', () async {
    mockHttpData(mockValidData());

    await sut.auth(params);

    verify(httpClient).called(#request).withArgs(named: {
      #url: url,
      #method: 'get',
      #body: {'email': params.email, 'password': params.password}
    });
  });

  test('should throw UnexpectedError if HttpClient return 400', () async {
    mockHttpError(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 404', () async {
    mockHttpError(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 500', () async {
    mockHttpError(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('should throw UnexpectedError if HttpClient return 401', () async {
    mockHttpError(HttpError.unauthorizaed);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.invalidCredentials));
  });

  test('should return Account if HttpClient return 200', () async {
    final validData = mockValidData();
    mockHttpData(validData);

    final account = await sut.auth(params);

    expect(account.token, validData["accessToken"]);
  });

  test(
      'should throw UnexpectedError if HttpClient return 200 with invalid data',
      () async {
    mockHttpData({'invalida_key': 'invalid_value'});

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}
