%include polycode.fmt

\begin{code}

type PayoffReader a = Reader a Double

runPayoff :: a -> PayoffReader a -> Double
runPayoff params reader = runReader reader params

\end{code}

