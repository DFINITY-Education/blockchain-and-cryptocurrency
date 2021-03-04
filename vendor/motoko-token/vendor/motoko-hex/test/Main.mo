/**
 * Module      : Main.mo
 * Description : Unit tests.
 * Copyright   : 2020 DFINITY Stiftung
 * License     : Apache 2.0 with LLVM Exception
 * Maintainer  : Enzo Haussecker <enzo@dfinity.org>
 * Stability   : Stable
 */

import Array "mo:base/Array";
import Hex "../src/Hex";
import Result "mo:base/Result";

actor {

  private type Result<Ok, Err> = Result.Result<Ok, Err>;

  private func eq(a : Word8, b : Word8) : Bool {
    a == b;
  };

  private func unwrap(result : Result<[Word8], Hex.DecodeError>) : [Word8] {
    Result.unwrapOk<[Word8], Hex.DecodeError>(result);
  };

  public func run() {
    let data : [Word8] = [
      072, 101, 108, 108, 111, 032, 087, 111,
      114, 108, 100,
    ];
    let expect = #ok data;
    let actual = Hex.decode(Hex.encode(data));
    assert(Array.equal<Word8>(unwrap(expect), unwrap(actual), eq));
  };
};
