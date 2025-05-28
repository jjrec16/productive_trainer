final conn = await MySqlConnection.connect(ConnectionSettings(
  host: 'sql.freedb.tech',
  port: 3306,
  user: 'trainer_user',       // ← Twój login z FreeDB
  password: 'twoje_haslo',    // ← Twoje hasło
  db: 'productive_trainer',                 // ← dokładna nazwa bazy z FreeDB
));
