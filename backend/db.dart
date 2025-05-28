final conn = await MySqlConnection.connect(ConnectionSettings(
  host: 'sql.freedb.tech',
  port: 3306,
  user: 'freedb_productive_trainer',       // ← Twój login z FreeDB
  password: 'TbZ@CfNgz\$f&9\$D'
',    // ← Twoje hasło
  db: 'productive_trainer',                 // ← dokładna nazwa bazy z FreeDB
));
