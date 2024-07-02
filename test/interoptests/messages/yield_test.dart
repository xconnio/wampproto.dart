import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Yield", () {
    const equality = DeepCollectionEquality();
    const baseYieldCmd = "message yield 1";

    bool isEqual(Yield msg1, Yield msg2) =>
        msg1.requestID == msg2.requestID &&
        equality.equals(msg1.options, msg2.options) &&
        equality.equals(msg1.args, msg2.args) &&
        equality.equals(msg1.kwargs, msg2.kwargs);

    test("JSONSerializer", () async {
      var msg = Yield(1);
      var command = "$baseYieldCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Yield;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Yield(1, args: ["abc"]);
      var command = "$baseYieldCmd abc --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Yield;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Yield(1, options: {"abc": 1}, args: ["abc"], kwargs: {"a": 1});
      var command = "$baseYieldCmd abc -o abc=1 -k a=1 --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Yield;
      expect(isEqual(message, msg), true);
    });
  });
}
