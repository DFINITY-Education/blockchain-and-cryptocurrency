import Principal "mo:base/Principal";

actor class User() = User {

    public func whoAmI() : async Principal {
        Principal.fromActor(User)
    };

};
