import 'package:calories_db_project/psql_connection_holder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('connecting', () async {
    await PsqlConnectionHolder.instance();
  });
}
