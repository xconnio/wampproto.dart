import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Abort", () {
    const equality = DeepCollectionEquality();
    const baseAbortCmd = "message abort crash -d foo=abc";

    bool isEqual(Abort msg1, Abort msg2) => msg1.reason == msg2.reason && equality.equals(msg1.details, msg2.details);

    test("JSONSerializer", () async {
      var msg = Abort({"foo": "abc"}, "crash");
      var command = "$baseAbortCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Abort;

      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Abort({"foo": "abc"}, "crash");
      var command = "$baseAbortCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Abort;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Abort({"foo": "abc"}, "crash");
      var command = "$baseAbortCmd --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Abort;
      expect(isEqual(message, msg), true);
    });
  });
}
