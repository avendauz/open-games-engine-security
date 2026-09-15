{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}


module Security.BiasedCoin where 

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

data Coin = Heads | Tails deriving (Eq, Ord, Show)
data PlayerGuess = WasHeads | WasTails deriving (Eq, Ord, Show)
data UserType = Normal | Adversary deriving (Eq, Ord, Show )
data Move = Accept | Reject deriving (Eq, Ord, Show)
guesserPayoff Heads WasHeads = 1
guesserPayoff Heads WasTails = 0
guesserPayoff Tails WasHeads = 0
guesserPayoff Tails WasTails = 1

coinFlip = distFromList [((Heads, Heads), 5/16), ((Tails, Tails), 5/16), ((Heads, Tails), 3/16), ((Tails, Heads), 3/16)]

-- simpleProb :: Numeric.Probability.Distribution.T Double (Coin, Coin)
-- simpleProb = distFromList [((Heads, Heads), 5/16), ((Tails, Tails), 5/16), ((Heads, Tails), 3/16), ((Normal), 3/16)]
guesserStrategy = Kleisli $ \case {
    -- Heads -> distFromList [(WasHeads, 0.5), (WasTails, 0.5)];
    -- Tails -> distFromList [(WasHeads, 0.5), (WasTails, 0.5)]
    Heads -> playDeterministically WasHeads;
    Tails -> playDeterministically WasTails
} 

-- defenderStrategy = Kleisli $ \case {
--     Attacker -> playDeterministically Reject; 

-- }

badGuesserStrategy = Kleisli $ \case {
    Heads -> distFromList [(WasHeads, 0.5), (WasTails, 0.5)];
    Tails -> distFromList [(WasHeads, 0.5), (WasTails, 0.5)]
} 
biasedCoin = [opengame|

   inputs : ;
   feedback: ;
   :----------------------------:

   inputs: ;
   feedback: ;
   operation: nature coinFlip;
   outputs: (coinSecret, coinObserved);
   returns: ;

   inputs: coinObserved;
   feedback: ;
   operation: dependentDecision "guesser" (const [WasHeads, WasTails]);
   outputs: guess;
   returns: guesserPayoff coinSecret guess;

   :----------------------------:

   outputs: ;
   returns: ;



|]

-- maximization = [opengame|

--    inputs : ;
--    feedback: ;
--    :----------------------------:

--    inputs: ;
--    feedback: ;
--    operation: nature simpleProb;
--    outputs: attackerType;
--    returns: ;

--    inputs: attackerType;
--    feedback: ;
--    operation: dependentDecision "defender" (const [Accept, Reject]);
--    outputs: defense;
--    returns: guesserPayoff attackerType defense;

--    :----------------------------:

--    outputs: ;
--    returns: ;



-- |]

runGame strat = evaluate biasedCoin (strat ::- Nil) void

contextPlayer ::- Nil = runGame guesserStrategy
-- seeContext = map (\x -> x.context (guessersSx.state)) contextPlayer