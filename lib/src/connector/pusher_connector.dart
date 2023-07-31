

import 'package:lecho/src/channel/pusher_channel.dart';
import 'package:lecho/src/channel/pusher_encrypted_private_channel.dart';
import 'package:lecho/src/channel/pusher_presence_channel.dart';
import 'package:lecho/src/channel/pusher_private_channel.dart';
import 'package:lecho/src/connector/connector.dart';

///
/// This class creates a null connector.
///
class PusherConnector extends Connector {
  /// The Pusher connection instance.
  dynamic pusher;

  /// All of the subscribed channel names.
  Map<String, PusherChannel> channels = {};

  PusherConnector(Map<String, dynamic> options) : super(options);

  /// Create a fresh Pusher connection.
  @override
  void connect() {
    pusher = options['client'];
    pusher.connect();
  }

  /// Listen for an event on a channel instance.
  PusherChannel listen(String name, String event, Function callback) {
    return channel(name).listen(event, callback);
  }

  /// Get a channel instance by name.
  @override
  PusherChannel channel(String name) {
    if (channels[name] == null) {
      channels[name] = PusherChannel(pusher, name, options);
    }

    return channels[name] as PusherChannel;
  }

  /// Get a private channel instance by name.
  @override
  PusherPrivateChannel privateChannel(String name) {
    if (channels['private-$name'] == null) {
      channels['private-$name'] = PusherPrivateChannel(
        pusher,
        'private-$name',
        options,
      );
    }

    return channels['private-$name'] as PusherPrivateChannel;
  }

  /// Get a private encrypted channel instance by name.
  PusherEncryptedPrivateChannel encryptedPrivateChannel(String name) {
    if (channels['private-encrypted-$name'] == null) {
      channels['private-encrypted-$name'] =
          PusherEncryptedPrivateChannel(
        pusher,
        'private-encrypted-$name',
        options,
      );
    }

    return channels['private-encrypted-$name']
        as PusherEncryptedPrivateChannel;
  }

  /// Get a presence channel instance by name.
  @override
  PusherPresenceChannel presenceChannel(String name) {
    if (channels['presence-$name'] == null) {
      channels['presence-$name'] = PusherPresenceChannel(
        pusher,
        'presence-$name',
        options,
      );
    }

    return channels['presence-$name'] as PusherPresenceChannel;
  }

  /// Leave the given channel, as well as its private and presence variants.
  @override
  void leave(String name) {
    List<String> channels = [name, 'private-$name', 'presence-$name'];

    channels.forEach((String name) => leaveChannel(name));
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
    return pusher.getSocketId();
  }

  /// Disconnect Pusher connection.
  @override
  void disconnect() {
    pusher.disconnect();
  }
}
