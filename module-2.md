# Module 2: Understanding Tokens

Modules 2-4 all make use of an **ERC-20** style token, which has already been implemented for you. In this module, you will experiment with this token on the IC by simulating activities such as minting your own token, transferring funds to other users, and leveraging account allowances.

## Understanding

Blockchain-based **tokens** are digital units of value similar to fiat currencies. They are built on top of existing blockchains, which verify the total supply, transfer, and ownership of these tokens. A token can represent anything of value - ranging from financial assets to reputation points in a digital platform - and, as such, could potentially take on many different forms and variations.

There are two main types of tokens:

1. **[Non-fungible tokens](https://en.wikipedia.org/wiki/Non-fungible_token)** (NFTs) represent a single, unique item on a blockchain and are often used to verify ownership of files such as digital artwork or other digital items of value.
2. **Fungible tokens**, which are the kind of tokens that we're discussing today, are indistinguishable from other tokens of the same kind, allowing them to be interchangeable (i.e. one particular kind of token is worth the exact same as other tokens of that same kind).

The main difference between fungible tokens and cryptocurrencies is that cryptocurrencies have their own blockchain while tokens are built on top of an existing blockchain. For example, ETH is a cryptocurrency built on the Ethereum blockchain, but anyone can create their own token on Ethereum to represent a new kind of asset.

[ERC-20](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/) is a standard for creating Fungible Tokens on the Ethereum blockchain that ensures some degree of uniformity in important method signatures.

### ERC-20 Methods

The ERC-20 token standard includes several required methods that all tokens must implement, which provide functionality for checking the total number of tokens in circulation, transferring/checking balances, and establishing a spending allowance for a third-party account. See the ERC-20 [spec](https://eips.ethereum.org/EIPS/eip-20) for more specific information regarding these methods. 

```javascript
// Optional Methods //
function name() public view returns (string)
function symbol() public view returns (string)
function decimals() public view returns (uint8)
// End Optional //
function totalSupply() public view returns (uint256)
function balanceOf(address _owner) public view returns (uint256 balance)
function transfer(address _to, uint256 _value) public returns (bool success)
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
function approve(address _spender, uint256 _value) public returns (bool success)
function allowance(address _owner, address _spender) public view returns (uint256 remaining)
```

### ERC-20 Style Token on the IC

We have provided you with an implementation of this ERC-20 style token in Motoko, originally created [here](https://github.com/enzoh/motoko-token) by DFINITY team member Enzo Haussecker. 

Begin by looking over the [methods](https://github.com/DFINITY-Education/blockchain-and-cryptocurrency/tree/main/vendor/motoko-token#the-token-package) included in this package. Notice the similarities and differences between this implementation and the signatures specified in Solidity (the language of Ethereum) from the ERC-20 spec page. Which methods have we chosen to implement? How do we represent the parameter and return types in Motoko?

Next, take a look at the actual [code implementation](https://github.com/DFINITY-Education/blockchain-and-cryptocurrency/blob/main/vendor/motoko-token/app/Token.mo) of this token. You don't need to understand the specifics of every function, but make sure you can at least answer the following questions:

1. What is an `Owner`, and how is it represented?
2. How do we store the overall token supply and then keep track of individual user balances?
3. What is the `name` and `symbol` for this token implementation?

## Your Task

In this module, you will use the command-line interface to "play around" with this token, experimenting with some of the public methods included in the package.

### Deploying

Let's first begin by deploying this canister to a local network on your computer. Take a look at the [Developer Quick Start Guide](https://sdk.dfinity.org/docs/quickstart/quickstart.html) if you'd like a quick refresher on how to run programs on a locally-deployed IC network. 

Follow these steps to deploy your canisters and launch the front end. If you run into any issues, reference the **Quick Start Guide**, linked above,  for a more in-depth walkthrough.

1. Ensure that your dfx version matches the version shown in the `dfx.json` file by running the following command:

   ```
   dfx --version
   ```

   You should see something along the lines of:

   ```
   dfx 0.6.25
   ```

   If your dfx version doesn't match that of the `dfx.json` file, see the [this guide](https://sdk.dfinity.org/docs/developers-guide/install-upgrade-remove.html#install-version) for help in changing it. 

2. Open a second terminal window (so you can start and view network operations without conflicting with the management of your project) and navigate to the same `\blockchain-and-cryptocurrency` directory.

   In this new window, run:

   ```
   dfx start
   ```

3. Navigate back to your main terminal window (also in the `\blockchain-and-cryptocurrency` directory) and ensure that you have `node` modules available by running:

   ```
   npm install
   ```

4. Finally, execute:

   ```
   dfx deploy
   ```

### Experimenting

Next, let's call some of the Token methods via the CLI. If you need a refresher on calling functions that require arguments, see this [DFINITY SDK](https://sdk.dfinity.org/docs/developers-guide/tutorials/hello-location.html) guide.

