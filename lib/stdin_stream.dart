import 'dart:async';
import 'dart:convert';
import 'dart:io';

class StdinStreamSub {
  final StreamSubscription<String> subscription;

  StdinStreamSub(
    void Function(String) onData,
  ) : subscription = stdin
            .transform(
              utf8.decoder,
            )
            .transform(
              const LineSplitter(),
            )
            .asBroadcastStream()
            .listen(
              onData,
            );
}
