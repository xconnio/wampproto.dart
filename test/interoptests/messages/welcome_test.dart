import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Welcome", () {
    const equality = DeepCollectionEquality();
    const baseWelcomeCmd =
        '''message welcome 1 -d authmethod=anonymous -d authid=foo -d authrole=bar -d roles={"callee":true} ''';

    bool isEqual(Welcome msg1, Welcome msg2) =>
        msg1.sessionID == msg2.sessionID &&
        msg1.authID == msg2.authID &&
        msg1.authMethod == msg2.authMethod &&
        msg1.authRole == msg2.authRole &&
        equality.equals(msg1.authExtra, msg2.authExtra) &&
        equality.equals(msg1.roles, msg2.roles);

    test("JSONSerializer", () async {
      var msg = Welcome(1, {"callee": true}, "foo", "bar", "anonymous");
      var command = "$baseWelcomeCmd--serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Welcome;

      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Welcome(1, {"callee": true}, "foo", "bar", "anonymous");
      var command = "$baseWelcomeCmd--serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Welcome;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Welcome(1, {"callee": true}, "foo", "bar", "anonymous");
      var command = "$baseWelcomeCmd--serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Welcome;
      expect(isEqual(message, msg), true);
    });
  });
}
