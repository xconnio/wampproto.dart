import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";
import "package:wampproto/src/dealer.dart";

class WAMPSession {
  WAMPSession({Serializer? serializer}) : _serializer = serializer ?? JSONSerializer();

  final Serializer _serializer;

  // data structures for RPC
  final Map<int, int> _callRequests = {};
  final Map<int, int> _registerRequests = {};
  final Map<int, int> _registrations = {};
  final Map<int, int> _invocationRequests = {};
  final Map<int, int> _unregisterRequests = {};

  // data structures for PubSub
  final Map<int, int> _publishRequests = {};
  final Map<int, int> _subscribeRequests = {};
  final Map<int, int> _subscriptions = {};
  final Map<int, int> _unsubscribeRequests = {};

  Object sendMessage(Message msg) {
    if (msg is Call) {
      _callRequests[msg.requestID] = msg.requestID;

      return _serializer.serialize(msg);
    } else if (msg is Register) {
      _registerRequests[msg.requestID] = msg.requestID;

      return _serializer.serialize(msg);
    } else if (msg is UnRegister) {
      _unregisterRequests[msg.requestID] = msg.registrationID;

      return _serializer.serialize(msg);
    } else if (msg is Yield) {
      if (!_invocationRequests.containsKey(msg.requestID)) {
        throw ArgumentError("cannot yield for unknown invocation request");
      }
      bool progress = msg.options[optionProgress] ?? false;
      if (!progress) {
        _invocationRequests.remove(msg.requestID);
      }

      return _serializer.serialize(msg);
    } else if (msg is Publish) {
      if (msg.options.containsKey("acknowledge") && msg.options["acknowledge"]) {
        _publishRequests[msg.requestID] = msg.requestID;
      }

      return _serializer.serialize(msg);
    } else if (msg is Subscribe) {
      _subscribeRequests[msg.requestID] = msg.requestID;

      return _serializer.serialize(msg);
    } else if (msg is UnSubscribe) {
      _unsubscribeRequests[msg.requestID] = msg.subscriptionID;

      return _serializer.serialize(msg);
    } else if (msg is Error) {
      if (msg.msgType != Invocation.id) {
        throw ArgumentError("send only supported for invocation error");
      }

      var data = _serializer.serialize(msg);
      _invocationRequests.remove(msg.requestID);
      return data;
    }
    throw ArgumentError("unknown message ${msg.runtimeType}");
  }

  Message receive(Object data) {
    final msg = _serializer.deserialize(data);
    return receiveMessage(msg);
  }

  Message receiveMessage(Message msg) {
    if (msg is Result) {
      if (!_callRequests.containsKey(msg.requestID)) {
        throw ArgumentError("received RESULT for invalid request_id");
      }
      bool progress = msg.details["progress"] ?? false;
      if (!progress) {
        _callRequests.remove(msg.requestID);
      }
      return msg;
    } else if (msg is Registered) {
      if (!_registerRequests.containsKey(msg.requestID)) {
        throw ArgumentError("received REGISTERED for invalid request_id");
      }
      _registerRequests.remove(msg.requestID);

      _registrations[msg.registrationID] = msg.registrationID;

      return msg;
    } else if (msg is UnRegistered) {
      if (!_unregisterRequests.containsKey(msg.requestID)) {
        throw ArgumentError("received UNREGISTERED for invalid request_id");
      }
      final registrationID = _unregisterRequests.remove(msg.requestID);

      if (!_registrations.containsKey(registrationID)) {
        throw ArgumentError("received UNREGISTERED for invalid registration_id");
      }
      _registrations.remove(registrationID);

      return msg;
    } else if (msg is Invocation) {
      if (!_registrations.containsKey(msg.registrationID)) {
        throw ArgumentError("received INVOCATION for invalid registration_id");
      }
      _invocationRequests[msg.requestID] = msg.requestID;

      return msg;
    } else if (msg is Published) {
      if (!_publishRequests.containsKey(msg.requestID)) {
        throw ArgumentError("received PUBLISHED for invalid request_id");
      }
      _publishRequests.remove(msg.requestID);

      return msg;
    } else if (msg is Subscribed) {
      if (!_subscribeRequests.containsKey(msg.requestID)) {
        throw ArgumentError("received SUBSCRIBED for invalid request_id");
      }
      _subscribeRequests.remove(msg.requestID);

      _subscriptions[msg.subscriptionID] = msg.subscriptionID;

      return msg;
    } else if (msg is UnSubscribed) {
      if (!_unsubscribeRequests.containsKey(msg.requestID)) {
        throw ArgumentError("received UNSUBSCRIBED for invalid request_id");
      }
      final subscriptionID = _unsubscribeRequests.remove(msg.requestID);

      if (!_subscriptions.containsKey(subscriptionID)) {
        throw ArgumentError("received UNSUBSCRIBED for invalid subscription_id");
      }
      _subscriptions.remove(subscriptionID);

      return msg;
    } else if (msg is Event) {
      if (!_subscriptions.containsKey(msg.subscriptionID)) {
        throw ArgumentError("received EVENT for invalid subscription_id");
      }

      return msg;
    } else if (msg is Error) {
      switch (msg.msgType) {
        case Call.id:
          if (!_callRequests.containsKey(msg.requestID)) {
            throw ArgumentError("received ERROR for invalid call request");
          }

          _callRequests.remove(msg.requestID);
          break;

        case Register.id:
          if (!_registerRequests.containsKey(msg.requestID)) {
            throw ArgumentError("received ERROR for invalid register request");
          }

          _registerRequests.remove(msg.requestID);
          break;

        case UnRegister.id:
          if (!_unregisterRequests.containsKey(msg.requestID)) {
            throw ArgumentError("received ERROR for invalid unregister request");
          }

          _unregisterRequests.remove(msg.requestID);
          break;

        case Subscribe.id:
          if (!_subscribeRequests.containsKey(msg.requestID)) {
            throw ArgumentError("received ERROR for invalid subscribe request");
          }

          _subscribeRequests.remove(msg.requestID);
          break;

        case UnSubscribe.id:
          if (!_unsubscribeRequests.containsKey(msg.requestID)) {
            throw ArgumentError("received ERROR for invalid unsubscribe request");
          }

          _unsubscribeRequests.remove(msg.requestID);
          break;

        case Publish.id:
          if (!_publishRequests.containsKey(msg.requestID)) {
            throw ArgumentError("received ERROR for invalid publish request");
          }

          _publishRequests.remove(msg.requestID);
          break;

        default:
          throw ArgumentError("unknown error message type ${msg.runtimeType}");
      }

      return msg;
    }

    throw ArgumentError("unknown message ${msg.runtimeType}");
  }
}
