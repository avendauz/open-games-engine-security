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
import IDS.IDSAPayoff (unifyPayoff)
import IDS.IDSModel
import IDS.IDSAStrategies
import IDS.IDSA
import IDS.IDSDeception (deceptionGame)
import IDS.DeceptiveModel
distributionUser = 
  f . priorDistributionAttacker
  where f probAttacker = distFromList [(Attacker, probAttacker), (User, 1 - probAttacker)]
actionSpaceDefender = const [Open, Close]
actionSpaceAttacker = const [Access, DoesNotAccess]

twoIDS idsParams deceptionParams = [opengame|
   inputs: a1, d1, a2, d2, a3, d3;
   feedback: ;
   :----------------------------:

  
   inputs : a1, d1;
   feedback: ;
   operation: ids idsParams "A1" "D1";
   outputs: a1Type, a1New, d1New;
   returns: a1Payoff, d1Payoff;

   inputs : a2, d2;
   feedback: ;
   operation: deceptionGame deceptionParams "A2" "D2";
   outputs: a2Type, a2New, d2New;
   returns: a2Payoff, d2Payoff;

   :----------------------------:
   outputs: a1Type, a1New, d1New, a2Type, a2New, d2New;
   returns: a1Payoff, d1Payoff, a2Payoff, d2Payoff;
 |]
