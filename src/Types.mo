import Time "mo:base/Time";

module {

    public type PaymentChannel = {
        userA: Principal;
        userB: Principal;
        amountA: Nat;
        amountB: Nat;
        closing: Bool;
        closingUser: ?Principal;
        ttl: Time.Time;
    };

    public type Tx = {
        sender: Principal;
        receiver: Principal;
        amount: Nat;
    };

    public type Error = {
        #invalidTx;
        #invalidFinalize;
        #insufficientBalance;
	    #paymentChannelAlreadyExists;
        #paymentChannelDoesNotExist;
        #paymentChannelClosing;
        #paymentChannelNotClosing;
        #transferFailed;
    };

    public type Owner = Text;
    public type Token = actor {
      allowance: shared query (Owner, Owner) -> async Nat;
      approve:  (Owner, Nat) -> async Bool;
      balanceOf: shared query (Owner) -> async ?Nat;
      name: shared query () -> async Text;
      symbol: shared query () -> async Text;
      totalSupply: shared query () -> async Nat;
      transfer: (Owner, Nat) -> async Bool;
      transferFrom: shared (Owner, Owner, Nat) -> async Bool;
   };
};

