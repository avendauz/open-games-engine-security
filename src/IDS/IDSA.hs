{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
module IDS.IDSA where 

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

import           Data.Tuple.Extra (uncurry3)

import OpenGames.Preprocessor
import OpenGames.Engine.BayesianGamesNonState

import Security.ParameterBuilder
import Security.AttackerDefender

import Control.Monad.Reader hiding (lift, void)
import Examples.Staking.AndGateMarkov (attackerStrategy)

data HoneypotAllocation = HighInteractionHP | LowInteractionHP | Normal deriving (Eq, Show)

data VisitorMove = Access | DoesNotAccess deriving (Eq,Ord, Show)

data VisitorType = Attacker | User deriving (Eq, Ord, Show)

data AggregatorMove = Open | Close deriving (Eq, Ord, Show)

actionSpaceDefender = const [Open, Close]
actionSpaceAttacker = const [Access, DoesNotAccess]

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

exampleData = IDSParams {
    probDetected = 0.2,
    costOfAttack = 20,
    costOfDefense = 10,
    attackImpact = 10,
    priorDistributionDefender = 0.5, 
    priorDistributionAttacker = 0.5,
    computingResources = 100,
    basePayoff = 100,
    computationReductionUnderAttack = 70
}
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

distributionUser probAttacker = distFromList [(Attacker, probAttacker), (User, 1 - probAttacker)]

visitorStrategy :: Kleisli Stochastic VisitorType VisitorMove
visitorStrategy = Kleisli (\case {
    Attacker -> playDeterministically Access;
    User -> playDeterministically Access
})

defenderStrategy :: Kleisli Stochastic VisitorMove AggregatorMove
defenderStrategy = Kleisli (\case {
    Access -> playDeterministically Open;
    DoesNotAccess -> playDeterministically Close;
})


totalGame :: Double -> OpenGame
     StochasticOptic
     StochasticContext
     '[Kleisli Stochastic VisitorType VisitorMove,
       Kleisli Stochastic VisitorMove AggregatorMove]
     '[[DiagnosticInfoBayesian VisitorType VisitorMove],
       [DiagnosticInfoBayesian VisitorMove AggregatorMove]]
     ()
     ()
     ()
     ()
totalGame prob = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:
   inputs: ;
   feedback: ;
   operation: nature $ distributionUser prob;
   outputs: visitorType;
   returns: ;

   inputs: visitorType;
   feedback: ;
   operation: attackerLeader "Alice" actionSpaceAttacker;
   outputs: attackerDecision;
   returns: runPayoff exampleData $ visitorPayoff visitorType attackerDecision defenderDecision;

   inputs: attackerDecision;
   feedback: ;
   operation: defenderFollower "A" actionSpaceDefender;
   outputs: defenderDecision;
   returns: runPayoff exampleData $ defenderPayoff visitorType attackerDecision defenderDecision;

   :----------------------------:

   outputs: ;
   returns: ;

 |]

totalGameOpen :: Double -> OpenGame
     StochasticOptic
     StochasticContext
     '[Kleisli Stochastic VisitorType VisitorMove,
       Kleisli Stochastic VisitorMove AggregatorMove]
     '[[DiagnosticInfoBayesian VisitorType VisitorMove],
       [DiagnosticInfoBayesian VisitorMove AggregatorMove]]
     ()
     ()
     (VisitorType, VisitorMove, AggregatorMove)
     (Double, Double)
totalGameOpen prob = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:
   inputs: ;
   feedback: ;
   operation: nature $ distributionUser prob;
   outputs: visitorType;
   returns: ;

   inputs: visitorType;
   feedback: ;
   operation: attackerLeader "Alice" actionSpaceAttacker;
   outputs: attackerDecision;
   returns: attackerPayoff;

   inputs: attackerDecision;
   feedback: ;
   operation: defenderFollower "A" actionSpaceDefender;
   outputs: defenderDecision;
   returns: defenderPayoff;

   :----------------------------:

   outputs: visitorType, attackerDecision, defenderDecision;
   returns: attackerPayoff, defenderPayoff;

 |]


totalGameStrategies = visitorStrategy ::- defenderStrategy ::- Nil


payoffContext :: StochasticContext
  () () (VisitorType, VisitorMove, AggregatorMove) (Double, Double)
payoffContext = StochasticContext (pure ((),())) 
  (\_ (a,b,c) -> playDeterministically (runPayoff exampleData $ visitorPayoff a b c, runPayoff exampleData $ defenderPayoff a b c)
    )