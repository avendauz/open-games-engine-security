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
import Security.AttackerDefender (stackelbergGame1)
import IDS.DeceptionPayoff (unifyPayoff)
import IDS.DeceptionStrategies (deceptiveStrategies)
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

doEvaluation :: DeceptionParams -> IO ()
doEvaluation params = generateOutput $ 
    evaluate 
        (stackelbergGame1 (distributionActive params) actionSpaceAttacker actionSpaceDefender) 
            (deceptiveStrategies . deviation $ params) 
                ((instantiateContext . uncurry3 . unifyPayoff) params)