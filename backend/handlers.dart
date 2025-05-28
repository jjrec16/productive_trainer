import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'db.dart';

Future<Response> registerUser(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);
  final conn = await getConnection();

  try {
    await conn.query(
      'INSERT INTO users (firstname, lastname, email, username, password) VALUES (?, ?, ?, ?, ?)',
      [
        data['firstname'],
        data['lastname'],
        data['email'],
        data['username'],
        data['password'],
      ],
    );
    return Response.ok(jsonEncode({'status': 'success'}));
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  } finally {
    await conn.close();
  }
}

Future<Response> loginUser(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);
  final conn = await getConnection();

  try {
    final results = await conn.query('SELECT * FROM users WHERE username = ?', [data['username']]);
    if (results.isEmpty) return Response.forbidden(jsonEncode({'error': 'User not found'}));

    final user = results.first;
    if (data['password'] == user['password']) {
      return Response.ok(jsonEncode({'status': 'success', 'user_id': user['id']}));
    } else {
      return Response.forbidden(jsonEncode({'error': 'Incorrect password'}));
    }
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  } finally {
    await conn.close();
  }
}

Future<Response> addTraining(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);
  final conn = await getConnection();

  try {
    final result = await conn.query(
      'INSERT INTO trainings (user_id, name, total_time) VALUES (?, ?, ?)',
      [data['user_id'], data['name'], data['total_time']],
    );
    final trainingId = result.insertId;

    final List exercises = data['exercises'];
    for (var exercise in exercises) {
      await conn.query(
        'INSERT INTO exercises (training_id, description, exercise_time, sets) VALUES (?, ?, ?, ?)',
        [trainingId, exercise['description'], exercise['exercise_time'], exercise['sets']],
      );
    }

    return Response.ok(jsonEncode({'status': 'success'}));
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  } finally {
    await conn.close();
  }
}

Future<Response> getTrainings(Request request) async {
  final userId = int.tryParse(request.url.queryParameters['user_id'] ?? '');
  if (userId == null) return Response(400, body: jsonEncode({'error': 'Missing or invalid user_id'}));

  final conn = await getConnection();
  try {
    final results = await conn.query(
      'SELECT id, name, total_time FROM trainings WHERE user_id = ?', [userId]);

    final trainings = results.map((row) => {
      'id': row[0],
      'name': row[1],
      'total_time': row[2],
    }).toList();

    return Response.ok(jsonEncode({'trainings': trainings}));
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  } finally {
    await conn.close();
  }
}
Future<Response> getTrainingExercises(Request request) async {
  final param = request.url.queryParameters['training_id'];
  if (param == null) {
    return Response(400, body: jsonEncode({'error': 'Missing training_id'}));
  }

  final trainingId = int.tryParse(param);
  if (trainingId == null) {
    return Response(400, body: jsonEncode({'error': 'Invalid training_id'}));
  }

  final conn = await getConnection();
  try {
    final results = await conn.query(
      'SELECT description, exercise_time, sets FROM exercises WHERE training_id = ?',
      [trainingId],
    );

    final exercises = results.map((row) => {
      'description': row[0].toString(),
      'exercise_time': row[1],
      'sets': row[2],
    }).toList();

    return Response.ok(jsonEncode({'exercises': exercises}));
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  } finally {
    await conn.close();
  }
}


Future<Response> getUserInfo(Request request) async {
  final userId = int.tryParse(request.url.queryParameters['user_id'] ?? '');
  if (userId == null) return Response(400, body: jsonEncode({'error': 'Invalid user_id'}));

  final conn = await getConnection();
  try {
    final result = await conn.query('SELECT firstname FROM users WHERE id = ?', [userId]);
    if (result.isEmpty) return Response.notFound(jsonEncode({'error': 'User not found'}));

    return Response.ok(jsonEncode({'firstname': result.first[0]}));
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  } finally {
    await conn.close();
  }
}

Future<Response> getTrainingById(Request request) async {
  final idParam = request.url.queryParameters['id'];
  final id = int.tryParse(idParam ?? '');
  if (id == null) {
    return Response(400, body: jsonEncode({'error': 'Invalid training ID'}));
  }

  final conn = await getConnection();
  try {
    final trainings = await conn.query(
      'SELECT id, name, total_time FROM trainings WHERE id = ?', [id]);

    if (trainings.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'Training not found'}));
    }

    final training = trainings.first;

    final exercises = await conn.query(
      'SELECT description, exercise_time, sets FROM exercises WHERE training_id = ?', [id]);

    final exList = exercises.map((row) => {
      'description': row[0]?.toString() ?? '',
      'exercise_time': row[1],
      'sets': row[2]
    }).toList();

    return Response.ok(jsonEncode({
      'id': training[0],
      'name': training[1],
      'total_time': training[2],
      'exercises': exList,
    }));
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  } finally {
    await conn.close();
  }
}


Future<Response> updateTraining(Request request) async {
  final trainingId = int.tryParse(request.url.queryParameters['id'] ?? '');
  if (trainingId == null) return Response(400, body: jsonEncode({'error': 'Invalid ID'}));

  final body = await request.readAsString();
  final data = jsonDecode(body);
  final conn = await getConnection();

  try {
    await conn.query('UPDATE trainings SET name = ?, total_time = ? WHERE id = ?',
      [data['name'], data['total_time'], trainingId]);

    await conn.query('DELETE FROM exercises WHERE training_id = ?', [trainingId]);

    final List exercises = data['exercises'];
    for (var ex in exercises) {
      await conn.query(
        'INSERT INTO exercises (training_id, description, exercise_time, sets) VALUES (?, ?, ?, ?)',
        [trainingId, ex['description'], ex['exercise_time'], ex['sets']],
      );
    }

    return Response.ok(jsonEncode({'status': 'updated'}));
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  } finally {
    await conn.close();
  }
}

Future<Response> deleteTraining(Request request) async {
  final trainingId = int.tryParse(request.url.queryParameters['id'] ?? '');
  if (trainingId == null) return Response(400, body: jsonEncode({'error': 'Invalid ID'}));

  final conn = await getConnection();
  try {
    await conn.query('DELETE FROM exercises WHERE training_id = ?', [trainingId]);
    final result = await conn.query('DELETE FROM trainings WHERE id = ?', [trainingId]);

    if (result.affectedRows == 0) {
      return Response.notFound(jsonEncode({'error': 'Training not found'}));
    }

    return Response.ok(jsonEncode({'status': 'deleted'}));
  } catch (e) {
    return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
  } finally {
    await conn.close();
  }
}