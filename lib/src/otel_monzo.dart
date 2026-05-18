// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_monzo_suppression.dart';

class MonzoResult {
  const MonzoResult({
    this.userId,
    this.accountId,
    this.potId,
    this.transactionId,
    this.category,
    this.amount,
    this.currency,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? userId;
  final String? accountId;
  final String? potId;
  final String? transactionId;
  final String? category;
  final double? amount;
  final String? currency;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class MonzoCallResult<T> {
  const MonzoCallResult({required this.value, this.result});
  final T value;
  final MonzoResult? result;
}

Future<T> tracedMonzo<T>({
  required String operation,
  required Future<MonzoCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (monzoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_monzo');
  final span = t.startSpan('monzo $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'monzo');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.userId != null) {
        span.setStringAttribute('user.id', res.userId!);
      }
      if (res.accountId != null) {
        span.setStringAttribute('monzo.account.id', res.accountId!);
      }
      if (res.potId != null) {
        span.setStringAttribute('monzo.pot.id', res.potId!);
      }
      if (res.transactionId != null) {
        span.setStringAttribute('monzo.transaction.id', res.transactionId!);
      }
      if (res.category != null) {
        span.setStringAttribute('monzo.transaction.category', res.category!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('monzo.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('monzo.currency', res.currency!);
      }
      if (res.status != null) {
        span.setStringAttribute('monzo.status', res.status!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('monzo.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'monzo.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
