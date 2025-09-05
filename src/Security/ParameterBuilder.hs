{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE FlexibleInstances #-}



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

import           Control.Monad.Reader
import Data.Tuple.Extra (uncurry3)
import GHC.Float (asinDouble)

type PayoffReader a = Reader a Double

type GeneratePayoffReader a b = a -> PayoffReader b

runPayoff :: a -> PayoffReader a -> Double
runPayoff params reader = runReader reader params


data Player params x y = CreatePlayer {
    generateOpenGame :: params -> StochasticBayesianOpenGame '[Kleisli Stochastic x y] '[[DiagnosticInfoBayesian x y]] x () y Double,
    getName :: () -> String,
    getPayoff :: params -> Double,
    getStrategy :: Kleisli Stochastic x y
}




type AttackerGame a b = OpenGame
     StochasticOptic
     StochasticContext
     '[Kleisli Stochastic a b]
     '[[DiagnosticInfoBayesian a b]]
     a
     ()
     b
     Double

data SecurityInteraction a b c d = SecurityInteraction {


    attacker :: OpenGame
     StochasticOptic
     StochasticContext
     '[Kleisli Stochastic a b]
     '[[DiagnosticInfoBayesian a b]]
     a
     ()
     b
     Double,

     defender :: OpenGame
     StochasticOptic
     StochasticContext
     '[Kleisli Stochastic c d]
     '[[DiagnosticInfoBayesian a b]]
     a
     ()
     b
     Double
}


-- closeGame :: OpenGame
--      StochasticOptic
--      StochasticContext
--      a
--      b
--      ()
--      ()
--      c
--      d -> List b
-- closeGame game = 

data BlockchainModelParams = BlockchainModelParams {
    networkCoefficient :: Double,
    something :: Double
} deriving (Show)


{-

Maybe we can have a builder pattern around the params. Each builder needs to know what to do with the params (like how to calculate payoff, etc.

We also need a way of constructively, declaratively designing these problems. 





-}
-- buildAgent :: (Eq x, Show x, Ord y, Show y) => a -> StochasticBayesianOpenGame '[Kleisli Stochastic x y] '[[DiagnosticInfoBayesian x y]] x () y Double
-- buildAgent ()

--data family StrategySpace a b
--newtype instance StrategySpace VisitorMove HoneypotAllocation = DefenderStrategy (Kleisli Stochastic VisitorMove HoneypotAllocation)

--data family StrategySpace a b = Strategy Kleisli Stochastic a b

--data instance DefenderStrategy = StrategySpace VisitorMove HoneypotAllocation

-- temp :: StrategySpace VisitorMove HoneypotAllocation
-- temp = Strategy $ Kleisli (\case {
--     Access -> playDeterministically HighInteractionHP;
--     DoesNotAccess -> playDeterministically Normal;
-- })


-- observes, responds are in scope for the game that we introduce, PayoffConfig contains all externals
-- class PlayerConfig observes responds params where 
--     calculatePayoff :: observes -> responds -> params -> Double
--     getStrategy :: params -> Kleisli Stochastic observes responds

-- instance PlayerConfig VisitorMove HoneypotAllocation (TempParams HoneypotAllocation) where 

--     calculatePayoff visitorMove x = costOfAttack x

--     getStrategy = Kleisli (\case {
--         Access -> playDeterministically HighInteractionHP;
--         DoesNotAccess -> playDeterministically HighInteractionHP
--     })


