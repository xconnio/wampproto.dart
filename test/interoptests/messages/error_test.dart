import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Error", () {
    const equality = DeepCollectionEquality();
    const testError = "wamp.error";
    const baseErrorCmd = "message error 1 1 wamp.error";

    bool isEqual(Error msg1, Error msg2) =>
        msg1.msgType == msg2.msgType &&
        msg1.requestID == msg2.requestID &&
        msg1.uri == msg2.uri &&
        equality.equals(msg1.details, msg2.details) &&
        equality.equals(msg1.args, msg2.args) &&
        equality.equals(msg1.kwargs, msg2.kwargs);

    test("JSONSerializer", () async {
      var msg = Error(1, 1, testError);
      var command = "$baseErrorCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Error;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Error(1, 1, testError, args: ["abc"]);
      var command = "$baseErrorCmd abc --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Error;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Error(1, 1, testError, details: {"abc": 123}, args: ["abc"], kwargs: {"a": 1});
      var command = "$baseErrorCmd abc -d abc=123 -k a=1 --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Error;
      expect(isEqual(message, msg), true);
    });
  });
}
