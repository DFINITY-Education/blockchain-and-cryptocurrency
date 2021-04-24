import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import P "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

import Types "./Types";

actor class PaymentChannelClass(Token : Types.Token) = PC {

    type Hash = Hash.Hash;

    type Error = Types.Error;
    type PaymentChannel = Types.PaymentChannel;
    type Result = Result.Result<(), Error>;
    type Tx = Types.Tx;

    private let paymentChannels = HashMap.HashMap<Text, PaymentChannel>(1, Text.equal, Text.hash);

    public shared(msg) func setup(counterparty : Principal, amount: Nat) : async Result {
        switch (await Token.balanceOf(Principal.toText(msg.caller))) {
            case (?balance) {
                if (balance < amount) return #err(#insufficientBalance);
            };
            case (null) return #err(#insufficientBalance);
        };

        let key = genKey(msg.caller, counterparty);
        switch (paymentChannels.get(key)) {
            case(?_) #err(#paymentChannelAlreadyExists);
            case(null) {
                paymentChannels.put(key, {
                    userA = msg.caller;
                    userB = counterparty;
                    amountA = amount;
                    amountB = 0;
                    closing = false;
                    closingUser = null;
                    ttl = 0;
                });

                if (not (await Token.transferFrom(Principal.toText(msg.caller), Principal.toText(Principal.fromActor(PC)), amount))) {
                    return #err(#transferFailed);
                };

                #ok(())
            };
        }
    };

    public shared(msg) func addFunds(counterparty : Principal, amount: Nat) : async Result {
        let key = genKey(msg.caller, counterparty);
        switch (paymentChannels.get(key)) {
            case(?pc) {
                if (pc.closing) return #err(#paymentChannelClosing);
                if (msg.caller == pc.userA) {
                    paymentChannels.put(key, {
                        userA = pc.userA;
                        userB = pc.userB;
                        amountA = pc.amountA + amount;
                        amountB = pc.amountB;
                        closing = pc.closing;
                        closingUser = pc.closingUser;
                        ttl = pc.ttl;
                    });
                } else {
                    paymentChannels.put(key, {
                        userA = pc.userA;
                        userB = pc.userB;
                        amountA = pc.amountA;
                        amountB = pc.amountB + amount;
                        closing = pc.closing;
                        closingUser = pc.closingUser;
                        ttl = pc.ttl;
                    });
                };

                #ok(())
            };
            case(null) #err(#paymentChannelDoesNotExist);
        }
    };

    public shared(msg) func beginClosingChannel(
        counterparty : Principal,
        tx : Tx,
        signedAttestation : Hash
    ) : async Result {
        let key = genKey(msg.caller, counterparty);
        switch (paymentChannels.get(key)) {
            case(?pc) {
                if (pc.closing) return #err(#paymentChannelClosing);
                if (tx.amount > pc.amountA + pc.amountB) return #err(#invalidTx);

                if (tx.sender == pc.userA) {
                    paymentChannels.put(key, {
                        userA = pc.userA;
                        userB = pc.userB;
                        amountA = pc.amountA - tx.amount;
                        amountB = pc.amountB + tx.amount;
                        closing = true;
                        closingUser = ?msg.caller;
                        ttl = Time.now() + (3600 * 1000_000);
                    });
                } else {
                    paymentChannels.put(key, {
                        userA = pc.userA;
                        userB = pc.userB ;
                        amountA = pc.amountA - tx.amount;
                        amountB = pc.amountB + tx.amount;
                        closing = true;
                        closingUser = ?msg.caller;
                        ttl = Time.now() + (3600 * 1000_000);
                    });
                };

                #ok(())
            };
            case(null) #err(#paymentChannelDoesNotExist);
        }
    };

    public shared(msg) func finalizeClosingChannel(counterparty : Principal) : async Result {
        let key = genKey(msg.caller, counterparty);
        switch (paymentChannels.get(key)) {
            case(?pc) {
                if (not pc.closing) return #err(#paymentChannelNotClosing);
                if ((Option.unwrap<Principal>(pc.closingUser) == msg.caller) and (pc.ttl > Time.now())) {
                    return #err(#invalidFinalize);
                };

                paymentChannels.delete(key);
                if (not (await Token.transferFrom(Principal.toText(Principal.fromActor(PC)), Principal.toText(pc.userA), pc.amountA))) {
                    return #err(#transferFailed);
                };
                if (not (await Token.transferFrom(Principal.toText(Principal.fromActor(PC)), Principal.toText(pc.userB), pc.amountB))) {
                    return #err(#transferFailed);
                };

                #ok(())
            };
            case(null) #err(#paymentChannelDoesNotExist);
        }
    };

    func genKey(party: Principal, counterparty: Principal) : Text {
        let partyText = Principal.toText(party);
        let counterpartyText = Principal.toText(counterparty);
        switch (Principal.compare(party, counterparty)) {
            case(#less) partyText # counterpartyText;
            case(#greater) counterpartyText # partyText;
            case(_) P.unreachable();
        }
    };

};
