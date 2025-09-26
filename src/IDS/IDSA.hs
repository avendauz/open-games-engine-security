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
import IDS.IDSAPayoff (visitorPayoff, defenderPayoff)
import IDS.IDSModel
import IDS.IDSAStrategies

distributionUser = 
  f . priorDistributionAttacker
  where f probAttacker = distFromList [(Attacker, probAttacker), (User, 1 - probAttacker)]
actionSpaceDefender = const [Open, Close]
actionSpaceAttacker = const [Access, DoesNotAccess]

ids params attackerName defenderName = stackelbergGame1Repeated 
            (distributionUser params) actionSpaceAttacker attackerName actionSpaceDefender defenderName (visitorPayoff) (defenderPayoff) params

idsRepeatedStage = repeatedStage actionSpaceAttacker "Alice" actionSpaceDefender "A" (visitorPayoff) (defenderPayoff) 
doEvaluation :: IDSParamsSimple -> IO ()
doEvaluation params = generateOutput $ 
  evaluate 
    (stackelbergGame1 (distributionUser params) actionSpaceAttacker "Alice" actionSpaceDefender  "A") 
      (totalGameStrategies params) 
        ((instantiateContext . uncurry3 . unifyPayoff) params)


doRepeatedEvaluation :: IDSParamsSimple -> IO ()
doRepeatedEvaluation params = generateOutput $ 
    evaluate 
        (stackelbergGame1Repeated 
            (distributionUser params) actionSpaceAttacker "Alice" actionSpaceDefender "A" (visitorPayoff) (defenderPayoff) params)
        strategies
        (instantiateRepeatedContext 0.9 2 strategies (Access, Open) [0, 0] (idsRepeatedStage params))
    where strategies = repeatedStrategies;
          
