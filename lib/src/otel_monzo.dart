// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_monzo_suppression.dart';

class MonzoResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class MonzoCallResult<T> {
  /// Creates a call result.
  const MonzoCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final MonzoResult? result;
}

Future<T> tracedMonzo<T>({
  required String operation,
  required Future<MonzoCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (monzoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_monzo');
  final span = t.startSpan('monzo $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'monzo')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.userId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('user.id', res.userId!)]));
      }
      if (res.accountId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('monzo.account.id', res.accountId!)]));
      }
      if (res.potId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('monzo.pot.id', res.potId!)]));
      }
      if (res.transactionId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('monzo.transaction.id', res.transactionId!)
        ]));
      }
      if (res.category != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('monzo.transaction.category', res.category!)
        ]));
      }
      if (res.amount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('monzo.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('monzo.currency', res.currency!)]));
      }
      if (res.status != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('monzo.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('monzo.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'monzo.error',
          )
        ]));
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
