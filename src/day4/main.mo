import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Account "Account";
import BootcampLocalActor "BootcampLocalActor";

actor class MotoCoin() {
  public type Account = Account.Account;

  var tSupply = 0;
  var airdropRan = false;
  var ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);
  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    // Fail
    // for (val in ledger.vals()) {
    //   tSupply := tSupply + val;
    // };
    // return tSupply;
    var total = 0;
    for (val in ledger.vals()) {
      total += val;
    };
    return total;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    var saldoRef = ledger.get(account);
    let saldo = Option.get(saldoRef, 0);
    return (saldo);
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {

    var fromAccount = ledger.get(from);
    if (fromAccount == null) return #err("Not found");

    var fromSaldo = Option.get(fromAccount, 0);
    if (fromSaldo < amount) return #err("Not enough");

    // let toAccount : ?Account = ledger.get(to);
    var toAccount = ledger.get(to);
    if (toAccount == null) return #err("Not found");

    var toSaldo = Option.get(toAccount, 0);
    try {
      let restFrom = ledger.replace(from, fromSaldo - amount);
      let restTo = ledger.replace(to, toSaldo + amount);
      return #ok();
    } catch (e) {
      return #err("Error");
    };
  };

  // Airdrop 100 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    // let motokoBtcmp = BootcampLocalActor.BootcampLocalActor();
    // let motokoBtcmp = await BootcampLocalActor.BootcampLocalActor();
    let motokoBtcmp : actor {
      getAllStudentsPrincipal : () -> async [Principal];
    } = actor ("rww3b-zqaaa-aaaam-abioa-cai");
    let allStudents = await motokoBtcmp.getAllStudentsPrincipal();
    if (allStudents.size() <= 0) {
      return #err("No Students");
    };
    // for (accStd in allStudents.vals()) {
    //   var account : Account = { owner = accStd; subaccount = null };
    //   let value_account = ledger.get(account);
    //   ledger.put(account, Option.get(value_account, 0) + 100);
    // };
    let saveAccount = func(student : Principal) : Nat {
      let account = {
        owner = student;
        subaccount = null;
      };
      let value = ledger.get(account);
      ledger.put(account, Option.get(value, 0) + 100);
      return 0;
    };

    let as = Array.map(allStudents, saveAccount);
    return #ok(());
  };
};
