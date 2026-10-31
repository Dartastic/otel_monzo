// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_monzo/otel_monzo.dart';

/// Traces Monzo calls with OpenTelemetry.
///
/// `otel_monzo` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Monzo call in
/// [tracedMonzo]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'monzo-example');

  // Traces a Monzo call.
  final monzoId = await tracedMonzo<String>(
    operation: 'create',
    invoke: () async {
      // Make the Monzo call here, then report what it returned.
      const id = 'monzo_8f3a2c';
      return const MonzoCallResult(
          value: id,
          result: MonzoResult(
              userId: 'user_8f3a2c',
              accountId: 'account_8f3a2c',
              potId: 'pot_8f3a2c',
              transactionId: 'transaction_8f3a2c',
              category: 'example',
              amount: 0.5,
              currency: 'usd',
              status: 'succeeded',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedMonzo create returned $monzoId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutMonzoInstrumentationAsync.
  await runWithoutMonzoInstrumentationAsync(
    () => tracedMonzo<String>(
      operation: 'create',
      invoke: () async {
        const id = 'monzo_8f3a2c';
        return const MonzoCallResult(
            value: id,
            result: MonzoResult(
                userId: 'user_8f3a2c',
                accountId: 'account_8f3a2c',
                potId: 'pot_8f3a2c',
                transactionId: 'transaction_8f3a2c',
                category: 'example',
                amount: 0.5,
                currency: 'usd',
                status: 'succeeded',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
