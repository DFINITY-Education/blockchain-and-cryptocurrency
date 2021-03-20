module {

    public type PaymentChannel = {
        userA: Principal;
        userB: Principal;
        amountA: Nat;
        amountB: Nat;
        closing: Bool;
        closingUser: ?Principal;
        ttl: Nat;
    };

    public type Tx = {
        sender: Principal;
        receiver: Principal;
        amount: Nat;
    };

    public type Error = {
        #invalidTx;
        #invalidFinalize;
        #paymentChannelDoesNotExist;
        #paymentChannelClosing;
        #paymentChannelNotClosing;
        #transferFailed;
    };

};
