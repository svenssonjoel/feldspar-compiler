--
-- Copyright (c) 2009-2011, ERICSSON AB
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
--     * Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the ERICSSON AB nor the names of its contributors
--       may be used to endorse or promote products derived from this software
--       without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--

{-# LANGUAGE GADTs #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Feldspar.Compiler.Backend.C.Options where

import Feldspar.Core.Interpretation (FeldOpts)
import Feldspar.Compiler.Imperative.Representation (Type, Constant)

data Options =
    Options
    { platform          :: Platform
    , printHeader       :: Bool
    , useNativeArrays   :: Bool
    , useNativeReturns  :: Bool
    , frontendOpts      :: FeldOpts
    , safetyLimit       :: Integer -- ^ Threshold to stop when the size information gets lost.
    , nestSize          :: Int -- ^ Indentation size for PrettyPrinting
    }

data Platform = Platform {
    name            :: String,
    types           :: [(Type, String)],
    values          :: [(Type, ShowValue)],
    includes        :: [String],
    varFloating     :: Bool
} deriving (Show)

type ShowValue = Constant () -> String

-- * Renamer data types to avoid cyclic imports.

type Rename = (String, [(Which, Destination)])

data Predicate = Complex | Float | Signed32 | Unsigned32
   deriving Show

data Which = All | Only Predicate
   deriving Show

data WhichType = FunType | ArgType
   deriving Show

data Destination =
    Name String
  | Extend WhichType Platform
  | ExtendRename WhichType Platform String
   deriving Show
