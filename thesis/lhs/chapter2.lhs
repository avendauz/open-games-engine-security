\section{Software abstractions for open cybersecurity games}
\label{sec:2}
\subsection{Overview}
The previous chapter identified compositional patterns amongst a series of related game theoretic models for cybersecurity problems. But the process for analyzing the behaviour of the model requires additional work, specifically as the model increases in complexity. 

In this chapter, we show how to use the Haskell environment to generate parameters and specify the parameter space of games. Therefore, after using the DSL to con

There are many computational tools that exist in order to solve for equilibria, produce extensive-form game-trees, and SMT-solvers. But what we would like to outline in this chapter is being able to simultaneously generate games in a declarative manner, where the game formulation process is aided by the open games Haskell DSL. In this chapter we'll see how after a few attempts, generalizing these patterns allow for model \textit{reproducability} and \textit{reusability}, ultimately culminating in a small library of 2-player security games. We will see how this simple subset of game scan be used to rapidly generate game theoretic models in a variety of settings. By leveraging abstract data types, polymorphism, and the reader monad, we can parameterize these models with modules that help organize payoff modules and strategies. 

Providing a small subset of games as a library, this falls short of a clear-cut executable script for a predetermined model. Part of developing or extending a model could be better 



\subsection{Current state-of-the-art for open games}
This thesis draws on a key motivation proposed by Zahn in \cite{ZahnCybercat}, towards the synthesis of an encoded library of microeconomic models. The process of developing the "correct" model is therefore framed as a software engineering problem. The open-games-engine has demonstrated its use verifying the most recognizable game theory problems like Prisoner's Dilemma, to auction mechanisms. A series of these models have been met with production-level directions, and a codebase of models have grown. While this thesis departs from the application of this field towards cybersecurity, the bulk of the work that is presented here is an attempt to give guidelines for using the open-games-engine effectively. Specifically, the interdisciplinary and workflow possibilities that are provided by producing models in this environment, achieving easy maneuverability and testing that fits naturally with the requirements for synthesizing effective security models. 

\cite{20squares} has a series of completed projects for auctions and blockchain staking protocols. Capturing the complexity of models with open games is shown in these previous projects, but this chapter will deliberate on formalizing common techniques used to generate these models. I invite readers to refer to the README for \cite{20squares} projects for the syntax of the open-games DSL and common operators that can be used. 

\subsection{Formalizing Stackelberg equilibrium in open games}

\subsubsection{Related work}
The most recent work that uses software-assisted tools for Stackelberg security games is \cite{Phetmanee2024}, using rational verification. Rational verification is a formal-analysis technique for determining the equilibrium properties of multiagent systems. Specifically by encoding these properties in Linear Temporal Logic, practitioners can use model-checkers such as PRISM to verify that given models satisfy properties. After writing these propositions, PRISM can act as an equilibrium checker by checking all possible states of the game. In particular, \cite{Phetmanee2024} extends the PRISM framework to demonstrate the security properties detailed in CVE-2017-8759, and generates data demonstrating the defensive conditions and recommendations for security advisors. 

This thesis seeks to bring the resultant model closer to its conception, or in other words, more reactive to changes made to the original parameters of its conception. In the StEvE methodology, security experts are tasked with encoding an ADT and the corresponding payoffs, to then be encoded into the temporal logic propositions. A PRISM script can then ingest the CVE data and in-lined cost values to get an evaluation outputted to the terminal with metrics such as payoffs for attackers and defenders in each state.


\subsection{Model instantiation}
Drawing from the habit of separation-of-concerns, 
\subsection{Towards test-driven modelling}
Test-driven development (TDD) is a coding paradigm where a programmer begins with unit tests and iteratively refactors code to fulfill these tests and write new ones. A programmer doesn't move on to the next iteration until the entire test suite passes, ensuring that refactors don't cause breaking changes across a code-base. The very first test case in any situation is to verify the most basic assumptions for the behaviour of a program. And as the complexity and dependency of this program grows, these assumptions are always kept in check. TDD enables the coder to think about specifications first, and while those specifications are open to change over time, writing these tests document the expected behaviour of the program. 

Here I propose test-driven modelling as a way to guide experiments in a self-documented fashion, while also maintaining guarantees of a game before its eventual composition with others. 

It's a well-known fact that in the problem of a player allocating finite defensive resources across a series of subsystems, for example by employing maximum, high-cost 


\subsubsection{Generating test cases}

\subsection{Leveraging the Haskell type system}
\label{sec: types}
Type inference is a powerful tool for checking correctness of your models. And as a developer we can let the language work for us by observing a basic requirement for our model: type correctness. According to the proposed methodology, perhaps I've written that my specification as type sfor inputs and outputs for my attacker. Then to simulate the behaviour of the attacker, I need to supply the expected behaviour as a strategy where the attacker observes the expected input type and returns the expected output type. With these bounds in place, it leaves room for me to specify behaviour according to a wide variety of attack vectors or capabilities. 
\begin{enumerate}
	\item What the agent observes
	\item What the agent can do about it 
	\item All the 
\end{enumerate}


Working with the open-games DSL allows us to structure our game in a block-by-block style, however some of the major components of the model require Haskell functions to encode payoff matrices, action spaces

Definition: an open-game allows for attachments. As soon as we provide the associated payoff for the building block, we close off an end. So for each complete model, the agents: 


Parameters and hardcoded values: we often want to encode our behaviour as Haskell functions. For example, the level of defense may be dependent on the level of honeypot, and ... Often we need to keep track of constraints associated with these, which intuitively follows a specification written in QuickCheck. Following the specification, we can verify that we capture the expected behaviour with these functional tests 

The added benefit of generating test parameters and ensuring variable constraints are met.

The type checker will ensure that closing a game with a given payoff builder will mean that types must line up at the interfaces. 

\subsection{A few SOLID principles}
Open for extension ,closed for modification. The hallmark of this design strategy . Just as we might want to consider an additional player, we can easily replicate a utility-maximizing agent using the DSL. Similarly, if we would like to consider an additoinal model parameter or 

Having a modular language allows us to construct games open for extension, by interacting with the interfaces exposed by each game. 

IDEA: We want to encode our "assumptions" such as paraemter bounds, sign, and relative values. We cna quickcheck these as part of the simulation process in order to preliminarily check that test parameters used for simulation accurately reflect the given values. 
\subsubsection{Separation of concerns}

\subsection{Designing payoffs}
Based on examples provided in \cite{Zahn2024}, some of the following design patterns can be recognized:
\begin{enumerate}
	\item Type-specified payoffs 
	\item State-specified payoffs
\end{enumerate}
\subsubsection{Payoff parameterization with the reader monad}

\textbf{Goal:} the development of payoff modules that can be interchanged for a particular game.

Note that from section \ref{sec: types}, the instantiation of games by action space informs the types exactly available for designing payoffs. Since this model doesn't 'require' any specific payoff behaviour beyond these types (and passing some test infrastructure). We can loosely characterize payoff functions by their dependence on the following information: 
\begin{enumerate}
	\item The output of the designed game 
	\item Model-level exogenous parameters 
\end{enumerate}

An example of 1. in a simple case is a tuple of actions chosen by each player in the game, or the assigned player type. 2. is concerned with system parameters that are relevant to payoff data. Here, we propose the reader monad as the necessary function-passing structure for generating payoff functions according to these model-level exogenous parameters. 

\begin{code}

type PayoffReader a = Reader a Double

runPayoff :: a -> PayoffReader a -> Double
runPayoff params reader = runReader reader params

\end{code}




Notice the parametric type \textit{a}, so we can define a \textit{PayoffReader} for any ADT containing exogenous model parameters. This supports the system-level-first architecture that allows a modeller to introduce relevant variables that are not directly involved and subject to manipulation separate from the interworkings of the open game model. Thus, we can actively test how different payoff schemes affect our game model, either by (1) testing the same game with different system variables or (2) the same system variables with different player capabilities. We can characterize a payoff profile's dependence on two things: the outputs of the open game, and the variables accessible with the \textit{PayoffReader}.

To start with writing payoffs according to the outputs of a game, we can consider the running Bayesian security game example from the previous chapter. Already we can consider branching the payoff functions into helpers associated with each type of player, and pattern-match on these types. If we use the preset template from the Security module, the set of two-player security games requires a \textit{PayoffReader} for each attacker and defender. Then at the execution-level of the game, which runs against the model-level parameters, we use these parameters to instantiate the readers (in this case, \textit{IDSParams}). Thanks to the type-checker, the output type of the model should provide the modeller with the requirements for this \textit{PayoffReader} constructor. In this example, we can define the payoffs as follows: 

% \begin{hscode}\SaveRestoreHook
% 	\column{B}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\column{5}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\column{14}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\column{E}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\>[B]{}\Varid{visitorPayoff}\mathbin{::}\Conid{VisitorType}\to \Conid{VisitorMove}\to \Conid{DefenderMove}\to \Conid{PayoffReader}\;\Conid{IDSParams}{}\<[E]%
% 	\\
% 	\>[B]{}\Varid{visitorPayoff}\mathrel{=}\lambda \mathbf{case}\;\{\mskip1.5mu {}\<[E]%
% 	\\
% 	\>[B]{}\hsindent{5}{}\<[5]%
% 	\>[5]{}\Conid{Attacker}\to \Varid{attackerPayoff};{}\<[E]%
% 	\\
% 	\>[B]{}\hsindent{5}{}\<[5]%
% 	\>[5]{}\Conid{User}\to {}\<[14]%
% 	\>[14]{}\Varid{userPayoff}{}\<[E]%
% 	\\
% 	\>[B]{}\mskip1.5mu\}{}\<[E]%
% 	\\[\blanklineskip]%
% 	\>[B]{}\Varid{defenderPayoff}\mathbin{::}\Conid{VisitorType}\to \Conid{VisitorMove}\to \Conid{DefenderMove}\to \Conid{PayoffReader}\;\Conid{IDSParams}{}\<[E]%
% 	\\
% 	\>[B]{}\Varid{defenderPayoff}\mathrel{=}\lambda \mathbf{case}\;\{\mskip1.5mu {}\<[E]%
% 	\\
% 	\>[B]{}\hsindent{5}{}\<[5]%
% 	\>[5]{}\Conid{Attacker}\to \Varid{defenderUnderAttackPayoff};{}\<[E]%
% 	\\
% 	\>[B]{}\hsindent{5}{}\<[5]%
% 	\>[5]{}\Conid{User}\to \Varid{defenderNormalPayoff};{}\<[E]%
% 	\\
% 	\>[B]{}\mskip1.5mu\}{}\<[E]%
% 	\ColumnHook
% \end{hscode}\resethooks

The type signature of each of these functions corresponds to the output of the completed open game. Then, we can use helper functions associated with each matched type and define the payoff accordingly. Since we've instantiated the reader with our exogenous parameters, the bottom-level of our payoff functions have access to the data of \textit{IDSParams}. Refer to \textbf{IDS/IDSAPayoff.hs} for the complete implementation.

A key feature of using the reader monad is having fine-tuned control over these parameters without worrying about changing them. And if we do need to change them, it's explicit. Consider the payoff scheme used to slightly adapt the previous example by allowing the defender to not just open or close, but deploy two different kinds of honeypots or remain open under normal operation in \textbf{IDS/IDSAHPPayoff.hs}, 

% \begin{hscode}\SaveRestoreHook
% 	\column{B}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\column{5}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\column{14}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\column{E}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\>[B]{}\Varid{defenderPayoffHP}\mathbin{::}\Conid{VisitorType}\to \Conid{VisitorMove}\to \Conid{HoneypotDeploymentMove}\to \Conid{PayoffReader}\;\Conid{IDSParams}{}\<[E]%
% 	\ColumnHook
% \end{hscode}\resethooks

The type signature only differs in the third argument to the payoff functions. Intuitively, I will have to write the same pattern-matching structure but over the new datatype \textit{HoneypotDeploymentMove}, but the computation of payoff shouldn't have to be rewritten explicitly. Since in my model, deploying a high-interaction honeypot increases the probability of detecting an adversary, this can be reflected by locally altering the \textit{IDSParams} before using the same formula from IDSAPayoff. So given a \textit{HoneypotDeploymentMove}, I want to update my \textit{PayoffReader} with an augmentation function such as: 

% \begin{hscode}\SaveRestoreHook
% 	\column{B}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\column{E}{@{}>{\hspre}l<{\hspost}@{}}%
% 	\>[B]{}\Varid{augmentDetectionProb}\mathbin{::}\Conid{HoneypotDeploymentMove}\to (\Conid{PayoffReader}\;\Conid{IDSParams}\to \Conid{PayoffReader}\;\Conid{IDSParams}){}\<[E]%
% 	\\
% 	\>[B]{}\Varid{augmentDetectionProb}\;\Conid{HighInteractionHP}\mathrel{=}\Varid{local}\;(\lambda \Varid{params}\to \Varid{params}\;\{\mskip1.5mu \Varid{probDetected}\mathrel{=}\Varid{probDetected}\;\Varid{params}\mathbin{*}\mathrm{1.4}\mskip1.5mu\}){}\<[E]%
% 	\\
% 	\>[B]{}\Varid{augmentDetectionProb}\;\Conid{LowInteractionHP}\mathrel{=}\Varid{local}\;(\lambda \Varid{params}\to \Varid{params}\;\{\mskip1.5mu \Varid{probDetected}\mathrel{=}\Varid{probDetected}\;\Varid{params}\mathbin{*}\mathrm{1.25}\mskip1.5mu\}){}\<[E]%
% 	\\
% 	\>[B]{}\Varid{augmentDetectionProb}\;\Conid{Normal}\mathrel{=}\Varid{id}{}\<[E]%
% 	\ColumnHook
% \end{hscode}\resethooks



To demonstrate the breadth of this granularity, we observe the following example for designing payoffs derived from an initial problem statement.

\begin{enumerate}
	\item Assumption: there is only one attacker and one defender
	\item Assumption: the defender can either allow traffic or close the server 
\end{enumerate}

The factors that we consider that dictates the payoff would be included in the global config instantiating the model as a Haskell record type. Here, without having to change this global config, I use \textit{local} to adjust the detection probability. 


\subsubsection{Repeated payoff game structures}
As elaborated in \cite{Hedges2019}, we can introduce infinitely-repeated games by conditioning an open game according to some set we'll denote \textit{A}. For our purposes, we can consider conditioning a game by all the possible outcomes played in a stage game, whilst discounting the payoffs at each stage by some $\alpha$. 

Notice in the following definition of this repeated stage, besides the usual name and action space parameterization for each player the final argument is itself another open game dubbed \textit{payoffGame}. We can think about \textit{repeatedStage} as an open game with the sole purpose of accumulating passed back payoffs and sending them back to the next iteration in the \textbf{feedback} field. Here we set the \textit{feedback} and \textit{returns} types as a list of Doubles of length two for the two-player security game case. 
\begin{code}

repeatedStage actionSpaceAttacker attackerName actionSpaceDefender defenderName payoffGame = [opengame|
   inputs : visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: [(payoffIndexer previousPayoffs 0) + attackerPayoff, (payoffIndexer previousPayoffs 1) + defenderPayoff];
   :----------------------------:

   inputs: visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   operation: attackerLeader attackerName actionSpaceAttacker;
   outputs: attackerDecision;
   returns: (payoffIndexer previousPayoffs 0) + attackerPayoff;

   inputs: prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   operation: defenderFollower defenderName actionSpaceDefender;
   outputs: defenderDecision;
   returns: (payoffIndexer previousPayoffs 1) + defenderPayoff;

   inputs: visitorType, attackerDecision, defenderDecision;
   feedback: ;
   operation: payoffGame;
   outputs: attackerPayoff, defenderPayoff;
   returns : ;
   :----------------------------:

   outputs: visitorType, attackerDecision, defenderDecision;
   returns: previousPayoffs;
|]


repeatedPayoffGame params payoffReader1 payoffReader2 = [opengame|
   inputs : visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   :----------------------------:

   inputs: visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   operation: liftStochastic (\(x,y,z) -> playDeterministically (calculateCurrAttackerPayoff x y z, calculateCurrDefenderPayoff x y z));
   outputs: payoff1, payoff2;
   returns: ;

   :----------------------------:

   outputs: payoff1, payoff2;
   returns: ;

 |] where calculateCurrAttackerPayoff x y z = runPayoff params (payoffReader1 x y z)
          calculateCurrDefenderPayoff x y z = runPayoff params (payoffReader2 x y z)

\end{code}
\subsection{Collaboration}
To conceptualize the game requires a translation of the security situation to the game-theoretic situation. Whether we choose tractable solutions like payoffs corresponding to server up-time, there is a need for some system in order to communicate this information. Furthermore, specifications... As demonstrated, we would like reproducability and modularity to rapidly provide analytics according to specifications. (SOURCE CONTROL)
