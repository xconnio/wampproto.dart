import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Register", () {
    const equality = DeepCollectionEquality();
    const testProcedure = "io.xconn.test";
    const baseRegCmd = "message register 1 $testProcedure";

    bool isEqual(Register msg1, Register msg2) =>
        msg1.requestID == msg2.requestID && msg1.uri == msg2.uri && equality.equals(msg1.options, msg2.options);

    test("JSONSerializer", () async {
      var msg = Register(1, testProcedure);
      var command = "$baseRegCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Register;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Register(1, testProcedure);
      var command = "$baseRegCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Register;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Register(1, testProcedure, options: {"a": 1});
      var command = "$baseRegCmd -o a=1 --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Register;
      expect(isEqual(message, msg), true);
    });
  });
}
