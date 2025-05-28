import 'package:mysql1/mysql1.dart';

Future<MySqlConnection> getConnection() {
  final settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: '1', // ← twoje nowe hasło
    db: 'b_pt',
  );

  return MySqlConnection.connect(settings);
}
