{-# LANGUAGE LambdaCase #-}
module IDS.DeceptionStrategies where 
import IDS.DeceptiveModel

import OpenGames.Preprocessor
import OpenGames.Engine.BayesianGamesNonState

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

deceptiveStrategies deviation = visitorStrategy deviation ::- defenderStrategy ::- Nil
forSureDeceptiveStrategies = forSureVisitorStrategy ::- forSureDefenderStrategy ::- Nil
repeatedDeceptiveStrategies deviation = (convertVisitorStrategy . visitorStrategy $ deviation) ::- convertDefenderStrategy defenderStrategy ::- Nil

forSureVisitorStrategy :: Kleisli Stochastic DeceptiveType AttackerDeceptiveMove 
forSureVisitorStrategy = Kleisli (const $ playDeterministically Normal)

forSureDefenderStrategy :: Kleisli Stochastic AttackerDeceptiveMove DefenderRouting 
forSureDefenderStrategy = Kleisli (const $ playDeterministically Honeypot)

visitorStrategy :: Double -> Kleisli Stochastic DeceptiveType AttackerDeceptiveMove
visitorStrategy deviation = Kleisli (\case {
    Passive -> distFromList [(Normal, deviation), (Suspicious, 1 - deviation)];
    Active -> playDeterministically Normal
})

defenderStrategy :: Kleisli Stochastic AttackerDeceptiveMove DefenderRouting
defenderStrategy = Kleisli (\case {
    Normal -> playDeterministically Regular;
    Suspicious -> playDeterministically Honeypot;
})

convertVisitorStrategy :: Kleisli Stochastic DeceptiveType AttackerDeceptiveMove -> Kleisli Stochastic (DeceptiveType, AttackerDeceptiveMove, DefenderRouting) AttackerDeceptiveMove
convertVisitorStrategy x = Kleisli (\case {
    (Passive, _, _) -> runKleisli x Passive ;
    (Active, _ , _) -> runKleisli x Active
})

convertDefenderStrategy :: Kleisli Stochastic AttackerDeceptiveMove DefenderRouting -> Kleisli Stochastic (AttackerDeceptiveMove, DefenderRouting) DefenderRouting
convertDefenderStrategy x = Kleisli (runKleisli x . fst)


-- repeatedVisitorStrategy :: Double -> Kleisli Stochastic (DeceptiveType, AttackerDeceptiveMove, DefenderRouting) AttackerDeceptiveMove
-- repeatedVisitorStrategy deviation = Kleisli (\case {
--     (Passive, prevMove, prevDefenderMove) -> repeatedPassiveStrategy prevMove prevDefenderMove;
--     (Active, prevMove, prevDefenderMove) -> repeatedActiveStrategy prevMove prevDefenderMove
-- })

-- repeatedPassiveStrategy, repeatedActiveStrategy :: AttackerDeceptiveMove -> DefenderRouting -> Stochastic AttackerDeceptiveMove

-- repeatedPassiveStrategy 
