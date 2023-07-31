
// ignore_for_file: unnecessary_new

import 'package:lecho/src/channel/channel.dart';
import 'package:lecho/src/util/event_formatter.dart';

///
/// This class represents a Socket.io channel.
///
class SocketIoChannel extends Channel {
  /// The Socket.io client instance.
  dynamic socket;

  /// The name of the channel.
  late String name;

  /// Channel options.
  late Map<String, dynamic> options;

  /// The event formatter.
  late EventFormatter eventFormatter;

  /// The event callbacks applied to the socket.
  Map<String, dynamic> events = {};

  /// User supplied callbacks for events on this channel
  Map<String, List> _listeners = {};

  /// Create a new class instance.
  SocketIoChannel(dynamic socket, String name, Map<String, dynamic> options) {
    this.name = name;
    this.socket = socket;
    this.options = options;
    eventFormatter = new EventFormatter(this.options['namespace']);

    subscribe();
  }

  /// Subscribe to a Socket.io channel.
  void subscribe() {
    socket.emit('subscribe', {
      'channel': name,
      'auth': options['auth'] ?? {},
    });
  }

  /// Unsubscribe from channel and ubind event callbacks.
  void unsubscribe() {
    unbind();

    socket.emit('unsubscribe', {
      'channel': name,
      'auth': options['auth'] ?? {},
    });
  }

  /// Listen for an event on the channel instance.
  SocketIoChannel listen(String event, Function callback) {
    on(eventFormatter.format(event), callback);

    return this;
  }

  /// Stop listening for an event on the channel instance.
  @override
  SocketIoChannel stopListening(String event, [Function? callback]) {
    _unbindEvent(eventFormatter.format(event), callback);

    return this;
  }

  /// Register a callback to be called anytime a subscription succeeds.
  SocketIoChannel subscribed(Function callback) {
    on('connect', (socket) => callback(socket));

    return this;
  }

  /// Register a callback to be called anytime an error occurs.
  SocketIoChannel error(Function callback) {
    return this;
  }

  /// Bind the channel's socket to an event and store the callback.
  SocketIoChannel on(String event, Function callback) {
    _listeners[event] = _listeners[event] ?? [];

    if (events[event] == null) {
      events[event] = (props) {
        String channel = props[0];
        dynamic data = props[1];
        if (name == channel && _listeners[event]!.isNotEmpty) {
          _listeners[event]!.forEach((cb) => cb(data));
        }
      };

      socket.on(event, events[event]);
    }

    _listeners[event]?.add(callback);

    return this;
  }

  /// Unbind the channel's socket from all stored event callbacks.
  void unbind() {
    List.from(events.keys).forEach((event) => _unbindEvent(event));
  }

  /// Unbind the listeners for the given event.
  void _unbindEvent(String event, [Function? callback]) {
    _listeners[event] = _listeners[event] ?? [];

    if (callback != null) {
      _listeners[event] =
          _listeners[event]!.where((cb) => cb != callback).toList();
    }

    if (callback == null || _listeners[event]!.isEmpty) {
      if (events[event] != null) {
        socket.off(event, events[event]);

        events.remove(event);
      }

      _listeners.remove(event);
    }
  }
}
