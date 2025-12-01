{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
module OpenGames.Engine.BayesianGamesNonState
  ( StochasticBayesianOpenGame(..)
  , dependentDecision
  , dependentEpsilonDecision
  , fromLens
  , fromFunctions
  , nature
  , liftStochastic
  , uniformDist
  , distFromList
  , pureAction
  , playDeterministically
  ) where

import Unsafe.Coerce

import           Control.Arrow                      hiding ((+:+))
import           Control.Monad.State                hiding (state)
import           Control.Monad.Trans.Class
import GHC.TypeLits

import Data.Foldable
import           Data.HashMap                       as HM hiding (null,map,mapMaybe)


import Data.List (maximumBy)
import Data.Ord (comparing)
import           Data.Utils
import Numeric.Probability.Distribution hiding (map, lift, filter)

import OpenGames.Engine.OpenGames hiding (lift)
import OpenGames.Engine.OpticClass
import OpenGames.Engine.TLL
import OpenGames.Engine.Diagnostics

---------------------------------------------
-- Reimplements stateful bayesian from before

type StochasticBayesianOpenGame a b x s y r = OpenGame StochasticOptic StochasticContext a b x s y r

type Agent = String

support :: Stochastic x -> [x]
support = map fst . decons

bayes :: (Eq y) => Stochastic (x, y) -> y -> Stochastic x
bayes a y = mapMaybe (\(x, y') -> if y' == y then Just x else Nothing) a


deviationsInContext :: (Show x, Show y, Ord y, Show theta)
                    => Double -> Agent -> x -> theta -> Stochastic y -> (y -> Double) -> [y] ->  [DiagnosticInfoBayesian x y]
deviationsInContext epsilon name x theta strategy u ys
  = [DiagnosticInfoBayesian { equilibrium = strategicPayoff >= optimalPayoff - epsilon,
                      player = name,
                      payoff = strategicPayoff,
                      optimalMove = optimalPlay,
                      optimalPayoff = optimalPayoff,
                      context = u ,
                      state = x,
                      unobservedState = show theta,
                      strategy = strategy
                      }]
  where strategicPayoff = expected (fmap u strategy)
        (optimalPlay, optimalPayoff) = maximumBy (comparing snd) [(y, u y) | y <- ys]

stackelbergDeviations :: (Show x, Show y, Ord y, Show theta)
                    => Double -> Agent -> x -> theta -> Stochastic y -> (y -> Double) -> [y] ->  [DiagnosticInfoBayesian x y]
stackelbergDeviations epsilon name x theta strategy u ys
  = [DiagnosticInfoBayesian { equilibrium = strategicPayoff >= optimalPayoff - epsilon,
                      player = name,
                      payoff = strategicPayoff,
                      optimalMove = optimalPlay,
                      optimalPayoff = optimalPayoff,
                      context = u ,
                      state = x,
                      unobservedState = show theta,
                      strategy = strategy
                      }]
  where strategicPayoff = expected (fmap u strategy)
        (optimalPlay, optimalPayoff) = maximumBy (comparing snd) [(y, u y) | y <- ys]

dependentDecision :: (Eq x, Show x, Ord y, Show y) => String -> (x -> [y]) -> StochasticBayesianOpenGame '[Kleisli Stochastic x y] '[[DiagnosticInfoBayesian x y]] x () y Double
dependentDecision name ys = OpenGame {
  play = \(a ::- Nil) -> let v x = do {y <- runKleisli a x; return ((), y)}
                             u () _ = return ()
                            in StochasticOptic v u,
  evaluate = \(a ::- Nil) (StochasticContext h k) ->
     (concat [ let u y = expected (do {t <- (bayes h x);
                                       k t y})
                   strategy = runKleisli a x
                  in deviationsInContext 0 name x theta strategy u (ys x)
              | (theta, x) <- support h]) ::- Nil }

dependentEpsilonDecision :: (Eq x, Show x, Ord y, Show y) => Double -> String -> (x -> [y])  -> StochasticBayesianOpenGame '[Kleisli Stochastic x y] '[[DiagnosticInfoBayesian x y]] x () y Double
dependentEpsilonDecision epsilon name ys = OpenGame {
  play = \(a ::- Nil) -> let v x = do {y <- runKleisli a x; return ((), y)}
                             u () _ = return ()
                            in StochasticOptic v u,
  evaluate = \(a ::- Nil) (StochasticContext h k) ->
     (concat [ let u y = expected (do {t <- (bayes h x);
                                       k t y})
                   strategy = runKleisli a x
                  in deviationsInContext epsilon name x theta strategy u (ys x)
              | (theta, x) <- support h]) ::- Nil }

stackelbergDecision :: (Eq x, Show x, Ord y, Show y) => String -> (x -> [y]) -> StochasticBayesianOpenGame '[Kleisli Stochastic x y] '[[DiagnosticInfoBayesian x y]] x () y Double
stackelbergDecision name ys = OpenGame {
  play = \(a ::- Nil) -> let v x = do {y <- runKleisli a x; return ((), y)}
                             u () _ = return ()
                            in StochasticOptic v u,
  evaluate = \(a ::- Nil) (StochasticContext h k) ->
     (concat [ let u y = expected (do {t <- (bayes h x);
                                       k t y})
                   strategy = runKleisli a x
                  in stackelbergDeviations 0 name x theta strategy u (ys x)
              | (theta, x) <- support h]) ::- Nil }


-- Branching operator
(+++) :: forall a1 a2 b1 b2 x1 x2 s r y1 y2. (Unappend a1, Unappend a2, RepNothing b1, RepNothing b2)
      => StochasticBayesianOpenGame a1 b1 x1 s y1 r
      -> StochasticBayesianOpenGame a2 b2 x2 s y2 r
      -> StochasticBayesianOpenGame (a1 +:+ a2) (TMap Maybe (b1 +:+ b2)) (Either x1 x2) s (Either y1 y2) r
(+++) g1 g2 = OpenGame {
  play = \as -> case unappend as of (a1, a2) -> play g1 a1 ++++ play g2 a2,
  evaluate = \as (StochasticContext h k) ->
    case unappend as of
      ((a1, a2) :: (List a1, List a2)) ->
          let xs1 = [((z, x1), p) | ((z, Left x1), p) <- decons h]
              xs2 = [((z, x2), p) | ((z, Right x2), p) <- decons h]
              e1 = evaluate g1 a1 (StochasticContext (fromFreqs xs1) (\z y1 -> k z (Left y1)))
              e2 = evaluate g2 a2 (StochasticContext (fromFreqs xs2) (\z y2 -> k z (Right y2)))
           in case (null xs1, null xs2) of
                (False, False) -> vmap Just (e1 +:+ e2)
                (False, True)  -> unsafeConcat @b1 @b2 (vmap Just e1) (rep @b2)
                (True, False)  -> unsafeConcat @b1 @b2 (rep @b1) (vmap Just e2)
                _              -> error "This can't happen"
}

unsafeConcat :: forall b1 b2. List (TMap Maybe b1) -> List (TMap Maybe b2) -> List (TMap Maybe (b1 +:+ b2))
unsafeConcat = unsafeCoerce (+:+)


-- Support functionality for constructing open games
fromLens :: (x -> y) -> (x -> r -> s) -> StochasticBayesianOpenGame '[] '[] x s y r
fromLens v u = OpenGame {
  play = \Nil -> StochasticOptic (\x -> return (x, v x)) (\x r -> return (u x r)),
  evaluate = \Nil _ -> Nil}


fromFunctions :: (x -> y) -> (r -> s) -> StochasticBayesianOpenGame '[] '[] x s y r
fromFunctions f g = fromLens f (const g)

nature :: Stochastic x -> StochasticBayesianOpenGame '[] '[] () () x ()
nature a = OpenGame {
  play = \Nil -> StochasticOptic (\() -> do {x <- a; return ((), x)}) (\() () -> return ()),
  evaluate = \Nil _ -> Nil}

liftStochastic :: (x -> Stochastic y) -> StochasticBayesianOpenGame '[] '[] x () y ()
liftStochastic f = OpenGame {
  play = \Nil -> StochasticOptic (\x -> do {y <- f x; return ((), y)}) (\() () -> return ()),
  evaluate = \_ _ -> Nil}

-- liftContinuation :: StochasticOptic () () () ()-> StochasticBayesianOpenGame '[] '[] (Kleisli Stochastic a y, a) () y ()
-- liftContinuation optic = OpenGame {
--   play = \Nil -> optic,
--   evaluate = \_ _ -> Nil}

-- Support functionality for stochastic processes (also interface to the probability module in use)

-- uniform distribution
uniformDist = uniform

-- tailored distribution from a list
distFromList = fromFreqs

-- pure action (no randomization)
pureAction x = Kleisli $ const $ certainly x

playDeterministically :: a -> Stochastic a
playDeterministically = certainly


