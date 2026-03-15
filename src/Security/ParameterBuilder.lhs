%include polycode.fmt

Sometimes we want to write the payoff as follows, notice that the type is given 
by |defenderAccessPayoff :: HoneypotAllocation -> PayoffReader IDSParamsHP| 
\begin{code}

defenderAccessPayoff :: HoneypotAllocation -> PayoffReader IDSParamsHP
defenderAccessPayoff hp =
    do
        params <- ask
        costOfDefense <- asks $ ($ @ hp) . costOfDefense
        probDetection <- asks $ ($ @ hp) . probDetected
        computingResources <- asks computingResources
        computationReductionUnderAttack <- asks computationReductionUnderAttack
        return $ 
            (computingResources - costOfDefense) * 
                (probDetection + (1 - probDetection) * computationReductionUnderAttack)
\end{code}
