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
import Security.ParameterBuilder (runPayoff, PayoffReader)



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


stackelbergGame1 distType actionSpaceAttacker attackerName actionSpaceDefender defenderName = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:
   inputs: ;
   feedback: ;
   operation: nature $ distType;
   outputs: visitorType;
   returns: ;

   inputs: visitorType;
   feedback: ;
   operation: attackerLeader attackerName actionSpaceAttacker;
   outputs: attackerDecision;
   returns: attackerPayoff;

   inputs: attackerDecision;
   feedback: ;
   operation: defenderFollower defenderName actionSpaceDefender;
   outputs: defenderDecision;
   returns: defenderPayoff;

   :----------------------------:

   outputs: visitorType, attackerDecision, defenderDecision;
   returns: attackerPayoff, defenderPayoff;

 |]


payoffIndexer = (!!)

repeatedStage actionSpaceAttacker attackerName actionSpaceDefender defenderName payoffReader1 payoffReader2 params = [opengame|
   inputs : visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: [(payoffIndexer previousPayoffs 0) + calculateCurrAttackerPayoff visitorType attackerDecision defenderDecision, (payoffIndexer previousPayoffs 1) + calculateCurrAttackerPayoff visitorType attackerDecision defenderDecision];
   :----------------------------:

   inputs: visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   operation: attackerLeader attackerName actionSpaceAttacker;
   outputs: attackerDecision;
   returns: (payoffIndexer previousPayoffs 0) + calculateCurrAttackerPayoff visitorType attackerDecision defenderDecision;

   inputs: prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   operation: defenderFollower defenderName actionSpaceDefender;
   outputs: defenderDecision;
   returns: (payoffIndexer previousPayoffs 1) + calculateCurrAttackerPayoff visitorType attackerDecision defenderDecision;
   :----------------------------:

   outputs: visitorType, attackerDecision, defenderDecision;
   returns: previousPayoffs;
|]
   where calculateCurrAttackerPayoff x y z = runPayoff params (payoffReader1 x y z)
         calculateCurrDefenderPayoff x y z = runPayoff params (payoffReader2 x y z)

stochasticTransitionGame transitionFunction payoffFn = [opengame|

   inputs : dec1, dec2, oldState;
   feedback: ;
   :----------------------------:

   inputs: dec1, dec2, oldState;
   feedback: ;
   operation: liftStochastic payoffFn;
   outputs: newState;
   returns: ;

   :----------------------------:

   outputs: dec1, dec2, newState;
   returns: ;
 |]

stackelbergGame1Repeated distType actionSpaceAttacker attackerName actionSpaceDefender defenderName payoffReader1 payoffReader2 params= [opengame|
   inputs : initialAttackerDecision, initialDefenderDecision;
   feedback: ;
   :----------------------------:
   inputs: ;
   feedback: ;
   operation: nature $ distType;
   outputs: visitorType;
   returns: ;


   inputs: visitorType, initialAttackerDecision, initialDefenderDecision;
   feedback: finalPayoffs;
   operation: repeatedStage actionSpaceAttacker attackerName actionSpaceDefender defenderName payoffReader1 payoffReader2 params;
   outputs: passedVisitorType, attackerDecision, defenderDecision;
   returns: oldPayoffs;

   :----------------------------:

   outputs: passedVisitorType, attackerDecision, defenderDecision;
   returns: oldPayoffs;
 |]
