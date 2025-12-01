import OpenGames.Engine.BayesianGamesNonState (playDeterministically)
%include polycode.fmt

\begin{code}

augmentDetectionProb :: HoneypotDeploymentMove -> (PayoffReader IDSParams -> PayoffReader IDSParams)
augmentDetectionProb HighInteractionHP = local (\params -> params {probDetected = probDetected params * 1.4})
augmentDetectionProb LowInteractionHP = local (\params -> params {probDetected = probDetected params * 1.25})
augmentDetectionProb Normal = id
\end{code}