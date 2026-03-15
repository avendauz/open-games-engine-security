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
