import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Subscribe", () {
    const equality = DeepCollectionEquality();
    const topic = "io.xconn.test";
    const baseSubCommand = "message subscribe 1 $topic";

    bool isEqual(Subscribe msg1, Subscribe msg2) =>
        msg1.requestID == msg2.requestID && msg1.topic == msg2.topic && equality.equals(msg1.options, msg2.options);

    test("JSONSerializer", () async {
      var msg = Subscribe(1, topic);
      var command = "$baseSubCommand --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Subscribe;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Subscribe(1, topic);
      var command = "$baseSubCommand --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Subscribe;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Subscribe(1, topic, options: {"a": 1});
      var command = "$baseSubCommand -o a=1 --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Subscribe;
      expect(isEqual(message, msg), true);
    });
  });
}
