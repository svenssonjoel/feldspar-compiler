{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE UndecidableInstances #-}

-- | Marshaling between Feldspar and C99 types
--
module Feldspar.Compiler.Marshal
  ( SA(..)
  )
  where

import System.Plugins.MultiStage
import Feldspar.Core.Types (IntN(..), WordN(..))

import Data.Int (Int32)
import Data.Word (Word32)
import Data.Complex (Complex(..),realPart,imagPart)
import Data.Default
import Control.Applicative

import Foreign.Ptr
import Foreign.Marshal (free, new, newArray, peekArray)
import Foreign.Storable (Storable(..))
import Foreign.Storable.Tuple ()
import qualified Foreign.Storable.Record as Store

instance Reference IntN        where type Ref IntN        = IntN
instance Reference WordN       where type Ref WordN       = WordN
instance Reference (Complex a) where type Ref (Complex a) = Complex a

instance Marshal IntN        where type Rep IntN        = IntN
instance Marshal WordN       where type Rep WordN       = WordN
instance Marshal (Complex a) where type Rep (Complex a) = Complex a

instance Default (Ptr a) where def = nullPtr

instance (Storable (Rep a), Marshal a) => Marshal [a]
  where
    type Rep [a] = Ptr (SA (Rep a))
    to xs = do
        let len  = fromIntegral $ length xs
        let size = fromIntegral $ sizeOf (undefined :: Rep a)
        ys <- mapM to xs
        buffer <- newArray ys
        new $ SA buffer len size (fromIntegral (len * size))
    from p = peek p >>= go
      where
        go SA{..} = do
          res <- mapM from =<< peekArray (fromIntegral elems) buf
          free buf
          return res


-- | Buffer descriptor for Feldspar arrays
data SA a = SA { buf   :: Ptr a
               , elems :: Int32
               , esize :: Int32
               , bytes :: Word32
               }
  deriving (Eq, Show)

instance Default (SA a) where
    def = SA nullPtr def def def

storeSA :: Storable a => Store.Dictionary (SA a)
storeSA = Store.run $ SA
    <$> Store.element buf
    <*> Store.element elems
    <*> Store.element esize
    <*> Store.element bytes

instance Storable a => Storable (SA a)
  where
    sizeOf    = Store.sizeOf    storeSA
    alignment = Store.alignment storeSA
    peek      = Store.peek      storeSA
    poke      = Store.poke      storeSA

instance Reference (Ptr a)
  where
    type Ref (Ptr a) = Ptr a
    ref   = return
    deref = return

instance (Storable a) => Reference (SA a)
  where
    type Ref (SA a) = Ptr (SA a)
    ref   = new
    deref = peek

storeComplex :: (RealFloat a, Storable a)
             => Store.Dictionary (Complex a)
storeComplex = Store.run $ (:+)
    <$> Store.element realPart
    <*> Store.element imagPart

instance (RealFloat a, Storable a) => Storable (Complex a)
  where
    sizeOf    = Store.sizeOf    storeComplex
    alignment = Store.alignment storeComplex
    peek      = Store.peek      storeComplex
    poke      = Store.poke      storeComplex

instance (Storable (a,b)) => Reference (a,b)
  where
    type Ref (a,b) = Ptr (a,b)
    ref   = new
    deref = peek

instance (Storable (a,b,c)) => Reference (a,b,c)
  where
    type Ref (a,b,c) = Ptr (a,b,c)
    ref   = new
    deref = peek

instance (Storable (a,b,c,d)) => Reference (a,b,c,d)
  where
    type Ref (a,b,c,d) = Ptr (a,b,c,d)
    ref   = new
    deref = peek

instance (Storable (a,b,c,d,e)) => Reference (a,b,c,d,e)
  where
    type Ref (a,b,c,d,e) = Ptr (a,b,c,d,e)
    ref   = new
    deref = peek

instance (Storable (a,b,c,d,e,f)) => Reference (a,b,c,d,e,f)
  where
    type Ref (a,b,c,d,e,f) = Ptr (a,b,c,d,e,f)
    ref   = new
    deref = peek

instance (Storable (a,b,c,d,e,f,g)) => Reference (a,b,c,d,e,f,g)
  where
    type Ref (a,b,c,d,e,f,g) = Ptr (a,b,c,d,e,f,g)
    ref   = new
    deref = peek

instance ( Marshal a
         , Marshal b
         ) => Marshal (a,b)
  where
    type Rep (a,b) = (Rep a,Rep b)
    to (a,b)   = (,) <$> to a <*> to b
    from (a,b) = (,) <$> from a <*> from b

instance ( Marshal a
         , Marshal b
         , Marshal c
         ) => Marshal (a,b,c)
  where
    type Rep (a,b,c) = (Rep a,Rep b,Rep c)
    to (a,b,c)   = (,,) <$> to a <*> to b <*> to c
    from (a,b,c) = (,,) <$> from a <*> from b <*> from c

instance ( Marshal a
         , Marshal b
         , Marshal c
         , Marshal d
         ) => Marshal (a,b,c,d)
  where
    type Rep (a,b,c,d) = (Rep a,Rep b,Rep c,Rep d)
    to (a,b,c,d) =
      (,,,) <$> to a <*> to b <*> to c <*> to d
    from (a,b,c,d) =
      (,,,) <$> from a <*> from b <*> from c <*> from d

instance ( Marshal a
         , Marshal b
         , Marshal c
         , Marshal d
         , Marshal e
         ) => Marshal (a,b,c,d,e)
  where
    type Rep (a,b,c,d,e) = (Rep a,Rep b,Rep c,Rep d,Rep e)
    to (a,b,c,d,e) =
      (,,,,) <$> to a <*> to b <*> to c <*> to d <*> to e
    from (a,b,c,d,e) =
      (,,,,) <$> from a <*> from b <*> from c <*> from d <*> from e

instance ( Marshal a
         , Marshal b
         , Marshal c
         , Marshal d
         , Marshal e
         , Marshal f
         ) => Marshal (a,b,c,d,e,f)
  where
    type Rep (a,b,c,d,e,f) = (Rep a,Rep b,Rep c,Rep d,Rep e,Rep f)
    to (a,b,c,d,e,f) =
      (,,,,,) <$> to a <*> to b <*> to c <*> to d <*> to e <*> to f
    from (a,b,c,d,e,f) =
      (,,,,,) <$> from a <*> from b <*> from c <*> from d <*> from e <*> from f

instance ( Marshal a
         , Marshal b
         , Marshal c
         , Marshal d
         , Marshal e
         , Marshal f
         , Marshal g
         ) => Marshal (a,b,c,d,e,f,g)
  where
    type Rep (a,b,c,d,e,f,g) = (Rep a,Rep b,Rep c,Rep d,Rep e,Rep f,Rep g)
    to (a,b,c,d,e,f,g) =
      (,,,,,,) <$> to a <*> to b <*> to c <*> to d <*> to e <*> to f <*> to g
    from (a,b,c,d,e,f,g) =
      (,,,,,,) <$> from a <*> from b <*> from c <*> from d <*> from e <*> from f <*> from g

