## The Hex Package

[![Build Status](https://github.com/enzoh/motoko-hex/workflows/build/badge.svg)](https://github.com/enzoh/motoko-hex/actions?query=workflow%3Abuild)

This package implements hexadecimal encoding and decoding routines for the Motoko programming language.

### Prerequisites

- [DFINITY SDK](https://sdk.dfinity.org/docs/download.html) v0.5.11
- [Vessel](https://github.com/kritzcreek/vessel/releases/tag/v0.4.1) v0.4.1 (Optional)

### Usage

Encode an array of unsigned 8-bit integers in hexadecimal format.
```motoko
public func encode(array : [Word8]) : Text
```

Decode an array of unsigned 8-bit integers in hexadecimal format.
```motoko
public func decode(text : Text) : Result<[Word8], DecodeError> 
```
