import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Interrupt", () {
    const equality = DeepCollectionEquality();
    const baseInterruptCmd = "message interrupt 1 -o foo=abc";

    bool isEqual(Interrupt msg1, Interrupt msg2) =>
        msg1.requestID == msg2.requestID && equality.equals(msg1.options, msg2.options);

    test("JSONSerializer", () async {
      var msg = Interrupt(1, options: {"foo": "abc"});
      var command = "$baseInterruptCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Interrupt;

      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Interrupt(1, options: {"foo": "abc"});
      var command = "$baseInterruptCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Interrupt;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Interrupt(1, options: {"foo": "abc"});
      var command = "$baseInterruptCmd --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Interrupt;
      expect(isEqual(message, msg), true);
    });
  });
}
