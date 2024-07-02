import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Goodbye", () {
    const equality = DeepCollectionEquality();

    bool isEqual(Goodbye msg1, Goodbye msg2) =>
        msg1.reason == msg2.reason && equality.equals(msg1.details, msg2.details);

    test("JSONSerializer", () async {
      var msg = Goodbye({"foo": "abc"}, "crash");
      var command = "message goodbye crash -d foo=abc --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Goodbye;

      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Goodbye({"foo": "abc"}, "crash");
      var command = "message goodbye crash -d foo=abc --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Goodbye;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Goodbye({"foo": "abc"}, "crash");
      var command = "message goodbye crash -d foo=abc --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Goodbye;
      expect(isEqual(message, msg), true);
    });
  });
}
