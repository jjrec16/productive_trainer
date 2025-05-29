import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'handlers.dart';

const allowedOrigin = 'https://productive-trainer-frontend.onrender.com';

final router = Router()

  // Obsługa preflight CORS
  ..options('/<ignored|.*>', (Request request) {
    return Response.ok('', headers: {
      'Access-Control-Allow-Origin': allowedOrigin,
      'Access-Control-Allow-Methods': 'POST, GET, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      'Access-Control-Allow-Credentials': 'true',
    });
  })

  // Obsługa HEAD, żeby nie było błędów
  ..head('/<ignored|.*>', (Request request) {
    return Response.ok('', headers: {
      'Access-Control-Allow-Origin': allowedOrigin,
      'Access-Control-Allow-Credentials': 'true',
    });
  })

  // Endpointy
  ..post('/signup', registerUser)
  ..post('/login', loginUser)
  ..post('/trainings', addTraining)
  ..get('/trainings', getTrainings)
  ..put('/training', updateTraining)
  ..delete('/training', deleteTraining)
  ..get('/user', getUserInfo)
  ..get('/session', getTrainingExercises)
  ..get('/training', getTrainingById)

  // Not found
  ..all('/<ignored|.*>', (Request request) {
    print('❌ Route not found: ${request.method} ${request.url}');
    return Response.notFound(jsonEncode({'error': 'Route not found'}), headers: {'Content-Type': 'application/json'});
  });

final handler = Pipeline()
    .addMiddleware(_corsMiddleware())
    .addMiddleware(logRequests())
    .addHandler(router);

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Serwer działa na http://localhost:$port');
}

Middleware _corsMiddleware() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': allowedOrigin,
          'Access-Control-Allow-Methods': 'POST, GET, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
          'Access-Control-Allow-Credentials': 'true',
        });
      }

      final response = await innerHandler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': allowedOrigin,
        'Access-Control-Allow-Credentials': 'true',
        ...response.headers,
      });
    };
  };
}
