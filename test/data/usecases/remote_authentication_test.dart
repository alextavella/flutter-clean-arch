import 'package:faker/faker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:cleanarch/data/http/http.dart';
import 'package:cleanarch/data/usecases/usecases.dart';
import 'package:cleanarch/domain/usecases/usecases.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late RemoteAuthentication sut;
  late HttpClientSpy httpClient;
  late String url;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(
        httpClient: httpClient, url: url); // System under test
  });

  test('should call HttpClient with correct values', () async {
    final params = AuthenticationParams(
      email: faker.internet.email(), 
      password: faker.internet.password()
    );

    await sut.auth(params);

    verify(
      httpClient.request(
        url: url,
        method: 'get',
        body: {'email': params.email, 'password': params.password}
      )
    );
  });
}
