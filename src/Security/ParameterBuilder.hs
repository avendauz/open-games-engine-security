{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}




module Security.ParameterBuilder where

import OpenGames.Engine.Engine hiding (StochasticStatefulOptic
                                      , StochasticStatefulBayesianOpenGame(..)
                                      , Agent(..)
                                      , dependentDecision
                                      , dependentEpsilonDecision
                                      , fromFunctions
                                      , fromLens
                                      , uniformDist
                                      , distFromList
                                      , pureAction
                                      , playDeterministically
                                      , discount
                                      , nature
                                      )
import OpenGames.Preprocessor
import OpenGames.Engine.BayesianGamesNonState
import Test.QuickCheck

import OpenGames.Engine.Engine hiding (StochasticStatefulOptic
                                      , StochasticStatefulBayesianOpenGame(..)
                                      , Agent(..)
                                      , dependentDecision
                                      , dependentEpsilonDecision
                                      , fromFunctions
                                      , fromLens
                                      , uniformDist
                                      , distFromList
                                      , pureAction
                                      , playDeterministically
                                      , discount
                                      , nature
                                      )

import           Control.Monad.Reader hiding (lift)
import Control.Monad.Trans.Reader
import Data.Tuple.Extra (uncurry3)
import GHC.Float (asinDouble)
import Data.Bifunctor
type PayoffReader a = Reader a Double
type GeneratePayoffReader a b = a -> PayoffReader b

runPayoff :: a -> PayoffReader a -> Double
runPayoff params reader = runReader reader params

instantiateContext f = StochasticContext (pure ((), ())) (\_ x -> playDeterministically $ f x)

extractContinuation :: StochasticOptic s [Double] a [Double] -> s -> [Double] -> Stochastic [Double]
extractContinuation (StochasticOptic v u) x p = do
  (z,_) <-  v x
  u z p

extractNextState :: StochasticOptic s t a b -> s -> Stochastic a
extractNextState (StochasticOptic v _) x = do
  (z,a) <- v x
  pure a

repeatedContinuationPayoffs :: (Unappend a, Unappend b) => Double -> Integer
  -> List a
  -> i
  -> [Double]
  -> OpenGame StochasticOptic StochasticContext a b i [Double] i [Double]
  -> Stochastic [Double]
repeatedContinuationPayoffs discountFactor iterator strat action curPayoffs game 
  | iterator == 1 = pure curPayoffs
  | otherwise     = do
      newPayoffs <- extractContinuation (execute strat) action curPayoffs
      actionNew <-  nextState strat action
      repeatedContinuationPayoffs discountFactor (pred iterator) strat actionNew (map (*discountFactor) newPayoffs) game 
  where execute = play game 
        nextState strat' = extractNextState (execute strat')


instantiateRepeatedContext :: (Unappend a, Unappend b) => Double -> Integer
  -> List a
  -> s
  -> [Double]
  -> OpenGame
     StochasticOptic
     StochasticContext
     a
     b
     i
     [Double]
     i
     [Double]
  -> StochasticContext s t i [Double]
instantiateRepeatedContext discountFactor iterator strat initialAction initialPayoff game = 
    StochasticContext (pure ((),initialAction)) (\_ action -> repeatedContinuationPayoffs discountFactor iterator strat action initialPayoff game)




repeatedPayoffGame params attackerPayoffReader defenderPayoffReader = [opengame|

   inputs: (visitorType, attackerDecision, defenderDecision);
   feedback: ;
   :----------------------------:
   inputs : (visitorType, attackerDecision, defenderDecision);
   feedback: ;
   operation: liftStochastic $ calculatePayoff;
   outputs: newAttackerPayoff, newDefenderPayoff;
   returns: ;

   :----------------------------:
   outputs: newAttackerPayoff, newDefenderPayoff;
   returns: ;

 |] where 
        calculatePayoff inputs = 
            playDeterministically $ join bimap (runPayoff params) (attackerPayoffReader inputs, defenderPayoffReader inputs)



{-

Maybe we can have a builder pattern around the params. Each builder needs to know what to do with the params (like how to calculate payoff, etc.

We also need a way of constructively, declaratively designing these problems. 


-}


