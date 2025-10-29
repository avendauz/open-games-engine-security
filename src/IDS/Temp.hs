{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
module IDS.Temp where 

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

import OpenGames.Preprocessor
import OpenGames.Engine.BayesianGames 

data AttackerMove = Cheat | NotCheat deriving (Eq, Ord, Show)

data DefenderMove = Inspect | NoInspect deriving (Eq, Ord, Show)

defenderStrat = Kleisli (const $ distFromList [(Inspect, 0.1), (NoInspect, 0.9)])
--defenderStrat = Kleisli (const $ playDeterministically Inspect)
attackerStrat = Kleisli (const $ distFromList [(Cheat, 0.2), (NotCheat, 0.8)])
--attackerStrat = Kleisli (const $ playDeterministically Cheat)

attackerStratStack = Kleisli (const $ playDeterministically NotCheat)

type StrategiesType = Kleisli Stochastic () DefenderMove

instance Show StrategiesType where 
  show (Kleisli f) = show "my strategy"

generateStrat p = Kleisli (const $ distFromList [(Inspect, p), (NoInspect, 1-p)])

--generateDistribution :: [Stochastic StrategiesType]
generateDistribution = uniformDist $ map generateStrat [0.1, 0.2 .. 1.0]

natureStuff = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:
   inputs: ;
   feedback: ;
   operation: nature (generateDistribution);
   outputs: strategyDelivered;
   returns: ;

   :----------------------------:

   outputs: strategyDelivered;
   returns: ;

 |]
testingNature = distFromList [(Inspect, 0.1), (NoInspect, 0.9)]
testingNatureUni = uniformDist [Inspect, NoInspect]
strats = defenderStrat ::- attackerStrat ::- Nil
testingStackelberg = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:


     inputs: ;
   feedback: ;
   operation: dependentDecision "Bob" (const [Inspect, NoInspect]);
   outputs: defenderDecision;
   returns: fst $ payoffs defenderDecision attackerDecision;
   inputs: ;
   feedback: ;
   operation: dependentDecision "Alice" (const [Cheat, NotCheat]);
   outputs: attackerDecision;
   returns: snd $ payoffs defenderDecision attackerDecision;


   :----------------------------:

   outputs: ;
   returns: ;

 |]

justBob = [opengame|
   inputs : attackerDecision;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: dependentDecision "Bob" (const [Inspect, NoInspect]);
   outputs: defenderDecision;
   returns: fst $ payoffs defenderDecision attackerDecision;

   :----------------------------:

   outputs: defenderDecision;
   returns: ;

 |]

runningBob1 = play justBob (defenderStrat ::- Nil)

justAlice = [opengame|
   inputs : defenderDecision;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: dependentDecision "Alice" (const [Cheat, NotCheat]);
   outputs: attackerDecision;
   returns: snd $ payoffs defenderDecision attackerDecision;
   :----------------------------:

   outputs: ;
   returns: ;

 |]



-- doSomething = generateOutput $ evaluate gameIs testingStackelberg void
--runGame = generateOutput $ evaluate testingStackelberg strats void
runStackGame = generateOutput $ evaluate testingStackelberg (defenderStrat ::- attackerStratStack ::- Nil) void
payoffs :: DefenderMove -> AttackerMove -> (Double, Double)
payoffs Inspect Cheat = (-6, -9)
payoffs Inspect NotCheat = (-1,0)
payoffs NoInspect Cheat = (-10, 1)
payoffs NoInspect NotCheat = (0,0)

payoffs1 :: DefenderMove -> AttackerMove -> (Double, Double)
payoffs1 Inspect Cheat = (1, 1)
payoffs1 Inspect NotCheat = (3,0)
payoffs1 NoInspect Cheat = (0, 0)
payoffs1 NoInspect NotCheat = (2,1)