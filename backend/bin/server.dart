import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import '../lib/mysql_repository.dart';

void main() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final port = int.parse(env['API_PORT'] ?? '8080');
  final repo = MysqlRepository();
  final router = Router();

  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json',
  };

  router.options(
    '/<ignored|.*>',
    (Request req) => Response.ok('', headers: headers),
  );

  // GET endpoint (fetch rows)
  router.get('/products', (Request req) async {
    try {
      final products = await repo.getProducts();
      return Response.ok(jsonEncode(products), headers: headers);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: headers,
      );
    }
  });

  // POST endpoint (insert to add new row)
  router.post('/products', (Request req) async {
    try {
      final payload =
          jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final id = await repo.insertProduct(
        payload['name'] as String,
        (payload['price'] as num).toDouble(),
        payload['description'] as String,
        payload['quantity'] as int,
      );
      return Response(
        201,
        body: jsonEncode({'id': id, 'message': 'Created successfully'}),
        headers: headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: headers,
      );
    }
  });

  // PUT endpoint (update existing row)
  router.put('/products/<id>', (Request request, String id) async {
    try {
      final body =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      body['id'] = int.parse(id);
      final affected = await repo.updateProduct(body);
      return Response.ok(
        jsonEncode({'affected': affected}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  });

  // DELETE endpoint (delete existing row)
  router.delete('/products/<id>', (Request request, String id) async {
    try {
      final affected = await repo.deleteProduct(int.parse(id));
      return Response.ok(
        jsonEncode({'affected': affected}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  });

  final server = await io.serve(router.call, InternetAddress.anyIPv4, port);
  print('Server listening on http://localhost:${server.port}');
}
