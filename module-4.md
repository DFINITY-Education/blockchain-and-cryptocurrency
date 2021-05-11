# Module 4: More Payment Channels & Off-Chain Transactions

In this module, you will continue your implementation of the payment channel by adding the ability for users to close an open payment channel. After completing the payment channel, you will experiment with more off-chain transactions that take advantage of the methods you implemented.

## Understanding

Remember that, due to the off-chain nature of payment channels, none of the transactions actually result in balance changes for either user (other than the funds locked in escrow). If Alice pays Bob through a payment channel, Bob's balance doesn't increase until both parties decide to "close" the payment channel. At the time of the payment channel closing, all prior transactions are tallied and one final transaction representing their sum is committed to the blockchain.

In order for a payment channel to close, one of two conditions must be satisfied:

1. Both users agree to close the payment channel.
2. One user wants to close the payment channel and initiates a forced waiting period. They have the ability to close the payment channel once this waiting period is over, even if the other user doesn't want to.

This means that both users can close a payment channel immediately if they want to, but with only one user requesting a close then they must wait a predetermined period of time before the channel closes.

## Your Task

In this exercise, you will implement methods that enable users to close payment channels that they previously opened, employing the two conditions mentioned above in your solution. Once you complete this, you will have a functional payment channel!

You may be wondering how users actually transact on said channel, and you'd be right to! We've decided to implement a small tool that takes care of that for you, as that isn't the focus of this activity. Note, however, that the payment channel system we're creating is agnostic to the way in which off-chain transactions within the channel are processed.

### Code Understanding

We're using the same starter code in **`main.mo`** that we did in [Module 3](#module-3.md) - please re-read the "code understanding" portion of that module if you'd like a little review. You should have already implemented `setup()` and `addFunds()`, enabling users to create new payment channels and contribute funds to said channels. 

### Specification

**Task:** Complete the implementation of the `beginClosingChannel()` and `finalizeClosingChannel()` methods in `main.mo`.

**`beginClosingChannel()`** initiates the channel closing process for an open channel between the method caller and `counterpart`. `tx` represents the final transaction amount (the result of summing all transactions in the payment channel) that one user owes another. `signedAttestation` ... After this method is called, a "waiting period" is initiated, represented by the `ttl` field in the `PaymentChannel` type, that signals when the payment channel will close.

* After retrieving the payment channel between the two users, first check that it is not already in the closing process. If it is, return the `#paymentChannelClosing` error.
* Next, ensure that the `tx` doesn't exceed the total amount that both users initially allocated to the payment channel. If so, return the `#invalidTx` error.
* Otherwise, update the `PaymentChannel` in `paymentChannels` such that its `closing` value is `true`, the `closingUser` is the method caller, and the `ttl` is the current time (`Time.now()`) plus 3,600 * 1,000,000 nanoseconds
* If no such payment channel exists, return the `#paymentDoesNotExist` error

**`finalizeClosingChannel()`**  closes the payment channel between the caller and the `counterparty`. It is either called by the other user that *didn't* initiate the closing process (via a prior call to `beginClosingChannel()`) or by the same user who initiated the closing process *after* the `ttl` has expired. Any other calls to this method should be rendered invalid.

* Errors: if the payment channel doesn't exist, return `#paymentDoesNotExist` . Additionally, return `#paymentChannelNotClosing` if the payment channel is not currently in the state of `closing`.
* This method call should be rendered invalid if the caller is the same as the user who initiated the closing process *and* we have not yet reached the specified `ttl`, in which case you should return the `invalidFinalize` error
  * Otherwise, delete the payment channel
  * Once the payment channel has been deleted, complete the specified final transaction stored in `tx` by making a call to the `transferFrom` method in the `Token` canister.



