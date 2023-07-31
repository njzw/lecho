

import 'package:lecho/src/channel/socketio_channel.dart';
import 'package:lecho/src/channel/socketio_presence_channel.dart';
import 'package:lecho/src/channel/socketio_private_channel.dart';
import 'package:lecho/src/connector/connector.dart';

///
/// This class creates a connnector to a Socket.io server.
///
class SocketIoConnector extends Connector {
  /// The Socket.io connection instance.
  dynamic socket;

  /// All of the subscribed channel names.
  Map<String, SocketIoChannel> channels = {};

  SocketIoConnector(Map<String, dynamic> options) : super(options);

  /// Create a fresh Socket.io connection.
  @override
  void connect() {
    socket = options['client'];
    socket.connect();

    socket.on('reconnect', (_) {
      channels.values.forEach((channel) => channel.subscribe());
    });
  }

  /// Listen for an event on a channel instance.
  SocketIoChannel listen(String name, String event, Function callback) {
    return channel(name).listen(event, callback);
  }

  /// Get a channel instance by name.
  @override
  SocketIoChannel channel(String name) {
    if (channels[name] == null) {
      channels[name] =
          SocketIoChannel(socket, name, options);
    }

    return channels[name] as SocketIoChannel;
  }

  /// Get a private channel instance by name.
  @override
  SocketIoPrivateChannel privateChannel(String name) {
    if (channels['private-$name'] == null) {
      channels['private-$name'] = SocketIoPrivateChannel(
        socket,
        'private-$name',
        options,
      );
    }

    return channels['private-$name'] as SocketIoPrivateChannel;
  }

  /// Get a presence channel instance by name.
  @override
  SocketIoPresenceChannel presenceChannel(String name) {
    if (channels['presence-$name'] == null) {
      channels['presence-$name'] = SocketIoPresenceChannel(
        socket,
        'presence-$name',
        options,
      );
    }

    return channels['presence-$name'] as SocketIoPresenceChannel;
  }

  /// Leave the given channel, as well as its private and presence variants.
  @override
  void leave(String name) {
    List<String> channels = [name, 'private-$name', 'presence-$name'];

    channels.forEach((name) => leaveChannel(name));
  }

  /// Leave the given channel.
  @override
  void leaveChannel(String name) {
    if (channels[name] != null) {
      channels[name]!.unsubscribe();
      channels.remove(name);
    }
  }

  /// Get the socket ID for the connection.
  @override
  String? socketId() {
    return socket.id;
  }

  /// Disconnect Socketio connection.
  @override
  void disconnect() {
    socket.disconnect();
  }
}
