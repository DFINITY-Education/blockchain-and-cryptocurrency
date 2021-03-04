/**
 * Module     : Token.mo
 * Copyright  : 2020 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Array "mo:base/Array";
import AssocList "mo:base/AssocList";
import Error "mo:base/Error";
import Hex "../vendor/motoko-hex/src/Hex";
import List "mo:base/List";
import Option "mo:base/Option";
import Prim "mo:prim";
import Util "../src/Util";

actor Token {

  /** 
   * Types
   */

  // The identity of a token owner in a human readable format.
  public type Owner = Text;

  // The identity of a token owner in a machine readable format.
  private type OwnerBytes = [Word8];

  // Simplifier for type AssocList.AssocList.
  private type AssocList<K, V> = AssocList.AssocList<K, V>;

  /**
   * State
   */

  // The initializer of this canister.
  private let initializer : Principal = Prim.caller();

  // The total token supply.
  private let N : Nat = 1000000000;

  // The distribution of token balances.
  private stable var balances : AssocList.AssocList<OwnerBytes, Nat> =
    List.make((Util.unpack(initializer), N));
  
  // Keeps a list of allowed spender and amount for each token owner
  private stable var allowances : AssocList<OwnerBytes, AssocList<OwnerBytes, Nat>> =
    List.nil<(OwnerBytes, AssocList<OwnerBytes, Nat>)>();

  // Allows the given `spender` to spend `amount` tokens on behalf ot function caller
  public shared {
    caller = caller;
  } func approve(spender : Owner, amount : Nat) : async Bool {
    switch (Hex.decode(spender)) {
      case (#ok spenderBytes) {
        let ownerBytes = Util.unpack(caller);
        let balance = Option.get(find(ownerBytes), 0);
        if (balance < amount) {
          return false;
        } else {
          var allows : ?AssocList<OwnerBytes, Nat> = AssocList.find(allowances, ownerBytes, eq);
          switch(allows) {
            case null allows := ?List.make((spenderBytes, amount));
            case (?allowance) {
              var newAllowance : AssocList<OwnerBytes, Nat> = List.make((spenderBytes, amount));
              // counter for checking whether requested amount is lower than remaining balance to spend
              var counter : Nat = 0;
              List.iterate<(OwnerBytes, Nat)>(allowance, func (data) {
                counter += data.1;
                if (eq(data.0, spenderBytes)) {
                  // It was already included in the initalization of the list
                  //newAllowance := List.push((data.0, amount), newAllowance);
                } else {
                  newAllowance := List.push((data.0, data.1), newAllowance);
                };
              });
              if (counter + amount > balance) {
                // Trying to allow an amount greater than balance
                return false;
              } else {
                allows := ?newAllowance;
              };
            };
          };
          allowances := AssocList.replace(allowances, ownerBytes, eq, allows).0;
          return true;
        };
      };
      case (#err (#msg msg)) {
        throw Error.reject("Parse error on approve:spender => " # msg);
      };
    };
  };

  // Transfers `amount` tokens from `owner` to `to`. Function caller should have permission to do so.
  // See function 'approve'.
  public shared {
    caller = caller;
  } func transferFrom(owner : Owner, to : Owner, amount : Nat) : async Bool {
    let spenderBytes : OwnerBytes = Util.unpack(caller);
    let allowedAmount = await allowance(owner, Hex.encode(spenderBytes));
    if (allowedAmount < amount) {
      return false;
    };
    switch (Hex.decode(to)) {
      case (#ok receiver) {
        switch(Hex.decode(owner)) {
          case(#ok ownerBytes) {
            let balance = Option.get(find(ownerBytes), 0);
            if (balance < amount) {
              return false;
            } else {
              // First, update owner's balance
              let difference = balance - amount;
              replace(ownerBytes, if (difference == 0) null else ?difference);
              replace(receiver, ?(Option.get(find(receiver), 0) + amount));
              // Then update owner's allowance for spenderBytes
              var allowance = AssocList.find<OwnerBytes, AssocList<OwnerBytes, Nat>>(allowances, ownerBytes, eq);
              switch(allowance) {
                case null return false;
                case (?allowance) {
                  let diff = allowedAmount - amount;
                  let newAllowance = AssocList.replace<OwnerBytes, Nat>(allowance, spenderBytes, eq, if (diff == 0) null else ?diff).0;
                  allowances := AssocList.replace(allowances, ownerBytes, eq, ?newAllowance).0;
                  return true;
                }
              }
            };
          };
          case (#err (#msg msg)) {
            throw Error.reject("Parse error on transferFrom:owner => " # msg);
          };
        };
      };
      case (#err (#msg msg)) {
        throw Error.reject("Parse error on transferFrom:to => " # msg);
      };
    };

    return true;

  };

  // Returns the amount of tokens that `owner` has granter `spender` to spent.
  // See function `approve`.
  public query func allowance(owner : Owner, spender : Owner) : async Nat {
    switch (Hex.decode(owner)) {
      case (#ok ownerBytes) {
        switch(Hex.decode(spender)) {
          case (#ok spender2) {
            let allows = AssocList.find(allowances, ownerBytes, eq);
            switch(allows) {
              case null return 0;
              case (?allows) {
                let xxx = AssocList.find(allows, spender2, eq);
                switch(xxx) {
                  case null return 0;
                  case (?xxx) {
                    return Option.get(?xxx, 0);
                  };
                };
              };
            };
          };
          case (#err (#msg msg)) {
            throw Error.reject("Parse error on allowance:spender => " # msg);
          };
        };
      };
      case (#err (#msg msg)) {
        throw Error.reject("Parse error on allowance:owner => " # msg);
      };
    };
  };

  /**
   * High-Level API
   */

  // Returns the name of the token.
  public query func name() : async Text {
    return "Internet Computer Token";
  };

  // Returns the symbol of the token.
  public query func symbol() : async Text {
    return "ICT";
  };

  // Returns the total token supply.
  public query func totalSupply() : async Nat {
    return N;
  };

  // Returns the token balance of a token owner.
  public query func balanceOf(owner : Owner) : async ?Nat {
    switch (Hex.decode(owner)) {
      case (#ok ownerBytes) {
        return find(ownerBytes);
      };
      case (#err (#msg msg)) {
        throw Error.reject("Parse error: " # msg);
      };
    };
  };

  // Transfers tokens to another token owner.
  public shared {
    caller = caller;
  } func transfer(to : Owner, amount : Nat) : async Bool {
    switch (Hex.decode(to)) {
      case (#ok receiver) {
        let sender = Util.unpack(caller);
        let balance = Option.get(find(sender), 0);
        if (balance < amount) {
          return false;
        } else {
          let difference = balance - amount;
          replace(sender, if (difference == 0) null else ?difference);
          replace(receiver, ?(Option.get(find(receiver), 0) + amount));
          return true;
        };
      };
      case (#err (#msg msg)) {
        throw Error.reject("Parse error: " # msg);
      };
    };
  };

  /**
   * Utilities
   */

  // Finds the token balance of a token owner.
  private func find(ownerBytes : OwnerBytes) : ?Nat {
    return AssocList.find<OwnerBytes, Nat>(balances, ownerBytes, eq);
  };

  // Replaces the token balance of a token owner.
  private func replace(ownerBytes : OwnerBytes, balance : ?Nat) {
    balances := AssocList.replace<OwnerBytes, Nat>(
      balances,
      ownerBytes,
      eq,
      balance,
    ).0;
  };

  // Tests two token owners for equality.
  private func eq(x : OwnerBytes, y : OwnerBytes) : Bool {
    return Array.equal<Word8>(x, y, func (xi, yi) {
      return xi == yi;
    });
  };
};
