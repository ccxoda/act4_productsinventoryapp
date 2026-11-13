import 'package:dotenv/dotenv.dart';
import 'package:mysql1/mysql1.dart';

final env = DotEnv(includePlatformEnvironment: true)..load();

ConnectionSettings get settings => ConnectionSettings(
  host: env['DB_HOST'] ?? '127.0.0.1',
  port: int.parse(env['DB_PORT'] ?? '3306'),
  user: env['DB_USER'] ?? 'root',
  password: (env['DB_PASS'] ?? '').isEmpty ? null : env['DB_PASS'],
  db: env['DB_NAME'] ?? 'product',
);
