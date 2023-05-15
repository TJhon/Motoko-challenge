import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import List "mo:base/List";
import Time "mo:base/Time";
import Type "Types";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Text "mo:base/Text";

actor class Homework() {
  type Homework = Type.Homework;

  var homeworkDiary = Buffer.Buffer<Homework>(0);
  var pending = Buffer.Buffer<Homework>(0);
  var searchText = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    // hwList := List.push<Homework>(homework, hwList);
    // var id = homework.title;
    homeworkDiary.add(homework);
    return homeworkDiary.size() -1;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    // return #err("not implemented");
    try {
      let hw = homeworkDiary.get(id);
      return #ok(hw);
    } catch (e) {
      return #err("HW not found with de id" #Nat.toText(id));
    };
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    let hw : ?Homework = homeworkDiary.getOpt(id);
    switch (hw) {
      case (?hw) {
        homeworkDiary.put(id, homework);
        return #ok();
      };
      case null {
        return #err("Not found");
      };
    };
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    let hw : ?Homework = homeworkDiary.getOpt(id);
    switch (hw) {
      case (null) {
        return #err("Not found:" #Nat.toText(id));
      };
      case (?hw) {
        let newHW = {
          title = hw.title;
          description = hw.description;
          dueDate = hw.dueDate;
          completed = true;
        };
        homeworkDiary.put(id, newHW);
        return #ok();
      };
    };
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    let hw : ?Homework = homeworkDiary.getOpt(id);
    switch (hw) {
      case (?hw) {
        let x = homeworkDiary.remove(id);
        return #ok();
      };
      case null {
        return #err("sdklj");
      };

    };

  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  private func filter() : async Nat {
    return 1;
  };
  public shared query func getPendingHomework() : async [Homework] {
    // var pending = homeworkDiary.filterEntries(func(Homework, x) = x.completed);
    for (element in homeworkDiary.vals()) {
      if (element.completed) {

      } else {
        pending.add(element);
      };
    };
    return Buffer.toArray(pending);
  };

  // // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {

    for (el in homeworkDiary.vals()) {
      var title = el.title;
      var desc = el.description;
      var eval1 = Text.contains(title, #text searchTerm);
      var eval2 = Text.contains(desc, #text searchTerm);
      if (eval1 or eval2) {
        searchText.add(el);
      };
      // Text.contains()
    };
    return Buffer.toArray(searchText);
  };
};
