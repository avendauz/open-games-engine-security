{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}

module IDS.SeparatingEquilibrium where 

-- investigate separating equilibrium in signalling games 


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
                                      , (+++)
                                      )

import           Data.Tuple.Extra (uncurry3)

import OpenGames.Preprocessor hiding (line)
import OpenGames.Engine.BayesianGamesNonState

import Security.ParameterBuilder
import Security.AttackerDefender
import Control.Monad.Reader hiding (lift, void)
import Security.SignallingExample (idGame)

data GiveTypes = T1 | T2 deriving (Eq, Ord, Show)
data FirstMover = L | R deriving (Eq, Ord, Show)
data SecondMover = U | D deriving (Eq, Ord, Show)
natureMove = nature $ distFromList [(T1, 0.6), (T2, 0.4)]

payoffsFirstMover :: GiveTypes -> FirstMover -> SecondMover -> Double 
payoffsFirstMover T1 L U = 2
payoffsFirstMover T1 L D = 2
payoffsFirstMover T2 L U = 4
payoffsFirstMover T2 L D = 2
payoffsFirstMover T1 R U = 5
payoffsFirstMover T1 R D = 3
payoffsFirstMover T2 R U = 2
payoffsFirstMover T2 R D = 3

payoffsSecondMover :: GiveTypes -> FirstMover -> SecondMover -> Double 
payoffsSecondMover T1 L U = 1
payoffsSecondMover T1 L D = 0
payoffsSecondMover T2 L U = 0
payoffsSecondMover T2 L D = 1
payoffsSecondMover T1 R U = 4
payoffsSecondMover T1 R D = 1
payoffsSecondMover T2 R U = 0
payoffsSecondMover T2 R D = 1

firstMoverStrat :: Kleisli Stochastic GiveTypes FirstMover
firstMoverStrat = Kleisli (\case {
    T1 -> distFromList [(R, 0.5), (L, 0.5)] ;
    T2 -> playDeterministically R
})
secondMoverStrat :: Kleisli Stochastic FirstMover SecondMover
secondMoverStrat = Kleisli (\case {
    R -> playDeterministically U ; 
    L -> playDeterministically D 
})

signallingGame = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:
   inputs: ;
   feedback: ;
   operation: natureMove;
   outputs: firstMoverType;
   returns: ;

   inputs: firstMoverType;
   feedback: ;
   operation: dependentDecision "first" (const [L,R]);
   outputs: attackerDecision;
   returns: payoffsFirstMover firstMoverType attackerDecision defenderDecision;

   inputs: attackerDecision;
   feedback: ;
   operation: dependentDecision "second" (const [U,D]);
   outputs: defenderDecision;
   returns: payoffsSecondMover firstMoverType attackerDecision defenderDecision;

   :----------------------------:

   outputs: ;
   returns: ;

|]

runGame = evaluate signallingGame (firstMoverStrat ::- secondMoverStrat ::- Nil) void

data EnterOrLeave = Enter | Leave deriving (Eq, Ord, Show)
data FightOrAccom = Fight | Accom deriving (Eq, Ord, Show)
entrantFirstRound = [opengame|

   inputs : ;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: dependentDecision "entrant" (const [Enter, Leave]);
   outputs: firstRound;
   returns: firstRoundPayoff;

   inputs: firstRound;
   feedback: ;
   operation: chooseSubgameFn;
   outputs: chooseSubgame;
   returns: ;

   :----------------------------:

   outputs: chooseSubgame;
   returns: firstRoundPayoff;

|] where chooseSubgameFn = fromFunctions (\r -> case r of {Enter -> Right (); Leave -> Left ()}) id

firstRoundPayoff x = case x of
    Leave -> Left 0
    Enter -> Right 0

firstRoundStrategy :: Kleisli Stochastic () EnterOrLeave
firstRoundStrategy = Kleisli $ const $ playDeterministically Enter

-- exitGameFirstRound = [opengame|

--    inputs : ;
--    feedback: ;
--    :----------------------------:

--    inputs: ;
--    feedback: ;
--    operation: entrantFirstRound;
--    outputs: firstRoundChoice;
--    returns: 2;

--    inputs: firstRoundChoice;
--    feedback: ;
--    operation: combinedGame;
--    outputs: ;
--    returns: entrantPayoff, incumPayoff;

--    inputs: firstRoundChoice;
--    feedback: entrantPayoff, incumPayoff;
--    operation: secondRoundPayoff;
--    outputs: ;
--    returns: ;


--    :----------------------------:

--    outputs: ;
--    returns: ;

-- |] where combinedGame = payoffGame +++ secondRoundGame
--          payoffGame = fromLens (\() -> ()) (\_ _ -> 0)
--          secondRoundPayoff = fromLens id (\(entrant, incum) _ -> playDeterministically . payoffGenerator $ entrant incum)

payoffGenerator Fight Fight = (-3, -1) 
payoffGenerator Fight Accom = (1, -2)
payoffGenerator Accom Accom = (3, 1)
payoffGenerator Accom Fight = (-2, -1)

payoffFirstRound = (0, 2)
secondRoundGame = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: dependentDecision "entrant" (const [Fight, Accom]);
   outputs: entrantDecision;
   returns: entrantPayoff;

   inputs: ;
   feedback: ;
   operation: dependentDecision "incumbent" (const [Fight, Accom]);
   outputs: incumbentDecision;
   returns: incumPayoff;

   inputs: entrantDecision, incumbentDecision;
   feedback: ;
   operation: fromFunctions (\(x, y) -> payoffGenerator x y) id;
   outputs: entrantPayoff, incumPayoff;
   returns: ;

   inputs: ;
   feedback: ;
   operation: fromFunctions (const (2, 0)) id;
   outputs: firstRoundPayoff;
   returns: ;

   :----------------------------:

   outputs: firstRoundPayoff;
   returns: ;

|]


