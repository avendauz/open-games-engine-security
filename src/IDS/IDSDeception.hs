{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}

module IDS.IDSDeception where 
import Graphics.Rendering.Chart.Easy
import Graphics.Rendering.Chart.Backend.Diagrams(toFile)
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

import OpenGames.Preprocessor hiding (line)
import OpenGames.Engine.BayesianGamesNonState
import IDS.DeceptiveModel 
import Security.AttackerDefender (stackelbergGame1, stackelbergGame1Repeated, repeatedStage, repeatedPayoffGame)
import IDS.DeceptionPayoff (unifyPayoff, defenderPayoff, visitorPayoff)
import IDS.DeceptionStrategies (deceptiveStrategies, repeatedDeceptiveStrategies, forSureDeceptiveStrategies, forSureRepeatedDeceptiveStrategies)
import Security.ParameterBuilder
import Test.QuickCheck
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
            (distributionActive params) actionSpaceAttacker attackerName actionSpaceDefender defenderName (repeatedPayoffGame params visitorPayoff defenderPayoff)

repeatedDeceptionStage params = repeatedStage actionSpaceAttacker "Alice" actionSpaceDefender "A" (repeatedPayoffGame params visitorPayoff defenderPayoff)

doEvaluation params = 
    evaluate 
        (stackelbergGame1 (distributionActive params) actionSpaceAttacker "Alice" actionSpaceDefender "A") 
            (deceptiveStrategies . deviation $ params) 
                ((instantiateContext . uncurry3 . unifyPayoff) params)

propGame :: DeceptionParams -> Bool
propGame params = generateEquilibrium $ doEvaluation params 

doForSureEvaluation params = 
    evaluate 
        (stackelbergGame1 (distributionActive params) actionSpaceAttacker "Alice" actionSpaceDefender "A") 
            (forSureDeceptiveStrategies) 
                ((instantiateContext . uncurry3 . unifyPayoff) params)
                

doRepeatedEvaluation params rounds = 
    evaluate 
        (deceptionGame params "Alice" "A" )
        strategies
        (instantiateRepeatedContext 0.2 rounds strategies (Suspicious, Regular) [0,0] (repeatedDeceptionStage params))
    where strategies = forSureRepeatedDeceptiveStrategies;

rounds = [0, 1 .. 5]
activeProbabilities = [0, 0.05 .. 1.00]

staticAnalysisP1 params = 
    let [a,b] = generatePayoff $ doForSureEvaluation params
    in head a

staticAnalysisP2 params = 
    let [a,b] = generatePayoff $ doForSureEvaluation params
    in head b


generateParams = map temp activeProbabilities
payoffs = zip activeProbabilities (map staticAnalysisP1 generateParams)
payoffs2 = zip activeProbabilities (map staticAnalysisP2 generateParams)
p1ActivePayoff params rounds = 
    let [a,b] = generatePayoff $ doRepeatedEvaluation params rounds
    in head a

p2ActivePayoff params rounds = 
    let [a,b] = generatePayoff $ doRepeatedEvaluation params rounds
    in head b

p1Payoffs :: DeceptionParams -> [Double]
p1Payoffs params = map (p1ActivePayoff params) rounds

p2Payoffs params = map (p2ActivePayoff params) rounds

plotP1Active :: DeceptionParams -> [(Integer, Double)]
plotP1Active params = zip rounds [-20, -24,-24.8,-24.96,-24.992]
plotP2Active params = zip rounds (p2Payoffs params)
createAggGraph = toFile def ("graphics/temp.svg") $ do 
    layout_title .= "Aggregator payoff"
    setColors [opaque black, opaque blue, opaque red]
    plot (line "Attacker" [payoffs])
    --plot (line "Defender" [payoffs2])
