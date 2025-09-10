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
import IDS.IDSAPayoff (unifyPayoff)
import IDS.IDSModel
import IDS.IDSAStrategies

distributionUser probAttacker = distFromList [(Attacker, probAttacker), (User, 1 - probAttacker)]
actionSpaceDefender = const [Open, Close]
actionSpaceAttacker = const [Access, DoesNotAccess]

-- note that this shouldn't depend on a specific parameter record type, allow the reader to access the respective field
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


doEvaluation :: IDSParams -> IO ()
doEvaluation params = generateOutput $ 
  evaluate 
    (totalGameOpen . priorDistributionAttacker $ params) 
      (totalGameStrategies params) 
        ((instantiateContext . uncurry3 . unifyPayoff) params)



