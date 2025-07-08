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
data HoneypotAllocation = HighInteractionHP | LowInteractionHP | Normal deriving (Eq, Show)

data VisitorMove = Access | DoesNotAccess deriving (Eq,Show)

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
    getName :: () -> String
    
}

class ModelBuilder a where 


data IDSParams = IDSParams {
   probDetected :: Double,
   costOfAttack :: Double,
   costOfDefense :: Double,
   computationReductionUnderAttack :: Double,
   attackImpact :: Double,
   priorDistributionDefender :: Double,
   priorDistributionAttacker :: Double,
   activeDefenseFactor :: Double
}

data BlockchainModelParams = BlockchainModelParams {
    networkCoefficient :: Double,
    something :: Double
}

data PC observes responds params = PC {
    name :: String,
    calculatePayoff :: params -> Double,
    getStrategy :: Kleisli Stochastic observes responds
}

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


