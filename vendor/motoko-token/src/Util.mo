/**
 * Module     : Util.mo
 * Copyright  : 2020 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Iter "mo:base/Iter";
import Prim "mo:prim";

module Util {
  public func unpack(principal : Principal) : [Word8] {
    return Iter.toArray(Prim.blobOfPrincipal(principal).bytes());
  };
};
