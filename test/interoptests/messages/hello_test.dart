import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Hello", () {
    const equality = DeepCollectionEquality();
    const baseHelloCmd = "message hello realm1 anonymous --authid foo -r callee=true";

    bool isEqual(Hello msg1, Hello msg2) =>
        msg1.realm == msg2.realm &&
        msg1.authID == msg2.authID &&
        equality.equals(msg1.authExtra, msg2.authExtra) &&
        equality.equals(msg1.authMethods, msg2.authMethods) &&
        equality.equals(msg1.roles, msg2.roles);

    test("JSONSerializer", () async {
      var msg = Hello("realm1", {"callee": true}, "foo", ["anonymous"]);
      var command = "$baseHelloCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Hello;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Hello("realm1", {"callee": true}, "foo", ["anonymous"]);
      var command = "$baseHelloCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Hello;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Hello("realm1", {"callee": true}, "foo", ["anonymous"], authExtra: {"foo": "bar"});
      var command = "$baseHelloCmd -e foo:bar --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Hello;
      expect(isEqual(message, msg), true);
    });
  });
}
