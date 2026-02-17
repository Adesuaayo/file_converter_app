import 'dart:isolate';

/// Utility for running heavy computation in isolates to avoid UI jank.
/// Flutter's compute() is limited to top-level/static functions;
/// this wrapper provides a cleaner API with error handling.
class IsolateUtils {
  IsolateUtils._();

  /// Runs a computation in a separate isolate.
  /// [computation] must be a top-level or static function.
  /// [message] is the input data passed to the computation.
  ///
  /// Returns the result of the computation.
  /// Throws if the isolate encounters an error.
  static Future<R> compute<M, R>(
    R Function(M) computation,
    M message,
  ) async {
    final receivePort = ReceivePort();
    Isolate? isolate;

    try {
      isolate = await Isolate.spawn(
        (SendPort sendPort) {
          try {
            final result = computation(message);
            sendPort.send(_IsolateResult<R>(result: result));
          } catch (e, stackTrace) {
            sendPort.send(
              _IsolateResult<R>(error: e.toString(), stackTrace: stackTrace),
            );
          }
        },
        receivePort.sendPort,
      );

      final response = await receivePort.first as _IsolateResult<R>;
      if (response.error != null) {
        throw Exception(
          'Isolate computation failed: ${response.error}',
        );
      }
      return response.result as R;
    } finally {
      receivePort.close();
      isolate?.kill(priority: Isolate.immediate);
    }
  }

  /// Runs a computation with progress reporting.
  /// [computation] receives a progress callback along with the message.
  /// [onProgress] is called on the main isolate with progress updates (0.0-1.0).
  static Future<R> computeWithProgress<M, R>({
    required _ProgressComputation<M, R> computation,
    required M message,
    required void Function(double progress) onProgress,
  }) async {
    final resultPort = ReceivePort();
    final progressPort = ReceivePort();
    Isolate? isolate;

    try {
      isolate = await Isolate.spawn(
        (List<SendPort> ports) {
          final resultSendPort = ports[0];
          final progressSendPort = ports[1];

          try {
            final result = computation(
              message,
              (progress) => progressSendPort.send(progress),
            );
            resultSendPort.send(_IsolateResult<R>(result: result));
          } catch (e, stackTrace) {
            resultSendPort.send(
              _IsolateResult<R>(error: e.toString(), stackTrace: stackTrace),
            );
          }
        },
        [resultPort.sendPort, progressPort.sendPort],
      );

      // Listen for progress updates
      progressPort.listen((message) {
        if (message is double) {
          onProgress(message);
        }
      });

      final response = await resultPort.first as _IsolateResult<R>;
      if (response.error != null) {
        throw Exception(
          'Isolate computation failed: ${response.error}',
        );
      }
      return response.result as R;
    } finally {
      resultPort.close();
      progressPort.close();
      isolate?.kill(priority: Isolate.immediate);
    }
  }
}

/// Type alias for a computation function that reports progress.
typedef _ProgressComputation<M, R> = R Function(
  M message,
  void Function(double progress) reportProgress,
);

/// Internal class to wrap isolate responses with error handling.
class _IsolateResult<R> {
  _IsolateResult({this.result, this.error, this.stackTrace});
  final R? result;
  final String? error;
  final StackTrace? stackTrace;
}
