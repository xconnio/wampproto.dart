import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  const baseUnRegCmd = "message unregistered 1";

  group("UnRegistered", () {
    bool isEqual(UnRegistered msg1, UnRegistered msg2) => msg1.requestID == msg2.requestID;

    test("JSONSerializer", () async {
      var msg = UnRegistered(1);
      var command = "$baseUnRegCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as UnRegistered;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = UnRegistered(1);
      var command = "$baseUnRegCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as UnRegistered;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = UnRegistered(1);
      var command = "$baseUnRegCmd --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as UnRegistered;
      expect(isEqual(message, msg), true);
    });
  });
}
