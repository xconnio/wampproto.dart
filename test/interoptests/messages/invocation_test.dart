import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Invocation", () {
    const equality = DeepCollectionEquality();
    const baseInvCmd = "message invocation 1 1";

    bool isEqual(Invocation msg1, Invocation msg2) =>
        msg1.requestID == msg2.requestID &&
        msg1.registrationID == msg2.registrationID &&
        equality.equals(msg1.details, msg2.details) &&
        equality.equals(msg1.args, msg2.args) &&
        equality.equals(msg1.kwargs, msg2.kwargs);

    test("JSONSerializer", () async {
      var msg = Invocation(1, 1);
      var command = "$baseInvCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Invocation;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Invocation(1, 1, args: ["abc"]);
      var command = "$baseInvCmd abc --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Invocation;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Invocation(1, 1, args: ["abc"], kwargs: {"a": 1});
      var command = "$baseInvCmd abc -k a=1 --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Invocation;
      expect(isEqual(message, msg), true);
    });
  });
}
