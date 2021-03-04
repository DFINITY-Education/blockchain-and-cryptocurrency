import Hash "mo:base/Hash";
import Hashmap "mo:base/Hashmap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

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
                    userA: party;
                    userB: counterparty;
                    amountA: amount;
                    amountB: 0;
                })
            };
        }
    };

    public shared(msg) func addFunds(counterparty : Principal) : async Result {

    };

    public shared(msg) func closeChannel(counterparty : Principal, tx : Tx, signedAttestation : Hash) : async Result {
        let key = genKey(party, counterparty);
        switch (paymentChannels.get(key)) {
            case(?pc) {
                pc.
            };
            case(null) Err(#paymentDoesNotExist);
        }
    };

    func genKey(party: Principal, counterparty: Principal) : Hash {
        let partyText = Principal.toText(party);
        let counterpartyText = Principal.toText(counterparty);
        switch (Principal.compare(party, counterparty)) {
            case(#less) Text.hash(partyText # counterpartyText);
            case(#greater) Text.hash(counterpartyText # partyText);
            case(_) "";
        }
    }

};
