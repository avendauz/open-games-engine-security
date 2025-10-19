%include polycode.fmt

\begin{code}
repeatedContinuationPayoffs :: (Unappend a, Unappend b, Eq i) => Double -> Integer
  -> List a
  -> i
  -> [Double]
  -> OpenGame StochasticOptic StochasticContext a b i [Double] i [Double]
  -> Stochastic [Double]
repeatedContinuationPayoffs discountFactor iterator strat action curPayoffs game 
  | iterator == 1 = pure curPayoffs
  | otherwise     = do
      newPayoffs <- extractContinuation (execute strat) action curPayoffs
      actionNew <-  nextState strat action
      repeatedContinuationPayoffs discountFactor (pred iterator) strat actionNew (map (*discountFactor) newPayoffs) game 
  where execute = play game 
        nextState strat' = extractNextState (execute strat')


\end{code}



\begin{code}
visitorStrategyMixed :: Double -> Kleisli Stochastic VisitorType VisitorMove 
visitorStrategyMixed prob = Kleisli (\case {
    Attacker -> distFromList [(Access, prob), (DoesNotAccess, 1- prob)];
    User -> playDeterministically Access
})
\end{code}


\begin{code}

defenderAccessPayoff :: HoneypotAllocation -> PayoffReader IDSParamsHP
defenderAccessPayoff hp =
    do
        params <- ask
        costOfDefense <- asks $ ($ hp ) . costOfDefense
        probDetection <- asks $ ($ hp) . probDetected
        computingResources <- asks computingResources
        computationReductionUnderAttack <- asks computationReductionUnderAttack
        return $ (computingResources - costOfDefense) * (probDetection + (1 - probDetection) * computationReductionUnderAttack)

\end{code}
