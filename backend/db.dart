final conn = await MySqlConnection.connect(ConnectionSettings(
  host: 'sql.freedb.tech',
  port: 3306,
  user: 'freedb_productive_trainer',
  password: 'TbZ@CfNgz\$f&9\$D', // ← poprawny string zakończony
  db: 'productive_trainer',
));
