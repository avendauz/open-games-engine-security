{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
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

import OpenGames.Preprocessor hiding (line)
import OpenGames.Engine.BayesianGamesNonState

import Security.ParameterBuilder
import Security.AttackerDefender
import Control.Monad.Reader hiding (lift, void)
import IDS.IDSAPayoff (visitorPayoff, defenderPayoff)
import IDS.IDSModel
import IDS.IDSAStrategies
import Graphics.Rendering.Chart.Easy hiding (Close)
import Graphics.Rendering.Chart.Backend.Diagrams(toFile)

distributionUser = 
  f . priorDistributionAttacker
  where f probAttacker = distFromList [(Attacker, probAttacker), (User, 1 - probAttacker)]

actionSpaceDefender = const [Open, Close]
actionSpaceAttacker = const [Access, DoesNotAccess]

ids params attackerName defenderName = stackelbergGame1Repeated 
            (distributionUser params) actionSpaceAttacker attackerName actionSpaceDefender defenderName (repeatedPayoffGame params visitorPayoff defenderPayoff)

idsRepeatedStage params = repeatedStage actionSpaceAttacker "Alice" actionSpaceDefender "A" (repeatedPayoffGame params visitorPayoff defenderPayoff)
doEvaluation ::
                    IDSParams ()
                    -> List
                         '[[DiagnosticInfoBayesian VisitorType VisitorMove],
                           [DiagnosticInfoBayesian VisitorMove AggregatorMove]]
doEvaluation params = evaluate 
    (stackelbergGame1 (distributionUser params) actionSpaceAttacker "Alice" actionSpaceDefender  "A") 
      (totalGameStrategies params) 
        ((instantiateContext . uncurry3 . unifyPayoff) params)

testDefenderStratAgainstSneakyAttacker p1 p2 = evaluate 
    (stackelbergGame1 (distributionUser exampleData) actionSpaceAttacker "Alice" actionSpaceDefender  "A") 
      (testBothMixed p1 p2 )
        ((instantiateContext . uncurry3 . unifyPayoff) exampleData)

--doSomething = or $ map (generateEquilibrium . (uncurry3 testDefenderStratAgainstSneakyAttacker)) [(a,b,c) | a <- priorAttacker, b <- priorAttacker, c <- [exampleData]]

getAttackerPayoff params = 
  let [a,b] = generatePayoff $ doEvaluation params
  in head a 
getDefenderPayoff params =
  let [a,b] = generatePayoff $ doEvaluation params 
  in head b 


doRepeatedEvaluation params = generateEquilibrium $ 
    evaluate 
        (stackelbergGame1Repeated 
            (distributionUser params) actionSpaceAttacker "Alice" actionSpaceDefender "A" (repeatedPayoffGame params visitorPayoff defenderPayoff))
        strategies
        (instantiateRepeatedContext 0.5 2 strategies (Access, Open) [0, 0] (idsRepeatedStage params))
    where strategies = repeatedStrategies;
          

propEq x = doRepeatedEvaluation x
priorAttacker = [0.01, 0.05 .. 0.95]

generateParams = map probAttacker priorAttacker

payoffs = zip priorAttacker (map getAttackerPayoff generateParams)
payoffs1 = zip priorAttacker (map getDefenderPayoff generateParams)
runExamples ::
                    IDSParams () -> Double 
                    -> List
                         '[[DiagnosticInfoBayesian VisitorType VisitorMove],
                           [DiagnosticInfoBayesian VisitorMove AggregatorMove]]
runExamples params p = evaluate 
    (stackelbergGame1 (distributionUser params) actionSpaceAttacker "Alice" actionSpaceDefender  "A") 
      (totalGameStrategiesMixed p) 
        ((instantiateContext . uncurry3 . unifyPayoff) params)

evaluateRunExamples = map (generateEquilibrium . runExamples exampleData) priorAttacker

evaluateOriginal = map (generateEquilibrium . doEvaluation) (map probAttacker priorAttacker)
wrapperDef p = let [a,b] = generatePayoff $ runExamples exampleData p in head b

wrapperAttacker p = let [a,b] = generatePayoff $ runExamples exampleData p in head a


createAggGraph = toFile def ("graphics/2-player-simple.svg") $ do 
    layout_title .= "2-player security gae"
    setColors [opaque black, opaque blue, opaque red]
    plot (line "Attacker" [payoffs])
    plot (line "Defender" [payoffs1])

createMixedStratGraph = toFile def ("graphics/mixedDefStrats.svg") $ do 
    layout_title .= "2-player security game, mixed defender strat"
    setColors [opaque black, opaque blue, opaque red]
    plot (line "Attacker" [zip priorAttacker (map (wrapperAttacker) priorAttacker)])
    plot (line "Defender" [zip priorAttacker (map wrapperDef priorAttacker)])