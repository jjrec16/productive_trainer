import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'handlers.dart';

final router = Router()
  ..post('/signup', registerUser)
  ..post('/login', loginUser)
  ..post('/trainings', addTraining)
  ..get('/trainings', getTrainings)
  ..put('/training', updateTraining)
  ..delete('/training', deleteTraining)
  ..get('/user', getUserInfo)
  ..get('/session', getTrainingExercises)
  ..get('/training', getTrainingById)
  ..all('/<ignored|.*>', (Request request) {
    print('❌ Route not found: ${request.method} ${request.url}');
    return Response.notFound('Route not found');
  });

final handler = Pipeline()
    .addMiddleware(_corsMiddleware()) // CORS jako pierwsze
    .addMiddleware(logRequests())     // Logowanie żądań
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
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        });
      }
      try {
        final response = await innerHandler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          ...response.headers,
        });
      } catch (e, stackTrace) {
        print('⚠️ Błąd podczas obsługi żądania: $e');
        print(stackTrace);
        return Response.internalServerError(body: 'Internal Server Error');
      }
    };
  };
}
