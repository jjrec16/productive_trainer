import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'handlers.dart';

final router = Router()

  // Obsługa zapytań preflight (CORS) i HEAD dla wszystkich tras
  ..options('/<ignored|.*>', (Request request) {
    return Response.ok('', headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, GET, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
    });
  })
  ..head('/<ignored|.*>', (Request request) {
    return Response.ok('', headers: {
      'Access-Control-Allow-Origin': '*',
    });
  })

  // Główne endpointy API
  ..post('/signup', registerUser)
  ..post('/login', loginUser)
  ..post('/trainings', addTraining)
  ..get('/trainings', getTrainings)
  ..put('/training', updateTraining)
  ..delete('/training', deleteTraining)
  ..get('/user', getUserInfo)
  ..get('/session', getTrainingExercises)
  ..get('/training', getTrainingById)

  // Obsługa brakujących tras
  ..all('/<ignored|.*>', (Request request) {
    print('❌ Route not found: ${request.method} ${request.url}');
    return Response.notFound('Route not found');
  });

// Middleware i uruchomienie serwera
final handler = Pipeline()
    .addMiddleware(_corsMiddleware())  // Najpierw CORS
    .addMiddleware(logRequests())      // Potem logowanie
    .addHandler(router);

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Serwer działa na http://localhost:$port');
}

// Middleware CORS dodający nagłówki do każdej odpowiedzi
Middleware _corsMiddleware() {
  return (innerHandler) {
    return (request) async {
      // Obsługa pre-flight OPTIONS
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        });
      }

      // Obsługa pozostałych zapytań z nagłówkami CORS
      final response = await innerHandler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        ...response.headers,
      });
    };
  };
}
