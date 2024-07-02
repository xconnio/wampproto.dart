import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Subscribed", () {
    const baseSubCommand = "message subscribed 1 1";

    bool isEqual(Subscribed msg1, Subscribed msg2) =>
        msg1.requestID == msg2.requestID && msg1.subscriptionID == msg2.subscriptionID;

    test("JSONSerializer", () async {
      var msg = Subscribed(1, 1);
      var command = "$baseSubCommand --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Subscribed;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Subscribed(1, 1);
      var command = "$baseSubCommand --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Subscribed;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Subscribed(1, 1);
      var command = "$baseSubCommand --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Subscribed;
      expect(isEqual(message, msg), true);
    });
  });
}
