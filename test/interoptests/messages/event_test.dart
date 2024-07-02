import "package:collection/collection.dart";
import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Event", () {
    const equality = DeepCollectionEquality();
    const baseEventCommand = "message event 1 1";

    bool isEqual(Event msg1, Event msg2) =>
        msg1.subscriptionID == msg2.subscriptionID &&
        msg1.publicationID == msg2.publicationID &&
        equality.equals(msg1.details, msg2.details) &&
        equality.equals(msg1.args, msg2.args) &&
        equality.equals(msg1.kwargs, msg2.kwargs);

    test("JSONSerializer", () async {
      var msg = Event(1, 1);
      var command = "$baseEventCommand --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Event;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Event(1, 1, args: ["abc"]);
      var command = "$baseEventCommand abc --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Event;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Event(1, 1, details: {"abc": 1}, args: ["abc"], kwargs: {"a": 1});
      var command = "$baseEventCommand abc -d abc=1 -k a=1 --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Event;
      expect(isEqual(message, msg), true);
    });
  });
}
