import 'package:calories_db_project/psql_connection_holder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    PsqlConnectionHolder.init('postgres', 'qweexrty');
  });

  test('connecting', () async {
    await PsqlConnectionHolder.instance();
  });
}
