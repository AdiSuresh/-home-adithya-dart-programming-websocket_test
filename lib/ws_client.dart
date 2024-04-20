import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:websocket_test/stdin_stream.dart';

void main(
  List<String> args,
) {
  final uri = Uri(
    scheme: 'ws',
    host: '127.0.0.1',
    port: 8080,
  );
  final channel = WebSocketChannel.connect(
    uri,
    protocols: [
      'ws',
    ],
  );
  final messageSub = StdinStreamSub(
    (data) {
      stdout.write(
        'Self: ',
      );
      channel.ready.then(
        (value) {
          channel.sink.add(
            data,
          );
        },
      );
    },
  );
  channel.ready.then(
    (value) {
      print('client ready');
      channel.stream.listen(
        (data) {
          print(
            '\nServer: $data',
          );
          stdout.write(
            'Self: ',
          );
        },
        onDone: () async {
          print(
            'server stopped',
          );
          await messageSub.subscription.cancel();
          await channel.sink.close();
          exit(0);
        },
      );
    },
  );
}
