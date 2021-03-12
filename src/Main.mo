import Hash "mo:base/Hash";
import Hashmap "mo:base/Hashmap";
import Option "mo:base/Option";
import P "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";

import Token "canister:Token";

import Types "./Types";

actor {

    type Hash = Hash.Hash;

    type PaymentChannel = Types.PaymentChannel;
    type Result = Result.Result<(), Error>;
    type Error = Types.Error;

    let paymentChannels = Hashmap<Hash, PaymentChannel>(1, Principal.equal, Principal.hash);

    public shared(msg) func setup(counterparty : Principal, amount: Nat) : async Result {
        if ((await Token.balanceOf(msg.caller)) < amount) return Err(#insufficientBalance);

        let key = genKey(party, counterparty);
        switch (paymentChannels.get(key)) {
            case(?_) Err(#paymentChannelAlreadyExists);
            case(null) {
                paymentChannels.put(key, PaymentChannel {
                    userA = party;
                    userB = counterparty;
                    amountA = amount;
                    amountB = 0;
                    closing = false;
                    closingUser = None;
                    ttl = 0;
                })
            };
        }
    };

    public shared(msg) func addFunds(counterparty : Principal, amount: Nat) : async Result {
        let key = genKey(party, counterparty);
        switch (paymentChannels.get(key)) {
            case(?pc) {
                if (pc.closing) return #err(#paymentChannelClosing);
                if (msg.caller == pc.userA) {
                    paymentChannels.put(key, PaymentChannel {
                        userA = pc.userA;
                        userB = pc.userB;
                        amountA = pc.amountA + amount;
                        amountB = pc.amountB;
                        closing = pc.closing;
                        closingUser = pc.closingUser;
                        ttl = pc.ttl;
                    });
                } else {
                    paymentChannels.put(key, PaymentChannel {
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
        let key = genKey(party, counterparty);
        switch (paymentChannels.get(key)) {
            case(?pc) {
                if (pc.closing) return #err(#paymentChannelClosing);
                if (tx.amount > pc.amountA + pc.amountB) return #err(#invalidTx);

                paymentChannels.put(key, PaymentChannel {
                        userA = pc.userA;
                        userB = pc.userB;
                        amountA = pc.amountA;
                        amountB = pc.amountB + amount;
                        closing = true;
                        closingUser = Some(msg.caller);
                        ttl = Time.now() + (3600 * 1000_000);
                    });

                #ok(())
            };
            case(null) Err(#paymentDoesNotExist);
        }
    };

    public shared(msg) func finalizeClosingChannel() : async Result {
        let key = genKey(party, counterparty);
        switch (paymentChannels.get(key)) {
            case(?pc) {
                if (not pc.closing) return #err(#paymentChannelNotClosing);
                if ((Option.unwrap<Principal>(pc.closingUser) == msg.caller) and (pc.ttl > Time.now())) {
                    return #err(#invalidFinalize);
                };

                paymentChannels.delete(key);
                if (not (await Token.transferFrom(tx.sender, tx.receiver, tx.amount))) return #err(#transferFailed);

                #ok(())
            };
            case(null) #err(#paymentChannelDoesNotExist);
        }
    };

    func genKey(party: Principal, counterparty: Principal) : Hash {
        let partyText = Principal.toText(party);
        let counterpartyText = Principal.toText(counterparty);
        switch (Principal.compare(party, counterparty)) {
            case(#less) Text.hash(partyText # counterpartyText);
            case(#greater) Text.hash(counterpartyText # partyText);
            case(_) P.unreachable();
        }
    };

};
