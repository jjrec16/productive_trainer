final conn = await MySqlConnection.connect(ConnectionSettings(
  host: 'sql.freedb.tech',
  port: 3306,
  user: 'trainer_user', // zmień na swój login
  db: 'productive_trainer',
  password: 'twoje_haslo', // zmień na swoje hasło
));
