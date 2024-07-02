import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Cancel", () {
    const equality = DeepCollectionEquality();
    const baseCancelCmd = "message cancel 1 -o foo=abc";

    bool isEqual(Cancel msg1, Cancel msg2) =>
        msg1.requestID == msg2.requestID && equality.equals(msg1.options, msg2.options);

    test("JSONSerializer", () async {
      var msg = Cancel(1, options: {"foo": "abc"});
      var command = "$baseCancelCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Cancel;

      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Cancel(1, options: {"foo": "abc"});
      var command = "$baseCancelCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Cancel;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Cancel(1, options: {"foo": "abc"});
      var command = "$baseCancelCmd --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Cancel;
      expect(isEqual(message, msg), true);
    });
  });
}
