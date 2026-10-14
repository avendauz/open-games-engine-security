{-# LANGUAGE GADTs #-}
{-# LANGUAGE DataKinds #-}

module OpenGames.Engine.IDSMarkovChain where

import           OpenGames.Engine.Engine hiding (StochasticStatefulOptic
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
                                      )
import           OpenGames.Engine.BayesianGamesNonState
import           OpenGames.Preprocessor


repeatFiniteTwoPlayer :: (Monad m)
             => Int
             -> OpenGame (MonadicOptic m) (MonadicContext m) '[s1, s2] '[m r1, m r2, m r3] x x' x x'
             -> OpenGame (MonadicOptic m) (MonadicContext m) '[s1, s2] '[m [r1], m [r2], m [r3]] x x' x x'
repeatFiniteTwoP 0 g = reindex (\_ -> Nil)
                           (\_ _ -> pure [] ::- pure [] ::- pure [] ::- Nil)
                           (fromFunctions id id)
repeatFinite n g = reindex (\(s1 ::- s2 ::- Nil) -> s1 ::- s2 ::- s1 ::- s2 ::- Nil)
                           (\_ (r1 ::- r2 ::- r3 ::- rs1 ::- rs2 ::- rs3 ::- Nil) -> f r1 rs1 ::- f r2 rs2 ::- f r3 rs3 ::- Nil)
                           (g >>> repeatFinite (n - 1) g)
  where f r rs = do {x <- r; xs <- rs; pure (x : xs)}
