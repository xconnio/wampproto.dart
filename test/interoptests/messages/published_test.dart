import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Published", () {
    const basePubCmd = "message published 1 1";

    bool isEqual(Published msg1, Published msg2) =>
        msg1.requestID == msg2.requestID && msg1.publicationID == msg2.publicationID;

    test("JSONSerializer", () async {
      var msg = Published(1, 1);
      var command = "$basePubCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Published;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Published(1, 1);
      var command = "$basePubCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Published;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Published(1, 1);
      var command = "$basePubCmd --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Published;
      expect(isEqual(message, msg), true);
    });
  });
}
