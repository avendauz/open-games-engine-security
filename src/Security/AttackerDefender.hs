{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
module Security.AttackerDefender where 

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

distributionUser probAttacker = distFromList [(Attacker, probAttacker), (User, 1 - probAttacker)]


natureVisitor :: Double -> OpenGame
     StochasticOptic StochasticContext '[] '[] () () VisitorType ()
natureVisitor probAttacker = [opengame|
   inputs : ;
   feedback : ;
   :----------------------------:

   inputs : ;
   feedback: ;
   operation : nature (distributionUser probAttacker);
   outputs   : visitorType;
   returns : ;
    :----------------------------:
   outputs : visitorType;
   returns : ;
|]



defenderFollower :: (Ord b, Show a, Show b, Eq a) => String -> (a -> [b]) -> OpenGame
     StochasticOptic
     StochasticContext
     '[Kleisli Stochastic a b]
     '[[DiagnosticInfoBayesian a b]]
     a
     ()
     b
     Double
defenderFollower defenderName getActionSpace = [opengame|

   inputs    :  attackerDecision;
   feedback  :  ;

   :----------------------------:
   inputs    : attackerDecision;
   feedback  :      ;
   operation : dependentDecision defenderName getActionSpace;
   outputs   : defenderDecision;
   returns   : defenderPayoff ;
   :----------------------------:

   outputs   : defenderDecision;
   returns   : defenderPayoff;
|]


attackerLeader attackerName getActionSpace = [opengame| 
    inputs: visitorType ;
    feedback: ;
    :----------------------------:
    inputs : visitorType ;
    feedback: ;
    operation: dependentDecision attackerName getActionSpace;
    outputs: attackerDecision;
    returns : attackerPayoff ;

    :----------------------------:
    outputs: attackerDecision;
    returns : attackerPayoff;

|]

payoffCalculator :: (VisitorType -> VisitorMove -> AggregatorMove -> Stochastic (Double, Double)) -> OpenGame
     StochasticOptic
     StochasticContext
     '[]
     '[]
     (VisitorType, VisitorMove, AggregatorMove)
     (Double, Double)
     ()
     ()
payoffCalculator payoffBuilder = [opengame|
   inputs: visitorType, visitorDecision, defenderDecision;
   feedback : visitorPayoff, defenderPayoff;
   :----------------------------:
   inputs: visitorType, visitorDecision, defenderDecision;
   feedback: ;
   operation: liftStochastic $ uncurry3 payoffBuilder;
   outputs: visitorPayoff, defenderPayoff;
   returns : ;

   :----------------------------:
   outputs: ;
   returns : ;

|]

calculatePayoff _ _ _ = playDeterministically (10, -10)



totalGame :: Double -> OpenGame
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
totalGame prob = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:
   inputs: ;
   feedback: ;
   operation: natureVisitor prob;
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


data VisitorMove = Access | DoesNotAccess deriving (Eq, Ord, Show)
data AggregatorMove = Open | Close deriving (Eq, Ord, Show)
data VisitorType = User | Attacker deriving (Eq, Ord, Show)

actionSpaceDefender = const [Open, Close]
actionSpaceAttacker = const [Access, DoesNotAccess]
defenderLeader defenderName getActionSpace = [opengame|

   inputs    :  ;
   feedback  :  ;

   :----------------------------:
   inputs    : ;
   feedback  :      ;
   operation : dependentDecision defenderName getActionSpace;
   outputs   : defenderDecision;
   returns   : defenderPayoff ;
   :----------------------------:

   outputs   : defenderDecision;
   returns   : defenderPayoff;

 |]

-- attackerDefenderGame getAttackerActionSpace getDefenderActionSpace = [opengame|
--    inputs    :  ;
--    feedback  :  ;

--    :----------------------------:

--    inputs    : ;
--    feedback  :      ;
--    operation : attackerLeader "Alice" getAttackerActionSpace;
--    outputs   : attackerDecision ;
--    returns   : attacker;

--    inputs    : defenseResourceAllocation, visitorDecision;
--    feedback  :      ;
--    operation : defenderFollower "A" getDefenderActionSpace;
--    outputs   : defenderDecision ;
--    returns   : aggregatorPayoff;

-- :----------------------------:

--    outputs   :;
--    returns   : ;
-- |]
