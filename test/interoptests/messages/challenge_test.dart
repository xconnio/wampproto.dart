import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Challenge", () {
    const equality = DeepCollectionEquality();
    const baseChallengeCmd = "message challenge ticket -e ticket=abc";

    bool isEqual(Challenge msg1, Challenge msg2) =>
        msg1.authMethod == msg2.authMethod && equality.equals(msg1.extra, msg2.extra);

    test("JSONSerializer", () async {
      var msg = Challenge("ticket", {"ticket": "abc"});
      var command = "$baseChallengeCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Challenge;

      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Challenge("ticket", {"ticket": "abc"});
      var command = "$baseChallengeCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Challenge;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Challenge("ticket", {"ticket": "abc"});
      var command = "$baseChallengeCmd --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Challenge;
      expect(isEqual(message, msg), true);
    });
  });
}
