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

visitorPayoff :: VisitorType -> VisitorMove -> AggregatorMove -> Reader IDSParams Double
visitorPayoff = \case {
    Attacker -> attackerPayoff ;
    User ->  userPayoff
}

defenderPayoff :: VisitorType -> VisitorMove -> AggregatorMove -> Reader IDSParams Double
defenderPayoff = \case {
    Attacker -> defenderUnderAttackPayoff ;
    User -> defenderNormalPayoff;
}


attackerPayoff :: VisitorMove -> AggregatorMove -> Reader IDSParams Double
attackerPayoff Access Open = attackerAccessPayoff
attackerPayoff Access Close = asks costOfAttack
attackerPayoff DoesNotAccess Open = (* (-1)) <$> attackerAccessPayoff
attackerPayoff DoesNotAccess Close = return 0

userPayoff :: VisitorMove -> AggregatorMove -> Reader IDSParams Double
userPayoff Access Open = do
    computingResources <- asks computingResources
    costOfDefense <- asks costOfDefense
    return $ (computingResources - costOfDefense) / computingResources
userPayoff _ _ = return 0

-- data IDSParams = IDSParams {
--    probDetected :: HoneypotAllocation -> Double,
--    costOfAttack :: Double,
--    costOfDefense :: HoneypotAllocation -> Double,
--    attackImpact :: Double,
--    priorDistributionDefender :: Double,
--    priorDistributionAttacker :: Double,
--    computingResources :: Double,
--    basePayoff :: Double
-- } 

attackerAccessPayoff :: Reader IDSParams Double
attackerAccessPayoff =
     do
        costOfAttack <- asks costOfAttack
        basePayoff <- asks basePayoff
        probDetected <- asks probDetected
        return $ (basePayoff - costOfAttack) * (1 - probDetected) - costOfAttack * probDetected           -- room to add lines i.e. here we can put more specific parameter changes

defenderUnderAttackPayoff :: VisitorMove -> AggregatorMove -> Reader IDSParams Double
defenderUnderAttackPayoff Access Open = defenderAccessPayoff
defenderUnderAttackPayoff Access Close = pure 0
defenderUnderAttackPayoff DoesNotAccess _ = pure 0

defenderNormalPayoff :: VisitorMove -> AggregatorMove -> Reader IDSParams Double
defenderNormalPayoff Access Open = asks computingResources
defenderNormalPayoff DoesNotAccess Open = asks $ (* (-1)) . computingResources
defenderNormalPayoff _ Close = pure 0

defenderAccessPayoff :: Reader IDSParams Double
defenderAccessPayoff =
    do
        params <- ask
        costOfDefense <- asks costOfDefense
        probDetection <- asks probDetected
        computingResources <- asks computingResources
        computationReductionUnderAttack <- asks computationReductionUnderAttack
        return $ (computingResources - costOfDefense) * (probDetection + (1 - probDetection) * computationReductionUnderAttack)

calculateExpectedValueOfAttack :: IDSParams -> Double
calculateExpectedValueOfAttack params =
   attackImpact params * (basePayoff params - costOfAttack params) * (1 - probDetected params)
   - costOfAttack params * probDetected params


-- calculateEffectiveService :: IDSParams -> HoneypotAllocation -> Double
-- calculateEffectiveService ps allocation = 
--    (availableComputingResources - costOfDefense ps allocation) / availableComputingResources 

-- payoffAggregator :: IDSParams -> Double
-- payoffAggregator _ _ _ DoesNotAccess _= 0
-- payoffAggregator _ _ Attacker Access Close = 0 -- add discount here, positive payoff for preventing downtime in the future?
-- payoffAggregator _ _ User _ Close = 0      -- could not provide services to users

-- payoffAggregator ps allocation Attacker Access Open = 
--    (availableComputingResources - costOfDefense ps allocation) * probDetected ps allocation
--    + (availableComputingResources - costOfDefense ps allocation) * (1 - probDetected ps allocation) * computationReductionUnderAttack ps allocation

-- payoffAggregator _ Normal User Access Open = availableComputingResources

-- payoffAggregator ps LowInteractionHP User Access Open = availableComputingResources - costOfDefense ps LowInteractionHP

-- payoffAggregator ps HighInteractionHP User Access Open = availableComputingResources - costOfDefense ps HighInteractionHP


data HoneypotAllocation = HighInteractionHP | LowInteractionHP | Normal deriving (Eq, Show)

data VisitorMove = Access | DoesNotAccess deriving (Eq,Show)

data VisitorType = Attacker | User deriving (Eq, Ord, Show)

data AggregatorMove = Open | Close deriving (Eq, Ord, Show)


-- RECORD TYPE FOR HARDCODED VALUES

-- data Parameters a = Parameters {
--    probDetected :: a -> Double,
--    costOfAttack :: Double,
--    costOfDefense :: a -> Double,
--    computationReductionUnderAttack :: a -> Double,
--    attackImpact :: a -> Double,
--    priorDistributionDefender :: Double,
--    priorDistributionAttacker :: Double,
--    activeDefenseFactor :: Double
-- }

data Player params x y = CreatePlayer {
    generateOpenGame :: params -> StochasticBayesianOpenGame '[Kleisli Stochastic x y] '[[DiagnosticInfoBayesian x y]] x () y Double,
    getName :: () -> String,
    getPayoff :: params -> Double,
    getStrategy :: Kleisli Stochastic x y
}

class PayoffBuilder a b where
    calculatePayoff :: a -> (b -> Double)


data IDSParams = IDSParams {
   probDetected :: Double,
   costOfAttack :: Double,
   costOfDefense :: Double,
   attackImpact :: Double,
   priorDistributionDefender :: Double,
   priorDistributionAttacker :: Double,
   computingResources :: Double,
   basePayoff :: Double,
   computationReductionUnderAttack :: Double
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
--      '[Kleisli Stochastic VisitorType VisitorMove,
--        Kleisli Stochastic VisitorMove AggregatorMove]
--      '[[DiagnosticInfoBayesian VisitorType VisitorMove],
--        [DiagnosticInfoBayesian VisitorMove AggregatorMove]]
--      ()
--      ()
--      (VisitorType, VisitorMove, AggregatorMove)
--      (Double, Double) -> OpenGame
--      StochasticOptic
--      StochasticContext
--      '[Kleisli Stochastic VisitorType VisitorMove,
--        Kleisli Stochastic VisitorMove AggregatorMove]
--      '[[DiagnosticInfoBayesian VisitorType VisitorMove],
--        [DiagnosticInfoBayesian VisitorMove AggregatorMove]]
--      ()
--      ()
--      (VisitorType, VisitorMove, AggregatorMove)
--      ()



instance PayoffBuilder IDSParams (VisitorType, VisitorMove, HoneypotAllocation) where
    calculatePayoff params (visitorType, visitorMove, hpAlloc) = 1.0

-- instance PayoffBuilder IDSParams HoneypotAllocation where 
--     calculatePayoff params = (\honeypot -> 1.0)

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


