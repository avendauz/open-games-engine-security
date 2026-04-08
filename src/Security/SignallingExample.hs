{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}


module Security.SignallingExample where 

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
    ( dependentDecision,
      distFromList,
      fromLens,
      nature,
      playDeterministically,
      StochasticBayesianOpenGame )
import Security.ParameterBuilder (runPayoff, PayoffReader)
import IDS.IDSModel (VisitorMove(Access, DoesNotAccess))
import Numeric.Probability.Distribution hiding (map)

data Signal = Good | Bad deriving (Eq, Show)
distributionTest = distFromList [(Good, 0.4), (Bad, 0.6)]
actionSpace :: Signal -> [VisitorMove]
actionSpace = const [Access, DoesNotAccess]

payoffFunction :: Signal -> VisitorMove -> Double 
payoffFunction Good Access = 10
payoffFunction Good DoesNotAccess = 12
payoffFunction Bad Access = -10
payoffFunction bad DoesNotAccess = -12

idGame :: StochasticBayesianOpenGame '[] '[] y () y ()
idGame = fromLens id (\_ () -> ())

copyGame :: StochasticBayesianOpenGame '[] '[] b () (b, b) ()
copyGame = fromLens (\x -> (x, x)) (\_ () -> ())

flattenGame = fromLens id (\(_,_) p -> ((), p))

deleteGame = fromLens id (\_ ((),()) -> ())


x :: OpenGame
  StochasticOptic
  StochasticContext
  '[Kleisli Stochastic Signal VisitorMove]
  '[[DiagnosticInfoBayesian Signal VisitorMove]]
  (Signal, Signal)
  ()
  (Signal, VisitorMove)
  ((), Double)
x = deleteGame >>> (idGame &&& dependentDecision "Aven" actionSpace)

combineGames :: OpenGame
  StochasticOptic
  StochasticContext
  '[Kleisli Stochastic Signal VisitorMove]
  '[[DiagnosticInfoBayesian Signal VisitorMove]]
  (Signal, Signal)
  ()
  ()
  ()
combineGames = x >>> payoffGame

payoffGame :: StochasticBayesianOpenGame '[] '[] (Signal, VisitorMove) ((), Double) () ()
payoffGame = fromLens (const ()) (\(signal, move) () -> ((), payoffFunction signal move))

natureCopy = (nature distributionTest >>> copyGame) 


finalGame = natureCopy >>> combineGames

stuff = nature distributionTest >>> copyGame >>> (deleteGame >>> (idGame &&& dependentDecision "Aven" actionSpace))


signallingContext = StochasticContext (playDeterministically ((), ())) (\_ (signal, action) -> playDeterministically $ payoffFunction signal action)

strat = Kleisli $ const $ playDeterministically Access
runFinalGame = evaluate finalGame (strat ::- Nil) void 

{-

We want to define an operator to facilitate Bayesian inverses. 

-}

data Honeypot = Active | Passive deriving (Show, Eq)

priorBias = distFromList [(Active, 0.4), (Passive, 0.6)]
priorZ = distFromList [(On, 0.6), (Off, 0.4)]
observation = do {x <- priorBias; return ((), x)}

firstUpdate = 
  Kleisli 

{-

data StochasticContext s t a b where
  StochasticContext :: (Show z) => Stochastic (z, s) -> (z -> a -> Stochastic b) -> StochasticContext s t a b

-}

backwards z b = do playDeterministically $ 0.5
continuation :: (z -> a -> Stochastic b)
continuation z = Kleisli $ const $ playDeterministically 0.5 
support :: Stochastic x -> [x]
support = map fst . decons

bayes :: (Eq y) => Stochastic (x, y) -> y -> Stochastic x
bayes a y = mapMaybe (\(x, y') -> if y' == y then Just x else Nothing) a

doUpdate x = expected $ 
    do 
       t <- bayes observation x
       backwards t observation

firstOptic cond = StochasticOptic (\s -> 
    do 
      a <- runKleisli cond s
      return ((), a) 
    )
    (\() _ -> return doUpdate )

secondOptic cond = StochasticOptic (\s -> 
    do 
      a <- runKleisli cond s
      return ((), a) 
    )
    (\() _ -> return ())

