{-# LANGUAGE GADTs #-}
{-# LANGUAGE DataKinds #-}
module IDS.Recursive where 

import OpenGames.Engine.OpticClass
import OpenGames.Engine.OpenGames
import OpenGames.Engine.TLL
import OpenGames.Engine.BayesianGamesNonState



repeatFinite :: Int
             -> OpenGame StochasticOptic StochasticContext '[s1, s2] '[r1, r2] x x' x x'
             -> OpenGame StochasticOptic StochasticContext '[s1, s2] '[[r1], [r2]] x x' x x'
repeatFinite 0 g = reindex (\_ -> Nil)
                           (\_ _ -> [] ::- [] ::- Nil)
                           (fromFunctions id id)
repeatFinite n g = reindex (\(s1 ::- s2 ::- Nil) -> s1 ::- s2 ::- s1 ::- s2 ::- Nil)
                           (\_ (r1 ::- r2 ::- rs1 ::- rs2 ::- Nil) -> (r1:rs1) ::- (r2:rs2) ::- Nil)
                           (g >>> repeatFinite (n - 1) g)
  where f r rs = do {x <- r; xs <- rs; pure (x : xs)}
