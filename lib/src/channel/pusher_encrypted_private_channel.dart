

import 'package:lecho/src/channel/pusher_channel.dart';

///
/// This class represents a Pusher private channel.
///
class PusherEncryptedPrivateChannel extends PusherChannel {
  PusherEncryptedPrivateChannel(
    dynamic pusher,
    String name,
    dynamic options,
  ) : super(pusher, name, options);

  /// Trigger client event on the channel.
  PusherEncryptedPrivateChannel whisper(String eventName, dynamic data) {
    this.pusher.channels.channels[this.name].trigger('client-$eventName', data);

    return this;
  }
}
