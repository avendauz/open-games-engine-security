{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
module IDS.CollaborativeIDS where 

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
import IDS.IDSModel
import IDS.IDSAStrategies
import IDS.IDSA
import IDS.IDSDeception (deceptionGame, repeatedDeceptionStage)
import IDS.DeceptiveModel
import IDS.DeceptionStrategies
import IDS.CollaborativeIDSModel 
distributionUser = 
  f . priorDistributionAttacker
  where f probAttacker = distFromList [(Attacker, probAttacker), (User, 1 - probAttacker)]
actionSpaceDefender = const [Open, Close]
actionSpaceAttacker = const [Access, DoesNotAccess]


data CollabIDSParams = Collab {
  a :: IDSParams,
  b :: IDSParams,
  capacity:: Double
}

twoIDS idsParams deceptionParams = [opengame|
   inputs: a1, d1, a2, d2;
   feedback: ;
   :----------------------------:

  
   inputs : a1, d1;
   feedback: ;
   operation: ids idsParams "A1" "D1";
   outputs: a1Type, a1New, d1New;
   returns: [payoffIndexer initialPayoffs 0, payoffIndexer initialPayoffs 1];

   inputs : a2, d2;
   feedback: ;
   operation: deceptionGame deceptionParams "A2" "D2";
   outputs: a2Type, a2New, d2New;
   returns: [payoffIndexer initialPayoffs 2, payoffIndexer initialPayoffs 3];

   :----------------------------:
   outputs: a1Type, a1New, d1New, a2Type, a2New, d2New;
   returns: initialPayoffs;
 |]

doubleRepeatedStage idsParams deceptionParams = [opengame|
 
   inputs : v1, a1, d1, v2, a2, d2;
   feedback: (newIdsGamePayoffs ++ newDeceptionGamePayoffs);
   :----------------------------:

   inputs: v1, a1, d1;
   feedback: newIdsGamePayoffs;
   operation: idsRepeatedStage idsParams ;
   outputs: v1New, a1New, d1New;
   returns: [payoffIndexer oldPayoffs 0, payoffIndexer oldPayoffs 1];

   inputs: v2, a2, d2;
   feedback: newDeceptionGamePayoffs;
   operation: repeatedDeceptionStage deceptionParams;
   outputs: v2New, a2New, d2New;
   returns: [payoffIndexer oldPayoffs 2, payoffIndexer oldPayoffs 3];

   :----------------------------:

   outputs: v1New, a1New, d1New, v2New, a2New, d2New;
   returns: oldPayoffs;
  |]



doCollaborativeIDS :: IDSParams -> DeceptionParams -> IO ()
doCollaborativeIDS idsParams deceptionParams = generateOutput $ 
    evaluate 
        (twoIDS idsParams deceptionParams)
        strategies
        (instantiateRepeatedContext 0.9 5 strategies (Access, Open, Suspicious, Regular) [0,0, 0,0] (doubleRepeatedStage idsParams deceptionParams))
    where strategies = repeatedStrategies +:+ (repeatedDeceptiveStrategies . deviation $ deceptionParams);
