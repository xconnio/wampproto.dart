import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Publish", () {
    const equality = DeepCollectionEquality();
    const basePubCommand = "message publish 1 io.xconn.topic";

    bool isEqual(Publish msg1, Publish msg2) =>
        msg1.requestID == msg2.requestID &&
        msg1.uri == msg2.uri &&
        equality.equals(msg1.options, msg2.options) &&
        equality.equals(msg1.args, msg2.args) &&
        equality.equals(msg1.kwargs, msg2.kwargs);

    test("JSONSerializer", () async {
      var msg = Publish(1, "io.xconn.topic");
      var command = "$basePubCommand --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Publish;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Publish(1, "io.xconn.topic", args: ["abc"]);
      var command = "$basePubCommand abc --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Publish;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Publish(1, "io.xconn.topic", options: {"abc": 1}, args: ["abc"], kwargs: {"a": 1});
      var command = "$basePubCommand abc -o abc=1 -k a=1 --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Publish;
      expect(isEqual(message, msg), true);
    });
  });
}
