void main() async {
  try {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'sql.freedb.tech',
      port: 3306,
      user: 'freedb_productive_trainer',
      password: r'TbZ@CfNgz$f&9$D',
      db: 'productive_trainer',
    ));
    print('✅ Połączono z bazą danych!');
    await conn.close();
  } catch (e) {
    print('❌ Błąd połączenia z bazą: $e');
  }
}
