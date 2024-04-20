import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:websocket_test/stdin_stream.dart';

class ClientHandler {
  final WebSocketChannel channel;

  const ClientHandler({
    required this.channel,
  });
}

void main() {
  var handlers = <ClientHandler>{};
  stdout.write(
    'Self: ',
  );
  final messageSub = StdinStreamSub(
    (data) {
      data = data.trim();
      if (data.isEmpty) {
        return;
      }
      stdout.write(
        'Self: ',
      );
      for (final handler in handlers) {
        handler.channel.ready.then(
          (value) {
            handler.channel.sink.add(
              data,
            );
          },
        );
      }
    },
  );
  final handler = webSocketHandler(
    (WebSocketChannel channel) {
      final h = ClientHandler(
        channel: channel,
      );
      handlers.add(
        h,
      );
      channel.stream.listen(
        (data) {
          print(
            '\nreceived: $data',
          );
          stdout.write(
            'Self: ',
          );
          for (final handler in handlers) {
            if (handler.channel != channel) {
              handler.channel.ready.then(
                (value) {
                  handler.channel.sink.add(
                    data,
                  );
                },
              );
            }
          }
        },
        onDone: () async {
          print(
            'client left',
          );
          handlers.remove(
            h,
          );
          if (handlers.isEmpty) {
            await messageSub.subscription.cancel();
            await channel.sink.close();
            exit(0);
          }
        },
      );
    },
  );
  shelf_io.serve(
    handler,
    'localhost',
    8080,
  );
}
