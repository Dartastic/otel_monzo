# otel_monzo

Dartastic OpenTelemetry bridge for Monzo (UK challenger bank).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_monzo/otel_monzo.dart';

await tracedMonzo<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return MonzoCallResult(value: r, result: MonzoResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutMonzoInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
