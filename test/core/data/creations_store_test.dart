import 'dart:convert';

import 'package:easefx_ai/core/data/creations_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('corrupted creation data cannot block app initialization', () async {
    SharedPreferences.setMockInitialValues({
      'creations_data': 'not-valid-json',
    });

    await expectLater(CreationsStore().init(), completes);

    expect(CreationsStore().creations, isEmpty);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('creations_data'), isFalse);
  });

  test('one malformed creation does not discard valid entries', () async {
    SharedPreferences.setMockInitialValues({
      'creations_data': jsonEncode([
        {
          'imageUrl': 'https://example.com/valid.jpg',
          'featureLabel': 'Test',
          'date': '2026-10-11T12:00:00.000',
        },
        {'imageUrl': 12},
      ]),
    });

    await CreationsStore().init();

    expect(CreationsStore().creations, hasLength(1));
    expect(
      CreationsStore().creations.single.imageUrl,
      'https://example.com/valid.jpg',
    );
  });
}
