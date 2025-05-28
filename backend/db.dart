final conn = await MySqlConnection.connect(ConnectionSettings(
  host: 'sql.freedb.tech',
  port: 3306,
  user: 'freedb_productive_trainer',
  password: r'TbZ@CfNgz$f&9$D',  // ← RAW STRING: nie musisz uciekać znaków
  db: 'productive_trainer',
));
