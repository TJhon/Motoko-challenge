import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Bool "mo:base/Bool";
import Prim "mo:⛔";

actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  var messageId = 1;
  private func hashKey(num : Nat) : Hash.Hash {
    return Text.hash(Nat.toText(num));
  };
  // var
  // var wall : HashMap.HashMap<Nat, Message> = HashMap.HashMap<Nat, Message>(messageId, Nat.equal, Hash.hash);
  var wall = HashMap.HashMap<Nat, Message>(2, Nat.equal, hashKey);
  let allMessage = Buffer.Buffer<Message>(2);
  var allMessageRanked = Buffer.Buffer<Message>(2);

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    var newMessage : Message = {
      content = c;
      vote = 0;
      creator = caller;
    };
    messageId := wall.size();
    wall.put(messageId, newMessage);
    return messageId;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    if (messageId > wall.size()) {
      return #err("Not found");
    };
    let message : ?Message = wall.get(messageId);
    switch (message) {
      case (?message) {
        return #ok(message);
      };
      case null {
        return #err("Not found");
      };
    };

  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    let mssg : ?Message = wall.get(messageId);
    switch (mssg) {
      case (null) {
        return #err("NOt found");
      };
      case (?current) {
        if (caller == current.creator) {
          let newMssg : Message = {
            vote = current.vote;
            content = c;
            creator = current.creator;
          };
          ignore wall.replace(messageId, newMssg);
          return #ok();
        } else {
          return #err("NOt user");
        };

      };
    };

  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    if (messageId >= wall.size()) {
      return #err("Not found");
    };
    var updateWall = wall.delete(messageId);
    // var message = wall.get(messageId);
    // Debug.print(message.content.text);
    // let prin = message.creator;
    // Principal.equal

    return #ok();
  };

  // Voting
  // private func vote(up: Bool): async Message{
  //   var up_to = 1
  //   if(up){
  //     up_to := -1
  //   };

  //   // return
  // };

  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    if (messageId >= wall.size()) {
      return #err("Not found");
    };
    let msg : ?Message = wall.get(messageId);
    switch (msg) {
      case (?current) {
        let mssg_v : Message = {
          vote = current.vote + 1;
          content = current.content;
          creator = current.creator;
        };
        ignore wall.replace(messageId, mssg_v);
        // updateMessage(messageId, mssg_v)
        return #ok();
      };
      case null {
        return #err("notfound");
      };
    };
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    if (messageId >= wall.size()) {
      return #err("Not found");
    };
    let msg : ?Message = wall.get(messageId);
    switch (msg) {
      case (?current) {
        let mssg_v : Message = {
          vote = current.vote - 1;
          content = current.content;
          creator = current.creator;
        };
        ignore wall.replace(messageId, mssg_v);
        // updateMessage(messageId, mssg_v)
        return #ok();
      };
      case null {
        return #err("notfound");
      };
    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    for (mssg in wall.vals()) {
      allMessage.add(mssg);
    };

    return Buffer.toArray(allMessage);
  };
  var allMessagesRanked = Buffer.Buffer<Message>(2);
  // Get all messages ordered by votes
  public query func getAllMessagesRanked() : async [Message] {
    var j : Nat = 0;
    var index : Nat = 0;
    var vote : Int = 0;

    if (Buffer.isEmpty(allMessage) != true) {
      allMessage.clear();
      for (message in wall.vals()) {
        allMessage.add(message);
      };
      while (allMessage.size() > 0) {
        j := 0;
        index := 0;
        vote := allMessage.get(index).vote;
        for (value in allMessage.vals()) {
          if (vote < value.vote) {
            index := j;
            vote := value.vote;
          };
          j += 1;
        };
        allMessagesRanked.add(allMessage.get(index));
        let x = allMessage.remove(index);
      };
      return Buffer.toArray<Message>(allMessagesRanked);
    } else {
      for (message in wall.vals()) {
        allMessage.add(message);
      };

      while (allMessage.size() > 0) {
        j := 0;
        index := 0;
        vote := allMessage.get(index).vote;
        for (value in allMessage.vals()) {
          if (vote < value.vote) {
            index := j;
            vote := value.vote;
          };
          j += 1;
        };
        allMessagesRanked.add(allMessage.get(index));
        let x = allMessage.remove(index);
      };
      return Buffer.toArray<Message>(allMessagesRanked);
    };

  };
};
