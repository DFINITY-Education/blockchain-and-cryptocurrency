

module {
    
    public type PaymentChannel = {
        userA: Principal;
        userB: Principal;
        amountA: Nat;
        amountB: Nat;
    };

    public type Tx = {
        sender: Principal;
        receiver: Principal;
        amount: Nat;
    }

};