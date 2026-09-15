\section{Simulation-based analysis and discussion}
\label{sec:3}
\subsection{Motivation}
So far, the 

A main shortcoming of open game models "in-production" is the lack of other solution concepts such as separating or sequential equilibrium. 
\subsection{Equilibria analysis}
\subsection{Payoff graphs}
\subsection{The case for test-driven development}

TDD ensures high-quality verification of assumptions but separated into three key areas: (1) game structure and (2) parameterization. With the DSL, the typechecker does all the work of ensuring types are lined up, computations are pipelined explicitly in the language by cross-referencing the appropriate fields of a code-block.  
\subsection{Test data generation}
Fine tuned control over simulation. A straightforward example in a attacker-defender signalling game is the case of a defender assuming the prior probability of an attacker as 0. This ultimately leads to a nonsensical outcome, which is reflected in the DiagnosticInformation as \textit{NaN}. When attempting to 
\subsection{Utility from Diagnostics}
Noticing hte expected reward in the payoff section, the average expected utility 
Deconstructing the returned Diagnostic type, each player recieves a certain expected payoff within the context of the support of the unobservable state. In a simple case, 
\
\subsection{Towards Bayesian perfect equilibrium}

\begin{example}
    
\end{example}
\cite{hedges2017morphismsopengames} provides a definition of subgame-perfect equilibrium for perfect information games. However, 
Something about on/off eq
\cite{capucci2021translating} provides a translation to extensive-form games of incomplete information, but still missing this implmentation in the current open-game implementation. 
Here we examine results from a signalling game to interpret how the engine behaves. 
If we want to track probabilities at each aforementioned information set, we need only relax the positive probability support constraint. 

From existence theorem, we have necessarily a mixed Bayesian equilibrium
Note that the definition of sequential play in \cite{BayesianOpenGames} differs from \cite{ghani2017compositionaltreatmentiteratedopen} and \cite{hedges2017morphismsopengames}, where the composite game has a strategy profile given by function from the strategy set of the first player to the strategy set of the second moving player. This reactionary set is also reminscent of a second-mover playing against a globally-known fixed strategy. 
Let's examine the output of the signalling game.
Subgame perfect equilibrium? 

\textbf{Claim}: each subgame given in the diagnostic output represent information sets, Since we have to examine all scenarios in the support of the previously-played moves, for each possible input, we unumerate over each possible combination of unobservable states. 
By testing only separating equilibrium, the engine does not check off-equilibrium paths. So there is no checking of a some subgames
\subsection{Open interface and value iteration}
Notice the strategies are supplied, but we can give our system stratregies from an external optimizer. As we'll see in the following chapter, 
\subsection{Sensitivity analysis}
\subsection{Discussion}
This approach lacks in designing optimization problems with continuous action spaces or 
\subsubsection{Peformance issues and scaling}
\subsubsection{Learning curve}
As mentioned previously, using this methodology and open-games-hs in it's current iteration requires a modeller to adapt .While we've demonstrated 
\subsection{Part of a larger framework}
As seen in A Game Theory Based Multi Layered Intrusion Detection Framework
for Wireless Sensor Networks, once again the two-player signalling game is used. But it is only relevant to one layer of a larger model involving incentive mchanisms for different IDS's to report honest findings. Would it be possible to design this multi-layered framework as a composition of more open games models? We want to show that each layer can be designed independently, and composed at the end for analyssi.
Possibility of automation.

\subsection{Libraries of test data}
CI integration for ensuring specifications.
\begin{example}
    Say you have created a new file which imports a 2-player, attacker-moves-first with private type security interaction from the \textbf{Security} library, aliased as your Haskell function |attackerFirstModel|. According to the needs of network managers evaluating two different SCADA honeypot configs, which deploy honeypot servers of varying capabilities. A demonstration of this is \textbf{IDSAPayoff.hs} and \textbf{IDSAPayoffHP.hs}, where \textbf{IDSAPayoffHP.hs} augments the payoff structure of \textbf{IDSAPayoff.hs}. This falls strictly within the concern of payoff structure, so these files don't need to know anything about open games or the intended model they will be used for. 
\end{example}
\subsection{Discussion}
Evaluating these patterns would require use cases and human trials. Following This involves usability, accessibility, and . 
