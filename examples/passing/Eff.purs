module Prelude where

class Monad m where
  ret :: forall a. a -> m a
  (>>=) :: forall a b. m a -> (a -> m b) -> m b

module Eff where

import Prelude

-- Eff Monad

foreign import data Eff :: # ! -> * -> *

foreign import retEff :: forall e a. a -> Eff e a

foreign import bindEff :: forall e a b. Eff e a -> (a -> Eff e b) -> Eff e b 

instance Prelude.Monad (Eff e) where
  ret = retEff
  (>>=) = bindEff

type Pure a = forall e. Eff e a

foreign import runPure :: forall a. Pure a -> a

-- Errors

foreign import data Error :: * -> !

foreign import throwError :: forall e r. e -> Eff (err :: Error e | r) {}

foreign import catchError :: forall e r a. (e -> Eff r a) -> Eff (err :: Error e | r) a -> Eff r a

-- State

foreign import data State :: * -> !

foreign import get :: forall s r. Eff (state :: State s | r) s

foreign import set :: forall s r. s -> Eff (state :: State s | r) {}

foreign import runState :: forall s r a. s -> Eff (state :: State s | r) a -> Eff r { value :: a, state :: s }

-- ST

foreign import data ST :: * -> !

foreign import data STRef :: * -> * -> *

foreign import newSTRef :: forall a h r. a -> Eff (st :: ST h | r) (STRef h a)

foreign import readSTRef :: forall a h r. STRef h a -> Eff (st :: ST h | r) a

foreign import modifySTRef :: forall a h r. (a -> a) -> STRef h a -> Eff (st :: ST h | r) {}

foreign import runST :: forall a r. (forall h. Eff (st :: ST h | r) a) -> Eff r a

-- Tests

test1 = runPure (runState 0 (catchError (\s -> ret 0) 
  (do s <- get 
      throwError "Error!" 
      set (s + 1) 
      ret s)))

test2 = runPure (runST (do
  ref <- newSTRef 0
  modifySTRef (\n -> n + 1) ref 
  readSTRef ref))

