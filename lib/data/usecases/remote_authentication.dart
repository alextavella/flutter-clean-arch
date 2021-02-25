import '../http/http.dart';
import '../../domain/usecases/usecases.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({required this.httpClient, required this.url});

  auth(AuthenticationParams params) async {
    await httpClient.request(
      url: url,
      method: 'get', 
      body: RemoteAuthenticationParams.fromDomain(params).toJson()
    );
  }
}

class RemoteAuthenticationParams {
  final String email;
  final String password;

  RemoteAuthenticationParams({required this.email, required this.password});

  factory RemoteAuthenticationParams.fromDomain(AuthenticationParams params) =>
      RemoteAuthenticationParams(
        email: params.email, 
        password: params.password
      );

  Map toJson() => {'email': email, 'password': password};
}
