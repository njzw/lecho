import 'package:lecho/lecho.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

const String BEARER_TOKEN = 'YOUR_BEARER_TOKEN_HERE';

Lecho initSocketIOClient() {
  IO.Socket socket = IO.io(
    'http://localhost:6002',
    IO.OptionBuilder()
        .disableAutoConnect()
        .setTransports(['websocket']).build(),
  );

  Lecho echo = new Lecho(
    broadcaster: EchoBroadcasterType.SocketIO,
    client: socket,
    options: {
      'auth': {
        'headers': {
          'Authorization': 'Bearer $BEARER_TOKEN',
        }
      },
    },
  );

  return echo;
}
