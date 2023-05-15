import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

import IC "Ic";
import Type "Types";
import Iter "mo:base/Iter";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;

  let studenProfileStore = HashMap.HashMap<Principal, StudentProfile>(
    0,
    Principal.equal,
    Principal.hash,
  );
  stable var studenProfileStoreEntries : [(Principal, StudentProfile)] = [];

  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    // adicionales ; correspondiente login

    studenProfileStore.put(caller, profile);
    return #ok();
  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    // var existProfile : ?StudentProfile = studenProfileStore.get(p);
    // var existProfile : ?StudentProfile = ;
    switch (studenProfileStore.get(p)) {
      case (null) {
        return #err("Student Not found");
      };
      case (?profile) {
        return #ok(profile);
      };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    switch (studenProfileStore.get(caller)) {
      case null {
        return #err("Profile not found");
      };
      case (?call) {
        studenProfileStore.put(caller, profile);
        return #ok();
      };

    };
    // if (Principal.isAnonymous(caller)) return #err "User not found";
    // studenProfileStore.replace(caller, profile);
    // caller id
    // ignore studenProfileStore.replace(caller, profile);
    // return #ok();
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    switch (studenProfileStore.get(caller)) {
      case null {
        return #err("profile not found");
      };
      case (?profile) {
        studenProfileStore.delete(caller);
        return #ok();
      };
    };
    // if (Principal.isAnonymous(caller)) return #err "User not found";
    // studenProfileStore.delete(caller);
    // return #ok();
  };

  system func preupgrade() {
    studenProfileStoreEntries := Iter.toArray(studenProfileStore.entries());
  };
  system func postupgrade() {
    for ((p, student) in studenProfileStoreEntries.vals()) {
      studenProfileStore.put(p, student);
    };
    studenProfileStoreEntries := [];
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  type calculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public type Calculator = actor {
    reset : shared () -> async Int;
    add : shared (Int) -> async Int;
    sub : shared (Int) -> async Int;
  };

  public func test(canisterId : Principal) : async TestResult {
    let calc : Calculator = actor (Principal.toText(canisterId));
    // Unexpedte Value in types
    try {
      var a01 : Int = await calc.reset();
      // ignore Debug.print(a01);
      var a0 : Int = await calc.add(12);
      if (a0 != 12) return #err(#UnexpectedValue("Mala suma"));
      var a1 : Int = await calc.sub(5);
      if (a1 != 7) return #err(#UnexpectedValue("Mala resta"));
      var a2 : Int = await calc.reset();
      if (a2 != 0) return #err(#UnexpectedValue("Reset fail"));
      return #ok();
    } catch (e) {
      return #err(#UnexpectedValue("Fail calculator"));
    };
  };
  // STEP - 2 END
  // public type TestResult = Type.TestResult;
  // public type TestError = Type.TestError;

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  func _parceControler(errorMessage : Text) : [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };
  public func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    let managementCanister : IC.ManagementCanisterInterface = actor ("aaaaa-aa");
    try {
      let result = await managementCanister.canister_status({
        canister_id = canisterId;
      });
      let controllers = result.settings.controllers;
      for (pi in controllers.vals()) {
        if (pi == p) {
          return true;
        };
      };
      return false

    } catch (e) {
      let message = Error.message(e);
      let controllers = _parceControler(message);
      for (pi in controllers.vals()) {
        if (pi == p) {
          return true;
        };
      };
      return false

    };
  };
  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
    try {
      let passed = await test(canisterId);
      if (passed != #ok) {
        return #err("No passed the tests");
      };
      let isOwner = await verifyOwnership(canisterId, p);
      if (not isOwner) {
        return #err("Not Principal");
      };

      var estProfile : ?StudentProfile = studenProfileStore.get(p);

      switch (estProfile) {
        case (?profile) {
          var newStudent = {
            name = profile.name;
            graduate = true;
            team = profile.team;
          };
          ignore studenProfileStore.replace(p, newStudent);
          return #ok();
        };
        case null {
          return #err("Student not found");
        };
      };

    } catch (e) {

      return #err("not implemented");
    };
  };
  // STEP 4 - END
};
