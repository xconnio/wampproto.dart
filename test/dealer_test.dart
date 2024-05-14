import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/src/dealer.dart";
import "package:wampproto/src/uris.dart";

void main() {
  group("Dealer", () {
    final Dealer dealer = Dealer();
    const procedureName = "io.xconn.test";

    test("add and remove session", () {
      dealer.addSession(1);

      // adding duplicate session should throw an exception
      expect(() => dealer.addSession(1), throwsException);

      dealer.removeSession(1);

      // removing non-existing session should throw an exception
      expect(() => dealer.removeSession(3), throwsException);
    });

    test("register a procedure", () {
      dealer.addSession(1);

      final registerMessage = Register(1, procedureName);
      final messageWithRecipient = dealer.receiveMessage(1, registerMessage);
      expect(messageWithRecipient.recipient, 1);
      expect(messageWithRecipient.message, isA<Registered>());

      // check registration by procedure
      var hasRegistration = dealer.hasRegistration(procedureName);
      expect(hasRegistration, isTrue);

      // register with invalid sessionID
      expect(() => dealer.receiveMessage(2, registerMessage), throwsException);

      // register again with same procedure
      var errWithRecipient = dealer.receiveMessage(1, registerMessage);
      expect(errWithRecipient.recipient, 1);
      var errMessage = errWithRecipient.message as Error;
      expect(
        [errMessage.requestID, errMessage.msgType, errMessage.uri],
        [registerMessage.requestID, Register.id, errProcedureAlreadyExists],
      );
    });

    test("call a procedure and receive yield for invocation", () {
      var callMessage = Call(1, procedureName);
      var messageWithRecipient = dealer.receiveMessage(1, callMessage);
      expect(messageWithRecipient.recipient, 1);
      expect(messageWithRecipient.message, isA<Invocation>());

      // call a non-existing procedure
      var invalidCallMessage = Call(1, "invalid");
      var errMsgWithRecipient = dealer.receiveMessage(1, invalidCallMessage);
      expect(errMsgWithRecipient.message, isA<Error>());
      var errMsg = errMsgWithRecipient.message as Error;
      expect(errMsg.uri, errNoSuchProcedure);

      // process yield message correctly
      var invocation = messageWithRecipient.message as Invocation;
      var yieldMessage = Yield(invocation.requestID);
      var resultMsgWithRecipient = dealer.receiveMessage(1, yieldMessage);
      expect(resultMsgWithRecipient.recipient, 1);
      expect(resultMsgWithRecipient.message, isA<Result>());

      // receive yield for non-pending invocations
      expect(() => dealer.receiveMessage(1, yieldMessage), throwsException);

      // receive yield with invalid sessionID
      var msg = dealer.receiveMessage(1, callMessage).message as Invocation;
      expect(() => dealer.receiveMessage(3, Yield(msg.requestID)), throwsException);
    });

    test("unregister a procedure", () {
      var unRegister = UnRegister(1, 1);
      var messagesWithRecipient = dealer.receiveMessage(1, unRegister);
      expect(messagesWithRecipient.recipient, 1);
      expect(messagesWithRecipient.message, isA<UnRegistered>());

      // check registration by procedure
      var hasRegistration = dealer.hasRegistration(procedureName);
      expect(hasRegistration, isFalse);

      // unregister with invalid sessionID
      expect(() => dealer.receiveMessage(2, unRegister), throwsException);

      // unregister with invalid registrationID
      var invalidUnRegister = UnRegister(1, 2);
      expect(() => dealer.receiveMessage(1, invalidUnRegister), throwsException);

      // unregister with non-existing registrationID
      expect(() => dealer.receiveMessage(1, unRegister), throwsException);
    });

    test("receive invalid message", () {
      final subscribe = Subscribe(1, procedureName);
      expect(() => dealer.receiveMessage(1, subscribe), throwsException);
    });

    test("test progressive call results", () {
      var calleeId = 3;
      var callerId = 4;
      dealer
        ..addSession(calleeId)
        ..addSession(callerId);

      var register = Register(1, "foo.bar");
      dealer.receiveMessage(calleeId, register);

      var call = Call(2, "foo.bar", options: {optionReceiveProgress: true});
      var messageWithRecipient = dealer.receiveMessage(callerId, call);
      expect(messageWithRecipient.recipient, calleeId);
      var invMsg = messageWithRecipient.message as Invocation;
      expect(invMsg.details[optionReceiveProgress], isTrue);

      for (var i = 0; i < 10; i++) {
        var yield = Yield(invMsg.requestID, options: {optionProgress: true});
        var msgWithRecipient = dealer.receiveMessage(calleeId, yield);
        expect(messageWithRecipient.recipient, calleeId);
        var resultMsg = msgWithRecipient.message as Result;
        expect(resultMsg.requestID, equals(call.requestID));
        expect(resultMsg.details[optionProgress], isTrue);
      }

      var yield = Yield(invMsg.requestID);
      var msg = dealer.receiveMessage(calleeId, yield);
      expect(msg.recipient, callerId);
      var resultMsg = msg.message as Result;
      expect(resultMsg.requestID, equals(call.requestID));
      expect(resultMsg.details[optionProgress] ?? false, isFalse);

      var nonPendingYield = Yield(resultMsg.requestID);
      expect(
        () => dealer.receiveMessage(calleeId, nonPendingYield),
        throwsA(predicate((e) => e is Exception && e.toString().contains("no pending calls for session"))),
      );
    });

    test("test progressive call invocation", () {
      var procedureProCallInv = "io.xconn.test_progressive_call_inv";
      var calleeId = 5;
      var callerId = 6;
      dealer
        ..addSession(calleeId)
        ..addSession(callerId);

      var register = Register(1, procedureProCallInv);
      dealer.receiveMessage(calleeId, register);

      var call = Call(2, procedureProCallInv, options: {optionProgress: true});
      var messageWithRecipient = dealer.receiveMessage(callerId, call);
      expect(messageWithRecipient.recipient, calleeId);

      var invMessage = messageWithRecipient.message as Invocation;
      expect(invMessage.details[optionProgress], isTrue);
      var invocationRequestId = invMessage.requestID;

      for (var i = 0; i < 10; i++) {
        var call = Call(2, procedureProCallInv, options: {optionProgress: true});
        var messageWithRecipient = dealer.receiveMessage(callerId, call);
        expect(messageWithRecipient.recipient, calleeId);

        var invMessage = messageWithRecipient.message as Invocation;
        expect(invMessage.details[optionProgress], isTrue);
        expect(invMessage.requestID, equals(invocationRequestId));
      }

      var callMsg = Call(2, procedureProCallInv);
      var msgWithRecipient = dealer.receiveMessage(callerId, callMsg);
      expect(msgWithRecipient.recipient, calleeId);

      var invocationMessage = msgWithRecipient.message as Invocation;
      expect(invocationMessage.details.containsKey(optionProgress), isFalse);
    });
  });
}
