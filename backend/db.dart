import 'package:mysql1/mysql1.dart';

Future<MySqlConnection> getConnection() {
  final settings = ConnectionSettings(
    host: 'sql.freedb.tech',
    port: 3306,
    user: 'freedb_productive_trainer',
    password: r'TbZ@CfNgz$f&9$D',
    db: 'productive_trainer',
  );

  return MySqlConnection.connect(settings);
}

// Opcjonalnie możesz zachować funkcję main do testów lokalnych:
void main() async {
  try {
    final conn = await getConnection();
    print('✅ Połączono z bazą danych!');
    await conn.close();
  } catch (e) {
    print('❌ Błąd połączenia z bazą: $e');
  }
}
