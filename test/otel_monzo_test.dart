// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_monzo/otel_monzo.dart';
import 'package:test/test.dart';

void main() {
  group('otel_monzo', () {
    test('suppression toggles in zone', () async {
      expect(monzoInstrumentationSuppressed(), isFalse);
      await runWithoutMonzoInstrumentationAsync(() async {
        expect(monzoInstrumentationSuppressed(), isTrue);
      });
      expect(monzoInstrumentationSuppressed(), isFalse);
    });

    test('MonzoResult fields default null', () {
      const r = MonzoResult();
      expect(r.statusCode, isNull);
    });
  });
}
