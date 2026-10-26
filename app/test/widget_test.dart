import 'package:flutter_test/flutter_test.dart';
import 'package:silaisetu/core/config/brand.dart';

void main() {
  test('brand name is SilaiSetu', () {
    expect(Brand.name, 'SilaiSetu');
  });
}
