import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

// Dummy user data (database ki jagah)
final users = [
  {"email": "test@gmail.com", "password": "123456"}
];

class AuthController {
  Router get router {
    final router = Router();

    // Login API
    router.post('/login', (Request request) async {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      String email = data['email'];
      String password = data['password'];

      var user = users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        return Response.ok(
          jsonEncode({
            "status": true,
            "message": "Login Success",
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response(401,
            body: jsonEncode({
              "status": false,
              "message": "Invalid Credentials"
            }),
            headers: {'Content-Type': 'application/json'});
      }
    });

    return router;
  }
}

void main() async {
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(AuthController().router);

  var port = int.parse(Platform.environment['PORT'] ?? '8080');

  final server = await io.serve(handler, '0.0.0.0', port);
  print('Server running on port ${server.port}');
}