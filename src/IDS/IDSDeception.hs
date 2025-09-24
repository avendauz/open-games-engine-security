{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}

module IDS.IDSDeception where 

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
import IDS.DeceptiveModel 
import Security.AttackerDefender (stackelbergGame1, stackelbergGame1Repeated, repeatedStage)
import IDS.DeceptionPayoff (unifyPayoff, defenderPayoff, visitorPayoff)
import IDS.DeceptionStrategies (deceptiveStrategies, repeatedDeceptiveStrategies, forSureDeceptiveStrategies, forSureRepeatedDeceptiveStrategies)
import Security.ParameterBuilder
{-
Deceptive Attack and Defense Game in
Honeypot-Enabled Networks for
the Internet of Things
-}
distributionActive :: DeceptionParams -> Stochastic DeceptiveType
distributionActive = 
    f . probActive
    where f prob = distFromList [(Active, prob), (Passive, 1 - prob)]

actionSpaceAttacker = const [Normal, Suspicious]

actionSpaceDefender = const [Regular, Honeypot]


deceptionGame params attackerName defenderName = stackelbergGame1Repeated 
            (distributionActive params) actionSpaceAttacker attackerName actionSpaceDefender defenderName (visitorPayoff) (defenderPayoff) params

repeatedDeceptionStage = repeatedStage actionSpaceAttacker "Alice" actionSpaceDefender "A" (visitorPayoff) (defenderPayoff)

doEvaluation params = 
    evaluate 
        (stackelbergGame1 (distributionActive params) actionSpaceAttacker "Alice" actionSpaceDefender "A") 
            (deceptiveStrategies . deviation $ params) 
                ((instantiateContext . uncurry3 . unifyPayoff) params)

doForSureEvaluation params = 
    evaluate 
        (stackelbergGame1 (distributionActive params) actionSpaceAttacker "Alice" actionSpaceDefender "A") 
            (forSureDeceptiveStrategies) 
                ((instantiateContext . uncurry3 . unifyPayoff) params)
                
-- repeated version
doRepeatedEvaluation :: DeceptionParams -> IO ()
doRepeatedEvaluation params = generateOutput $ 
    evaluate 
        (deceptionGame params "Alice" "A" )
        strategies
        (instantiateRepeatedContext 0.2 5 strategies (Suspicious, Regular) [0,0] (repeatedDeceptionStage params))
    where strategies = forSureRepeatedDeceptiveStrategies;
