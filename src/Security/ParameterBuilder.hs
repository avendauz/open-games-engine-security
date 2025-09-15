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

extractContinuation :: StochasticOptic s (Double, Double) a (Double, Double) -> s -> (Double,Double) -> Stochastic (Double, Double)
extractContinuation (StochasticOptic v u) x p = do
  (z,_) <-  v x
  u z p

extractNextState :: StochasticOptic s t a b -> s -> Stochastic a
extractNextState (StochasticOptic v _) x = do
  (z,a) <- v x
  pure a

repeatedContinuationPayoffs :: Double -> Integer
  -> List '[Kleisli Stochastic a y, Kleisli Stochastic b z]
  -> i
  -> (Double, Double)
  -> OpenGame
     StochasticOptic
     StochasticContext
     '[Kleisli Stochastic a y, Kleisli Stochastic b z]
     '[[DiagnosticInfoBayesian a y], [DiagnosticInfoBayesian b z]]
     i
     (Double, Double)
     i
     (Double, Double)
  -> Stochastic (Double, Double)
repeatedContinuationPayoffs discountFactor iterator strat action (r1, r2) game 
  | iterator == 1 = pure (r1,r2)
  | otherwise     = do
      (r1',r2') <- extractContinuation (execute strat) action (r1, r2)
      actionNew <-  nextState strat action
      repeatedContinuationPayoffs discountFactor (pred iterator) strat actionNew (r1'*discountFactor,r2'*discountFactor) game 
  where execute = play game 
        nextState strat' = extractNextState (execute strat')




instantiateRepeatedContext :: Double -> Integer
  -> List '[Kleisli Stochastic a y, Kleisli Stochastic b z]
  -> s
  -> OpenGame
     StochasticOptic
     StochasticContext
     '[Kleisli Stochastic a y, Kleisli Stochastic b z]
     '[[DiagnosticInfoBayesian a y], [DiagnosticInfoBayesian b z]]
     i
     (Double, Double)
     i
     (Double, Double)
  -> StochasticContext s t i (Double, Double)
instantiateRepeatedContext discountFactor iterator strat initialAction game = 
    StochasticContext (pure ((),initialAction)) (\_ action -> repeatedContinuationPayoffs discountFactor iterator strat action (0,0) game)



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


