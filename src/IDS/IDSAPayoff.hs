{-# LANGUAGE LambdaCase #-}

module IDS.IDSAPayoff where 
import Security.ParameterBuilder
import Control.Monad.Reader

import           Data.Tuple.Extra (uncurry3)
import IDS.IDSModel
import Data.Bifunctor
import Control.Applicative
-- payoff module shouldn't know anything about open games ... 

unifyPayoff :: IDSParams -> VisitorType -> VisitorMove -> AggregatorMove -> (Double, Double)
unifyPayoff params visitorType visitorMove aggMove = 
    join bimap (runPayoff params) (visitorPayoff visitorType visitorMove aggMove,defenderPayoff visitorType visitorMove aggMove)

visitorPayoff :: VisitorType -> VisitorMove -> AggregatorMove -> PayoffReader IDSParams
visitorPayoff = \case {
    Attacker -> attackerPayoff ;
    User ->  userPayoff
}

defenderPayoff :: VisitorType -> VisitorMove -> AggregatorMove -> PayoffReader IDSParams
defenderPayoff = \case {
    Attacker -> defenderUnderAttackPayoff ;
    User -> defenderNormalPayoff;
}


attackerPayoff :: VisitorMove -> AggregatorMove -> PayoffReader IDSParams
attackerPayoff Access Open = attackerAccessPayoff
attackerPayoff Access Close = asks costOfAttack
attackerPayoff DoesNotAccess Open = (* (-1)) <$> attackerAccessPayoff
attackerPayoff DoesNotAccess Close = return 0

userPayoff :: VisitorMove -> AggregatorMove -> PayoffReader IDSParams
userPayoff Access Open = do
    computingResources <- asks computingResources
    costOfDefense <- asks costOfDefense
    return $ (computingResources - costOfDefense) / computingResources
userPayoff _ _ = return 0


attackerAccessPayoff :: PayoffReader IDSParams
attackerAccessPayoff =
     do
        costOfAttack <- asks costOfAttack
        basePayoff <- asks basePayoff
        probDetected <- asks probDetected
        return $ (basePayoff - costOfAttack) * (1 - probDetected) - costOfAttack * probDetected           -- room to add lines i.e. here we can put more specific parameter changes

defenderUnderAttackPayoff :: VisitorMove -> AggregatorMove -> PayoffReader IDSParams
defenderUnderAttackPayoff Access Open = defenderAccessPayoff
defenderUnderAttackPayoff Access Close = pure 0
defenderUnderAttackPayoff DoesNotAccess _ = pure 0

defenderNormalPayoff :: VisitorMove -> AggregatorMove -> PayoffReader IDSParams
defenderNormalPayoff Access Open = asks computingResources
defenderNormalPayoff DoesNotAccess Open = asks $ (* (-1)) . computingResources
defenderNormalPayoff _ Close = pure 0

defenderAccessPayoff :: PayoffReader IDSParams
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


-- payoffContext :: StochasticContext
--   () () (VisitorType, VisitorMove, AggregatorMove) (Double, Double)
-- payoffContext = StochasticContext (pure ((),())) 
--   (\_ (a,b,c) -> playDeterministically (runPayoff exampleData $ visitorPayoff a b c, runPayoff exampleData $ defenderPayoff a b c)
--     )

-- TODO: Add quickcheck property checks here for payoff and parameter checks


-- evaluateReader :: Reader IDSParams 
-- evaluateReader = do 
--     probAttacker <- asks priorDistributionAttacker    -- can come from outside
--     strats <- asks totalGameStrategies 
--     payoff <- asks unifyPayoff
--     let game = totalGameOpen probAttacker
--     let context = instantiateContext payoff
--     return $ evaluate game strats context