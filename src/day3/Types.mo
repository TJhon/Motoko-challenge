import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
module {
  public type Content = {
    #Text : Text;
    #Image : Blob;
    #Video : Blob;
    // #Survey : Survey;
  };

  public type Message = {
    content : Content;
    vote : Int;
    creator : Principal;
  };
};
