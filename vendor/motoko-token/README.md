## The Token Package

[![Build Status](https://github.com/enzoh/motoko-token/workflows/build/badge.svg)](https://github.com/enzoh/motoko-token/actions?query=workflow%3Abuild)

This package implements a simple ERC-20 style token.

### Prerequisites

- [DFINITY SDK](https://sdk.dfinity.org/docs/download.html) v0.6.0
- [Vessel](https://github.com/kritzcreek/vessel/releases/tag/v0.4.1) v0.4.1 (Optional)

### Usage

Return the name of the token.
```motoko
public query func name() : async Text
```

Return the symbol of the token.
```motoko
public query func symbol() : async Text
```

Return the total token supply.
```motoko
public query func totalSupply() : async Nat
```

Return the token balance of a token owner.
```motoko
public query func balanceOf(owner : Owner) : async ?Nat
```

Transfer tokens to another token owner.
```motoko
public shared func transfer(to : Owner, amount : Nat) : async Bool
```

Allows `spender` to spend `amount` tokens from function caller
```motoko
public shared func approve(spender : Owner, amount : Nat) async Bool
```

Returns the amount of tokens that `spender` can spend from `owner`
```motoko
public query func allowance(owner : Owner, spender : Owner) async Nat
```

Transfer `amount` tokens from `owner` to `to`. Function caller should have permission to do so.
See function `approve`.
```motoko
public shared func transferFrom(owner : Owner, to : Owner, amount : Nat) async Bool
```
