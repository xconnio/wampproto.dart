import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Registered", () {
    const baseRegCmd = "message registered 1 1";
    bool isEqual(Registered msg1, Registered msg2) =>
        msg1.requestID == msg2.requestID && msg1.registrationID == msg2.registrationID;

    test("JSONSerializer", () async {
      var msg = Registered(1, 1);
      var command = "$baseRegCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Registered;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Registered(1, 1);
      var command = "$baseRegCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Registered;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Registered(1, 1);
      var command = "$baseRegCmd --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Registered;
      expect(isEqual(message, msg), true);
    });
  });
}
