{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}

module IDS.Temp where 

import OpenGames.Engine.Engine 

import OpenGames.Preprocessor

import Security.ParameterBuilder
import Data.Foldable (maximumBy)
-- import Numeric.Probability.Distribution hiding (lift)

data AttackerMove = Cheat | NotCheat deriving (Eq, Ord, Show)
data DefenderMove = Inspect | NoInspect deriving (Eq, Ord, Show)
data DefenderType = Aggressive | Passive deriving (Eq, Ord,Show)
defenderStrat = Kleisli (const $ distFromList [(Inspect, 0.1), (NoInspect, 0.9)])
offDefenderStrat = Kleisli (const $ distFromList [(Inspect, 0.05), (NoInspect, 0.95)])
--defenderStrat = Kleisli (const $ playDeterministically Inspect)
attackerStrat = Kleisli (const $ distFromList [(Cheat, 0.2), (NotCheat, 0.8)])
--attackerStrat = Kleisli (const $ playDeterministically Cheat)

attackerStratStack = Kleisli (const $ playDeterministically NotCheat)
attackerStratCheat = Kleisli (const $ playDeterministically Cheat)

attackerDishonest = generatePayoff $ evaluate standardGameSequential (defenderStrat ::- attackerStratStack ::- Nil) void

type DefenderStrategies = Kleisli Stochastic DefenderType DefenderMove
type ReactionType = Kleisli Stochastic DefenderMove AttackerMove


instance Show DefenderStrategies where 
  show (Kleisli f) = show "my strategy"

generateStrat p = Kleisli (const $ distFromList [(Inspect, p), (NoInspect, 1-p)])

--generateDistribution :: [Stochastic StrategiesType]
--generateDistribution = uniformDist $ map generateStrat [0.1, 0.2 .. 1.0]

-- natureStuff = [opengame|
--    inputs : ;
--    feedback: ;
--    :----------------------------:
--    inputs: ;
--    feedback: ;
--    operation: nature (generateDistribution);
--    outputs: strategyDelivered;
--    returns: ;

--    :----------------------------:

--    outputs: strategyDelivered;
--    returns: ;

--  |]
testingNature = distFromList [(Inspect, 0.1), (NoInspect, 0.9)]
testingNatureUni = uniformDist [Inspect, NoInspect]
strats = defenderStrat ::- attackerStrat ::- Nil
noAttackStrat = Kleisli (const $ playDeterministically NotCheat)

-- stackelbergEquilbrium leaderStrat followerStrat = f && g 
--   where f = generateEquilibrium $ evaluate followerGameParameterized (followerStrat ::- Nil) (contextFollower leaderStrat)
--         g = generateEquilibrium $ evaluate (standardGameParameterized followerGameParameterized) (leaderStrat ::- followerStrat ::- Nil) void 

-- (cmap identity (play followerGameParameterized (followerStrat ::- Nil)) void)
testGame = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:

   inputs: defenderDecisionAgain;
   feedback: ;
   operation: dependentDecision "Leader" (const [Inspect, NoInspect]);
   outputs: defenderDecision;
   returns: testPayoff defenderDecision defenderDecisionAgain;

   inputs: ;
   feedback: ;
   operation: dependentDecision "Leader" (const [Inspect, NoInspect]);
   outputs: defenderDecisionAgain;
   returns: testPayoff defenderDecision defenderDecisionAgain;
   :----------------------------:

   outputs: ;
   returns: ;

 |]
testPayoff Inspect Inspect = 10
testPayoff Inspect NoInspect = 20
testPayoff NoInspect NoInspect = 15
testPayoff NoInspect Inspect = 5

runTestGame = generateOutput $ evaluate testGame (Kleisli (const $ playDeterministically Inspect) ::- Kleisli (const $ playDeterministically NoInspect) ::- Nil) void

leaderGame = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: dependentDecision "Leader" (const [Inspect, NoInspect]);
   outputs: defenderDecision;
   returns: payoffs;
   :----------------------------:

   outputs: defenderDecision;
   returns: payoffs;

 |]

followerGame = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: dependentDecision "Follower" f;
   outputs: followerDecision;
   returns: snd $ payoffs;
   :----------------------------:

   outputs: followerDecision;
   returns: payoffs;

 |]

f = const [NotCheat]
followerGameSequential = [opengame|
   inputs : defenderDecision;
   feedback: ;
   :----------------------------:

   inputs: defenderDecision;
   feedback: ;
   operation: dependentDecision "Follower" (f);
   outputs: followerDecision;
   returns: snd $ payoffs;
   :----------------------------:

   outputs: followerDecision;
   returns: payoffs;

 |]

followerGameParameterized = [opengame|
   inputs : leaderMove;
   feedback: fst $ payoffs leaderMove followerDecision;
   :----------------------------:

   inputs: leaderMove;
   feedback: ;
   operation: dependentDecision "Follower" (const [Cheat, NotCheat]);
   outputs: followerDecision;
   returns: snd $ payoffs leaderMove followerDecision;
   :----------------------------:

   outputs: ;
   returns: ;

 |]





standardGame = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: leaderGame;
   outputs: leaderDecision;
   returns: fst $ payoffs leaderDecision followerDecision;

   inputs: ;
   feedback: ;
   operation: followerGame;
   outputs: followerDecision;
   returns: payoffs leaderDecision followerDecision;
   :----------------------------:

   outputs: ;
   returns: ;

 |]

standardGameSequential = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: leaderGame;
   outputs: leaderDecision;
   returns: fst $ payoffs leaderDecision followerDecision;

   inputs: leaderDecision;
   feedback: ;
   operation: followerGameSequential;
   outputs: followerDecision;
   returns: payoffs leaderDecision followerDecision;
   :----------------------------:

   outputs: ;
   returns: ;

 |]

standardGameParameterized paramedGame= [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: leaderGame;
   outputs: leaderDecision;
   returns: leaderPayoff;

   inputs: leaderDecision;
   feedback: leaderPayoff;
   operation: paramedGame;
   outputs: ;
   returns: ;
   :----------------------------:

   outputs: ;
   returns: ;

 |]



-- generateFollowerContext :: (Kleisli Stochastic () DefenderMove) -> StochasticContext DefenderMove 
-- testingStackelberg :: OpenGame
--   StochasticOptic
--   StochasticContext
--   (('[Kleisli Stochastic DefenderMove AttackerMove] +:+ '[]) +:+ '[])
--   '[[DiagnosticInfoBayesian DefenderMove AttackerMove]]
--   (Kleisli Stochastic DefenderMove AttackerMove, DefenderType)
--   ()
--   AttackerMove
--   ()
testingStackelberg = [opengame|
   inputs : fixedLeaderDecision;
   feedback: attackerDecision;
   :----------------------------:
   inputs: fixedLeaderDecision;
   feedback: ;
   operation: dependentDecision "Alice" (const [Cheat, NotCheat]);
   outputs: attackerDecision;
   returns: snd $ payoffs fixedLeaderDecision attackerDecision;


   :----------------------------:

   outputs: ;
   returns: ;

 |]

generateMixedStrategies = map (\x -> distFromList [(Inspect, x), (NoInspect, 1-x)]) [0.0, 0.05 .. 1.0]

-- initializeGame = [opengame|
--    inputs : proposedLeaderStrategy, ;
--    feedback: ;
--    :----------------------------:

--    inputs: ;
--    feedback: ; 
--    operation: dependentDecision "Leader" (const [Inspect, NotInspect]);
--    outputs: leaderDecision;
--    returns: fst $ payoffs fixedLeaderDecision attackerDecision;
 
--    inputs: proposedLeaderStrategy;
--    feedback: ; 
--    operation: testingStackelberg ;
--    outputs: attackerDecision;
--    returns: fst $ payoffs fixedLeaderDecision attackerDecision;

--    :----------------------------:

--    outputs: defenderDecision;
--    returns: ;

--  |]

--  something :: (Unappend a, Unappend b, Eq i) => (Kleisli Stochastic () DefenderMove) 
--   -> (OpenGame StochasticOptic StochasticContext a b x  )


-- attempt1 strats = evaluate testingStackelberg (strats ::- reactionSet ::- Nil) c
--     where c = StochasticContext (pure ((), )) (\_ (d,a) -> playDeterministically $ payoffs d a)

-- getPayoff strats x = do 
--         reaction <- extractNextState (play aliceReactionary (reactionSet ::- Nil)) x

--         return $ fst $ payoffs x reaction


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





-- bestResponseStrategy :: Kleisli Stochastic (Kleisli Stochastic () DefenderMove) AttackerMove
-- bestResponseStrategy = Kleisli Stochastic (const id)
-- doSomething = generateOutput $ evaluate testingStackelberg bestResponseStrategy ::- Nil void
--runGame = generateOutput $ evaluate testingStackelberg strats void
--runStackGame = generateOutput $ evaluate testingStackelberg (defenderStrat ::- (reactionSet defenderStrat) ::- Nil) void
--runTest = generateOutput $ evaluate testingStackelberg (defenderStrat ::- attackerStrat ::- Nil) void
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