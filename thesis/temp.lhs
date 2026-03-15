%include lhs2TeX.fmt
\begin{code}
defenderLeader defenderName getActionSpace = [opengame|

   inputs    :  ;
   feedback  :  ;

   :----------------------------:
   inputs    : ;
   feedback  :      ;
   operation : dependentDecision defenderName getActionSpace;
   outputs   : defenderDecision;
   returns   : defenderPayoff ;
   :----------------------------:

   outputs   : defenderDecision;
   returns   : defenderPayoff;

 |]
\end{code}
some stuff
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


