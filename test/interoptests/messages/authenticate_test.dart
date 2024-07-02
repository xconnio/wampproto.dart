import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Authenticate", () {
    const equality = DeepCollectionEquality();
    const baseAuthenticateCmd = "message authenticate signature -e ticket=abc";

    bool isEqual(Authenticate msg1, Authenticate msg2) =>
        msg1.signature == msg2.signature && equality.equals(msg1.extra, msg2.extra);

    test("JSONSerializer", () async {
      var msg = Authenticate("signature", {"ticket": "abc"});
      var command = "$baseAuthenticateCmd --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Authenticate;

      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Authenticate("signature", {"ticket": "abc"});
      var command = "$baseAuthenticateCmd --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Authenticate;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Authenticate("signature", {"ticket": "abc"});
      var command = "$baseAuthenticateCmd --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Authenticate;
      expect(isEqual(message, msg), true);
    });
  });
}
