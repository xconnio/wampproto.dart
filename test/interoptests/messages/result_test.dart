import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Result", () {
    const equality = DeepCollectionEquality();
    const baseResultCmd = "message result 1";

    bool isEqual(Result msg1, Result msg2) =>
        msg1.requestID == msg2.requestID &&
        equality.equals(msg1.details, msg2.details) &&
        equality.equals(msg1.args, msg2.args) &&
        equality.equals(msg1.kwargs, msg2.kwargs);

    test("JSONSerializer", () async {
      var msg = Result(1);
      var command = "$baseResultCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Result;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Result(1, args: ["abc"]);
      var command = "$baseResultCmd abc --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Result;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Result(1, details: {"abc": 1}, args: ["abc"], kwargs: {"a": 1});
      var command = "$baseResultCmd abc -d abc=1 -k a=1 --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Result;
      expect(isEqual(message, msg), true);
    });
  });
}
