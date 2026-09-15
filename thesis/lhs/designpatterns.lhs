\section{Modularity in game theoretic cybersecurity modelling}
\label{sec:designPatterns}
\subsection{Overview}

The stark reality of designing effective cybersecurity games is bridging real-world security concerns with an accurate representation in a game-theoretic terms. Numerous models have been constructed and analyzed according to specific security problems, thus tying the models to their specification. Furthermore, these models often extend or adapt previously existing constructions by making new assumptions, using different payoff schemes, or integrating the model into an automated defensive infrastructure. Although this informal relationship between these models have been surveyed, there has yet to be a generalized framework for mechanizing this relationship as a standardized game formulation process. On the other hand, as a software tool, open games can accommodate the security models setting, but not without specific Haskell setup-code for running and evaluating a model. Insofar that for investigating a large problem, an open games user can end up with a huge series of top-down Haskell scripts representing a specific simulation, with few structural or helper modules to tie everything together. In order to effectively develop a game formulation process using this tool, we need to identify compositional trends in cybersecurity games, then implement a small Haskell library to provide templates and helper functions for leveraging these compositional trends. Finally, we can follow a cybersecurity-games-as-code approach to iteratively test, generate, and improve models.
This culminates to a metamodelling design process over the open-games-hs software. The structure of the chapter is summarized as follows: 
\begin{itemize}
	\item Section \ref{designPatterns:state} is a review detailing the need for such a design process
	\item Section \ref{designPatterns:directTranslation} details a direct translation of models from literature to serve as a baseline and identify key issues (model reuse, scalability, replicability) that should be addressed 
	\item Section \ref{designPatterns:library} is an introduction of three Haskell modules and one testing framework which encapsulate the design patterns that address those key issues 
	\item detail a project structure using the modules from \ref{designPatterns:code} and project maintenance techniques with version control
	\item proposition of a test-driven, iterative modelling process and discussion
\end{itemize}


% In this chapter, we examine a variety of security games and remark on similarities and differences between game-formulation methods. By generalizing certain patterns such as identifying and encoding the commonly-used 2-player security game in the open-games-DSL, we show how to recover more complex models. By working in the open-games-DSL, a modeller can control information flow, introduce parallel subsystem security interactions, and reuse models. We review current security game analysis methods and present the possibility of integration with other tools. We propose an \textit{iterative development} framework using these design patterns to maintain a model library in a collaborative work setting.




%Indeed, the same code to analyze the intorduction of a single security interaction can analyze it in the context of a larger security infrastructure in a verifiable way.

%	 With an open-interfaced game representing a single security interaction, I demonstrate how a modeller can parameterize the game according to their security specification. 

%Finally, following
%The result of creating this representation is a game-theoretic model strictly tied to a security concern that is often encompassed by a larger security infrastructure. The system we may be trying to model is often comprised of subsystems. As attackers or defenders of this system we can think about an attack on the system as a whole or on its parts, or a mixture of both. 


 


% DOMAIN EXPERT

\subsection{State-of-the-art}
\label{designPatterns:state}
Using game theory to inform cybersecurity problems has seen growth in recent years with the development of a number of different models for evaluating Denial-of-Service attacks on cloud infrastructures, intrusion detection systems, and advanced persistent threats. Refer to the following surveys \cite{Pawlick2019}, \cite{Hausken2024}, \cite{Manshaei2013} for an overview of the wide collection of game-theoretic models. 

A general procedure for developing these models can be (roughly) summarized in the following steps: 
\begin{enumerate}
	\item Detail the security scenario and system, vectors of attack, and defensive capabilities
	\item Develop abstractions  and parameters for the players, actions, and payoff in a game-theoretic setting according to the security scenario
	\item Solve for a solution concept (i.e. Nash equilibrium, Subgame perfect Nash Equilibrium) using methods such as linear programming or Q-learning (for stochastic or repeated games)
	\item Deploy new strategies or technologies in the system according to the solution concept above
	\item Conduct simulations with a fixed strategy, determine the highest expected utility for players and evaluate system performance under these conditions
\end{enumerate}

However, the most recent concerns with evolving attacker threats and dynamic security situations requires more complex game-theoretic models. These games can be part of a larger automated defensive system to update defensive strategies in real time as part of a larger infrastructure such as in \cite{Jin2018}, \cite{Zhu2012}. The progression of these models often relies on the extension and variation of these game-theoretic models. For example, we may need to consider scaling the number of players or repeating strategic interactions. The models presented in \cite{Chen2009}, \cite{Nochenson2012} suggest the use of the models as a basis for extensions and increased-complexity for other security scenarios. Similarly in \cite{Pawlick2015}, the signalling game structure are derived from \cite{Carroll2009}, with adjustments to the utilities. We'll see later how these models written in open games allow for easy extensionality.

According to \cite{Collins2025} evaluating 86 different game-theoretic models in cybersecurity, there already exists a sense of homogeneity between these models, where 76\% of models only cover a two-player security interaction, and 79\% use Nash (or variants of) equilibrium solution concepts for analysis. The authors also recommended a formal method for modellers to state their assumptions of the model that follow more in-line with cybersecurity concepts. Expanding on this idea in particular, we propose that code-based methods for stating assumptions allows for clear, testable specifications. Only 24 of the 86 studies shown consider "multiple variants" of the constructed model. The specification of two criterion: (1) "Efficacy of Modelling" and (2) "Practicality of Solutions" serve as a framework for evaluating the tractability of game-theoretic models' representation of the underlying real cyber-interaction. The resulting recommendations should then be considered: 
\begin{enumerate}
	\item The need for a game space abstraction 
	\item Allow for more flexible assumptions
\end{enumerate}

In that same vein, \cite{Egan2025}, \cite{Liang2013} call for better scalability of models, in particular addressing models that account for more than two player games. This falls more closely to tractable game models that more accurately reflect collaborative or networked defensive systems, but requires more complex equilibrium solutions. Similar to other game formulation methods, each model has a large input dataset of parameters to consider.

Is the open-games-hs software equipped to address some of these issues? This thesis draws on a key motivation proposed by Zahn in \cite{ZahnCybercat}, towards the synthesis of an encoded library of microeconomic models. The process of developing the "correct" model is therefore framed as a software engineering problem. The open-games-engine has demonstrated its use verifying the most recognizable game theory problems like Prisoner's Dilemma, to auction mechanisms. A series of these models have been met with production-level directions, and a codebase of models have grown. While this thesis departs from the application of this field towards cybersecurity, the bulk of the work that is presented here is an attempt to give guidelines for using the open-games-engine effectively. Specifically, the interdisciplinary and workflow possibilities that are provided by producing models in this environment, achieving easy maneuverability and testing that fits naturally with the requirements for synthesizing effective security models. 

\cite{20squares} has a series of completed projects for auctions and blockchain staking protocols. Capturing the complexity of models with open games is shown in these previous projects, but this chapter will deliberate on formalizing common techniques used to generate these models. We invite readers to refer to the README for \cite{20squares} projects for the syntax of the open-games DSL and common operators that can be used. 

Most recently, \cite{tan2022a} demonstrates the open-games-engine use-case for modular law and contracting clauses as a software library \textit{Clause2Game}. His thesis strongly ties software engineering methodologies to clause law methodologies, which is reminiscent of our approach. For example, the resultant data sets already begin to hint at the need for a methodology for "closing games" with equilibrium analysis driven by random initial conditions using |Test.QuickCheck.Gen|. We hope that by explicitly providing a metamodelling, iterative process, this would be applicable beyond the field of security and pertain to collaboration between domain experts and game theory / open-games modellers. But overall, the open-games-hs software can be adapted to fit the modelling needs of the target discipline.  



%\subsubsection{Qualitative to quantitiative parameterization}
%\cite{Rass2017}
%This necessitates collaboration between a domain expert (e.g. cybersecurity expert) and a game-theorist to translate sensible payoff schemes and parameters. 
%
%On the other hand, databases such as NIST and CSVV are directly used in \cite{MacQueen2020} \cite{Furuncu2015}. Diving deeper into \cite{Chen2009}, the work does not consider correlation between attack targets and leaves it for future work. The theoretical basis for the payoffs involving reputation, punishment for loss contrasts with other payoffs using server downtime or capital expenditure from NIST (CVSS) metrics. 

\subsection{Discussion on rational verification}

The most recent work that uses software-assisted tools for Stackelberg security games is \cite{Phetmanee2024}, using rational verification. Rational verification is a formal-analysis technique for determining the equilibrium properties of multiagent systems. Specifically by encoding these properties in Linear Temporal Logic, practitioners can use model-checkers such as PRISM to verify that given models satisfy properties. After writing these propositions, PRISM can act as an equilibrium checker by checking all possible states of the game. In particular, \cite{Phetmanee2024} extends the PRISM framework to demonstrate the security properties detailed in CVE-2017-8759, and generates data demonstrating the defensive conditions and recommendations for security advisors. 


By using the PRISM-model checker and the PRISM property-specification language, it has been shown that security games can be mechanically verified. More recent work has extended PRISM to handle Stackelberg equilibrium for security games \cite{Phetmanee2024}. The complete software for two example models can be found at \cite{phetmanee_2024_13338608}. According to the proposed worfklow, there are automated tools to translate CVEs to attack-defense trees to Stackelberg Security Games, defined as a data structure storing the extensive-form representation of the game and atomic propositions that encode the reward structure as dictated in the attack-defense tree. For future work, encoding attack-defense trees defined in other models to be compatible with supplying payoffs in open games would be an interesting direction.

However, the models developed in \cite{Phetmanee2024} aren't built expressively for the reason of further extensionality in the future. The deliverable allows a user to provide a specific CVE and attacker action as a logical formula, and line-by-line entries for associated costs for specific attacker or defender actions. Finally, a security expert can input a certain patch or security property to test for Stackelberg equilibrium and whether that security property can be satisfied. 

The output of the StEve tool and the open-games diagnostic info are similar in terms of displaying each players associated payoff. However, the open-games-engine doesn't prove any satisfiability constraints, it's up to the modeller to check all possible states, whereas PRISM will be able to compute equilibrium automatically. Thus, StEve requires less understanding from security experts for running the game model, but prevents any amendments to game structure, such as an attacker being first-to-act rather than the defender. Working in the open-games environment necessitates more direct construction of the game with at most the import of the security games provided as a template in this thesis, but allows for greater maneuverability.

Comparatively, working in Haskell vs PRISM comes with the advantage of a type checker and various other language tools that will be expounded upon in the following chapter. An example difference is not needing to translate into a temporal logic formulae, but writing property tests using Hspec. The perceived downside is the inherent difference in computational complexity and running time for these models, which has yet to be determined. But from a useability point-of-view, a modeller can programmatically generate different attack or defense strategy profiles to test for any given model, with the tradeoff of not having a compact logic to run through the usual model-checking techniques. 

\subsection{Direct translation}
\label{designPatterns:directTranslation}
This study begins by following a procedure to first naively translate models from literature without any design patterns or meta-modelling structure. 

\begin{enumerate}
	\item Identify pre-existing security game models in literature 
	\item Implement these models to reproduce the expected results using open games
	\item Identify and generalize constructions used across models
	\item Analyze flexibility of models and analytical techniques 
\end{enumerate}

For the first step, we minimized our game type search to a particular subset of two-player cybersecurity games, in the broad setting with a defender in the role of deploying resources for protecting a computer network. An attacker also broadly falls to a role of attempting to access or control this computer network. We did not place restrictions on selecting these models to align by the technologies being assessed or a fixed type of cybersecurity attack, with the eventual aim to abstract these away from the game formulation. By reviewing the aforementioned surveys, we found that that many games falling under this classification can then be organized by a game-type (Bayesian, Stochastic etc.) each with their own notations, parameter restrictions, and payoff formulations. 

In the second step, the unstructured approach is used to establish a baseline for this study by hardcoding each of these specifications into a Haskell module. To maintain expressiveness and readability, we use appropriate variable names and global-scope constants for model-specific values. However, we wrote each of these modules in isolation, without considering any relationship or replicability in other modules. 

In the following chapter, we primarily focus on the third point by codifying specific design patterns for a more generalized game construction process. We chose four models from literature as detailed in Table \ref{table:baseline} to serve as the baseline for direct translation from the corresponding paper to its representation as open games. 

For the final step, no metric has been established for conducting a comparative analysis with other tools. We leave this for a future behavioural study, for security modellers across disciplines and skillsets to follow the presented design patterns to generate models. Possible metrics could involve productivity or real-system performance determined by the findings extracted from a model. 

\begin{figure}
	\label{figure:DirectTranslation}
	\centering 
	\includegraphics[width=\linewidth]{DirectTranslation.png}
	\caption{Flowchart of direct translation design process with game dependencies}
\end{figure}

Ultimately, direct translation is a non-uniform process at first glance, since the structure and parameters of the game are highly-dependent on the game type. Each source game model comes with its own specification in differing formats. A natural language description of the game formulation is the initial descriptor of the model, but later use tables for storing game parameters, conditions, and graphical notations like extensive-form game trees as in \textbf{Honey} and transition graphs as in \textbf{IDSMark}. In \ref{figure:DirectTranslation}, the red arrows demonstrate the process of a modeller reading the source game formulation and directly implementing it into an open game. However, we can't establish a relationship between the analyses on the far left to any analysis in the open-game-engine on the far right. The open-game-engine analysis is only dependent on the types and functions required to make the open game code block executable such as strategies. 

The black dotted lines in the "Game model specification" represent a qualitative or quantitative dependency from one game to another. An example \label{example:quantDepend} of an explicit quantitative dependency is where \cite{Pawlick2015} specifically adapts a signalling game from \cite{Carroll2009} by maintaining the same game structure and payoff scheme. For a qualitative dependency, we note a similar game formulation between \textbf{Decep} and \textbf{Honey} centered around the uncertainty of the attacker's type and the problem of the defender to act according to some prior belief. We immediately recognize near-identical |Nature| operators, data types corresponding to whether a server is a honeypot or normal, and the payoffs using constants such as probability of detection associated with a specific detection library. At the game formulation level, any such adaptation would then be conducted by-hand, citing a particular security specification. We would like to show that the blue dotted lines in "Open games DSL" and "Open games engine" can be explicitly established thus allowing reproducibility and consistency in-code rather than by-hand/ \footnote{We would also like any upstream changes in dependencies to be reflected in the resultant models}

Examining the resultant modules shows clear repetition along various facets, such as the DSL formulation since every game is two players, with the same attacker-followed-by-defender sequencing, with the exception of \textbf{IDSMark} which requires more operators to accommodate the repeated move structure. At the specification level, there is no implementable common language for these models to easily interchange the non-moving parts of the model such as the environment constants used to calculate payoffs or the action spaces. But after translation, the relationships between the components of the games can now be in a Haskell environment for which standard programming techniques can be applied. Recalling the explicit quantitative dependency mentioned in the previous paragraph (\ref{example:quantDepend}), the function implementing the payoff scheme should be the same for both models as open games.

\begin{table}[h!]
\centering
\begin{tabularx}{\textwidth}{||l l l X||} 
 \hline
 Module & Model name/Citation & Game type & Description \\ [0.5ex] 
 \hline\hline
 Deception.hs & \textbf{Decep} \cite{cceker2016deception} & Bayesian, two-player & Deception game to mitigate DDoS attacks \\ 
 Honeypot.hs & \textbf{Honey} \cite{li2019game} & Bayesian, two-player & Distributed honeypot deployment mechanism game models \\
 IDS.hs & \textbf{IDS} \cite{Chen2009} & Bayesian, two-player & Intrusion detection systems for heterogenous networks game models \\
 IDSMarkovChain.hs & \textbf{IDSMark}\cite{lye2005game} & Stochastic, two-player & Stochastic game over network state \\ [1ex] 
 \hline
\end{tabularx}
\caption{Baseline model implementations}
\label{table:baseline}
\end{table}

Furthermore, out-of-the-box equilibrium checker can verify equilibrium results from the paper (i.e. parameter values for which equilibrium is achieved), there is no analogous equilibrium-solving process in open games. However, with the input data for running the equilibrium checker comprised (typically) of floating point numbers, it should be possible to check for equilibrium under certain conditions. Additionally, the diagnostics are well-suited for reading expected payoffs as a result of the game. 



\subsection{Design patterns}
\label{designPatterns:library}
After analyzing the direct translation process, we can separate the responsibilities of the components that instantiate a model. These are specifically implemented as modules (dubbed \textbf{Security} modules in-line with the repository). The key advantage is that these three modules are dependent on each other through custom types relevant to the model. Given that specification, they can be developed independent of each other, then brought all together into a top-level testing suite for model-wide evaluation. The following section will tie these modules together into a streamlined, Agile-inspired workflow. 

\subsubsection{Module 1: two-player open games}
The first abstraction that can be leveraged is generalizing the two-player interactions. 
Readers may refer to \textit{AttackerDefender.hs} module for the complete documentation of these games. An example of a two-player template game is below: 

\begin{minipage}\textwidth
\scriptsize
\begin{code}
twoPlayer distType a1 name1 a2 name2 = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:
   inputs: ;
   feedback: ;
   operation: nature $ distType;
   outputs: visitorType;
   returns: ;

   inputs: visitorType;
   feedback: ;
   operation: attackerLeader name1 a1;
   outputs: attackerDecision;
   returns: attackerPayoff;

   inputs: attackerDecision;
   feedback: ;
   operation: defenderFollower name2 a2;
   outputs: defenderDecision;
   returns: defenderPayoff;

   :----------------------------:

   outputs: visitorType, attackerDecision, defenderDecision;
   returns: attackerPayoff, defenderPayoff;

 |]
\end{code}
\end{minipage}

In the Bayesian setting, we want to allow players to be able to observe a private type. Then, any direct observed inputs of a player are determined by the order-of-play. The following template code is used to dictate a game where an attacker moves first, with a private type. In the \textbf{outputs} and \textbf{returns} fields, we can see the template game exposes all the data generated within the game and receives the corresponding payoffs externally. The |name1| and |name2| are set by the modeller to help read the diagnostic information. 

Treating this open game as a first-class citizen for implementing large, complex models comes with many advantages. These can be composed sequentially, leading to possible chains of independent 2-player security interactions. Composing in parallel allows a modeller to dictate simultaneous play \footnote{conceptually, not necessarily physically playing simultaneously} of these security interactions. Since the payoffs are determined external to this building block, calculations can be written in a separate module. 

\begin{figure}
	\centering
	\includegraphics[width=\linewidth]{IDNBlockDiagram.png}
	\caption{A block diagram for an IDN, for three subsystems from \cite{Jin2018} \label{figure:Fig. 3}}
	
\end{figure}


\begin{mdframed}
\begin{example}
Consider the architecture of a typical IDN as seen in Figure \ref{figure:Fig. 3}. The model developed in \cite{Jin2018} is a two-layer stochastic, game between an attacker and an IDN, where the states of the game are defined by the status of each subsystem. Here, the assumption is that the capabilities of each of the IDSs and their respective attackers as homogenous, but working independently. In particular in the \textit{Simulation} section, the proposed model is evaluated with a specific set of parameters in a network of three IDSs and three independent attackers. If the assumption of homogeneity was to change, the parameters used to evaluate the model must also change. Maintaining consistency across the model requires flexbility, but current game formulation techniques aren't necessarily built with the notion of seamless integration.

From a security design point-of-view, this interaction between subsystems is vital, especially if a vulnerability in one system affects the defensive capabilities of another. After designing games for a subsystem, we can easily direct the flow of the result of the game to a level-higher for resource management. Designing this IDN using open games allows us to work on each subsystem separately from the aggregation mechanism. The disjoint nature of these parts allows for testing the efficacy of a different aggregation mechanisms or subsystems. Each subsystem interaction can then be instantiated as three functions using the template two-player game, but each parameterized accordingly \footnote{In order to run simulations using the constructed model formulation, the authors assigned values such as the detection libraries available to each IDS system $i$ and attacking libraries for each attacker $j$. \cite{He2015}.}. Then, the logic for the aggregation mechanism is defined as a separate open game which takes as input the outputs of the three previous functions. 

\end{example}
\end{mdframed}


\subsubsection{Module 2: model parameterization}

Outside the structure of the game, we organize the pipelined data necessary for decision making and payoff calculation into a single module. This module is the arena for modellers to construct abstract data types (ADT) corresponding to model-relevant parameters. Exogenous parameters, or parameters defined outside of an open game, can be hardcoded values. Exposing this module to all other modules allows each of them to access the relevant data as needed. No logic related to the game structure or calculating payoffs, we treat this module closer to a configuration file to dictate the available types that can be used. This also places no restriction on how many models use these parameters, allowing for related variant models accomplishing different tasks. Expectedly, any changes made at this level would reflect on its dependencies as a compile-error, for example in the case of adding a new parameter called for by the specification team. 
\begin{minipage}\textwidth
	\begin{code}
	data IDSParams = IDSParams {
	probDetected :: Double,
	costOfAttack :: Double,
	costOfDefense :: Double,
	attackImpact :: Double,
	priorDistributionAttacker :: Double,
	computingResources :: Double,
	basePayoff :: Double,
	computationReductionUnderAttack :: Double
} deriving Show

\end{code}
\end{minipage}

The only other fixed data types we would like to set here are the actions available to the models. See \textbf{IDS.IDSModel.hs} for a fully worked-out example.

Lastly, any test-data can be hardcoded here. But auto-generating each field of the data type is also possible using the |Test.QuickCheck.Gen| module. We can provide an implementation that sets clear guidelines for how to randomly generate each of the values. 
Below, we can generate test-data varying along the prior probability of an IDS encountering an attacker. We can manually sample test data using |totalGen|, or testing frameworks that generate test cases will use this implementation when testing over |IDSParams|. 
\begin{minipage}\textwidth
	\begin{code}
	totalGen :: Gen (IDSParams)
	totalGen = 
	    do 
	        probDetected <- choose (0,1)
	        return IDSParams {
	                probDetected = probDetected,
	                costOfAttack = 20,
	                costOfDefense = 10,
	                attackImpact = 10,
	                priorDistributionAttacker = 0.5,
	                computingResources = 100,
	                basePayoff = 100,
	                computationReductionUnderAttack = 70
	        }
	
	\end{code}
	
\end{minipage}

\subsubsection{Module 3: designing payoffs}
We can also recognize the similarities between how these types are used for computing payoffs. The instantiation of games by action space informs the types exactly available for designing payoffs. Since a model doesn't 'require' any specific payoff behaviour beyond these types (and maybe fitting into a test infrastructure). We can loosely characterize payoff functions by their dependence on the following information: 
\begin{enumerate}
	\item The output of the open game 
	\item Model-level exogenous parameters from \textbf{Module 2}
\end{enumerate}

An example of 1. in a simple case is a tuple of actions chosen by each player in the game, or the assigned player type. 2. is concerned with system parameters that are relevant to payoff data. Here, we propose the reader monad as the necessary function-passing structure for generating payoff functions according to these model-level exogenous parameters. The reader monad is well-suited to passing a configuration in functional programs, and easily accessing fields of record type with the |asks| operator. Let's see how this is used in-production.

\begin{code}

type PayoffReader a = Reader a Double

runPayoff :: a -> PayoffReader a -> Double
runPayoff params reader = runReader reader params

\end{code}




Notice the parametric type \textit{a}, so we can define a |PayoffReader| for any ADT containing exogenous model parameters. This supports the system-level-first architecture that allows a modeller to introduce relevant variables that are not directly involved and subject to manipulation separate from the interworkings of the open game model. Thus, we can actively test how different payoff schemes affect our game model, either by (1) testing the same game with different system variables or (2) the same system variables with different player capabilities. We can characterize a payoff profile's dependence on two things: the outputs of the open game, and the variables accessible with the |PayoffReader|.

Already we can consider branching the payoff functions into helpers associated with each type of player, and pattern-match on these types. If we use the preset two-player template from the \textbf{Security} module, the set of two-player security games requires a |PayoffReader| for each attacker and defender. Then at the execution-level of the game, which runs against the model-level parameters, we use these parameters to instantiate the readers (in this case, |IDSParams|). Thanks to the type-checker, the output type of the model should provide the modeller with the requirements for this |PayoffReader| constructor. 
\begin{mdframed}
	\begin{example}
		To design payoffs, we can start by fixing our model parametrs to follow |IDSParams| datatype as defined in \textbf{Module 1}. For one such implementation of describing an attacker's payoff, we can read from our config to assign values according to the (covariant) output of an open game, in this case dependent on the attacker and defender move. Pattern matching over the results can be read as "if the attacker attempted access, and a defender did not allow it, then the attacker recieves |costOfAttack|" Note that |attackerAccessPayoff| collects the values it needs, then does a computation.
\begin{code}

attPayoff :: AttMove -> DefMove -> PayoffReader IDSParams
attPayoff Access Open = attAccessPayoff
attPayoff Access Close = asks costOfAttack
attPayoff DoesNotAccess Open = (* (-1)) <$> attAccessPayoff
attPayoff DoesNotAccess Close = return 0

attAccessPayoff :: PayoffReader IDSParams
attAccessPayoff =
    do
		coA <- asks costOfAttack
		basePayoff <- asks basePayoff
		probDetected <- asks probDetected
		return $ (basePayoff - coA) * (1 - probDetected) - coA * probDetected     
\end{code}
	\end{example}
\end{mdframed}


The implementation of \textbf{Module 2} in the \textbf{Security} library provides the necessary functions to extract the actual numeric payoff from the reader, then package the payoffs into a |StochasticContext| so it's ready-to-use for the diagnostic functions. We can also further develop functional tests written specifically to ensure the behaviour of this module follows the required specifications, or even just a sanity check. This extra capability gives an added layer of ensuring correctness, without having to consider the entirety of the model. 


\begin{mdframed} \textwidth
   \begin{example}
      A key feature of using the reader monad is having fine-tuned control over these parameters without worrying about changing them. And if we do need to change them, it's explicit. Consider the payoff scheme used to slightly adapt the previous example by allowing the defender to not just open or close, but deploy two different kinds of honeypots or remain open under normal operation. Refer to \textbf{IDS/IDSAPayoff.hs} for the complete implementation, and \textbf{IDS/IDSAPayoffHP.hs} which explicitly adapts it. 

The type signature only differs in the third argument to the payoff functions. Intuitively, we will have to write the same pattern-matching structure but over the new datatype |HoneypotDeploymentMove|, but the computation of payoff shouldn't have to be rewritten explicitly. Since in our model, deploying a high-interaction honeypot increases the probability of detecting an adversary, this can be reflected by locally altering the |IDSParams| before using the same formula from \textbf{IDSAPayoff}. So given a |HoneypotDeploymentMove|, we want to update my |PayoffReader| with an augmentation function such as: 

To demonstrate the breadth of this granularity, we observe the following example for designing payoffs derived from an initial problem statement.

\begin{enumerate}
	\item Assumption: there is only one attacker and one defender
	\item Assumption: the defender can either allow traffic or close the server 
\end{enumerate}

The factors that we consider that dictates the payoff would be included in the config given by \textbf{Module 2}. Here, without having to change this global config, we use |local| to adjust the detection probability. 
   \end{example}
\end{mdframed}

\subsubsection{Module 4: property tests for model verification}
At this point, a modeller may be asking questions such as "is equilibrium reached under this system configuration and payoff calculations." This module leverages the Hspec testing library which has a nice tradeoff of writing human-readable specifications, and uses \textit{Gen} for these parameters to generate random test-data. 

A single experimentation test should be generalized under a broad goal using |describe|. The subsequent property tests are then defined using the |it| operators to designate the evaluation of a completed model. The |property| operator requires a boolean-valued function, so expectedly a modeller is in the position to extract properties based on this evaluation. \footnote{This resembles a model-checking approach in the multiagent-systems verification field, where a propositions are developed by a modeller which must be checked for each state of a state-transition structure}. 

\begin{minipage}\textwidth
\begin{code}
describe "Experiment 1: comparing defensive system A with system B"|
	it "should be in equilibrium under these conditions" $ 
            property $ \params -> myProposition
\end{code} 
\end{minipage}

Here, |myProposition| would be determined by the modeller as a result of evaluating a target model. Extra code to extract payoffs for specific players are necessary, but this logic would be designed to extract propositions such as "for all the test data, my model is in equilibrium". In terms of complexity, this evaluation is run for each test case of |params|. But how are these test cases generated? Precisely by the test data and model-wide data instantiation in \textbf{Module 1}. Without an explicit implementation of |Test.QuickCheck.Gen| for the supplied data type, we can end up with a number of test cases on the order of all the possible combinations over all the possible values within the natural range of each of the fields. This isn't computational feasible, but conceptually not useful to modellers anyways. Any valid experiment to extract results means investigating how one or two exogenous parameters affects equilibrium or payoffs. 
\begin{mdframed}\textwidth
\begin{example}

\end{example}
\end{mdframed}


\subsection{Iterative modelling using open games}
A methodology to promote greater synergy between the initial conception of a security problem to it's game-theoretic translation is needed. 


We propose the general procedure:
\begin{enumerate}
	\item High-level model specification
	\item Game structure as an open game 
	\item Designing payoffs according to model specification
\end{enumerate}

\subsubsection{High-level model specification}
To begin the formulation process, a modeller identifies the specifications of the problem. We dub this "high-level" as a way of top-down identifying system-level and exogenous parameters relevant to the problem. The objectives of this stage are summarized as: 
\begin{enumerate}
	\item Identify players (attackers and defenders)
	\item Quantify action spaces and encode as Haskell data types
	\item Encode relevant system parameters as a Haskell data type
\end{enumerate}

 

\subsubsection{Game-level specifications}
One level lower, we can consider game-level specifications, or in other words, the variables we consider directly in the game. These consist of action spaces in the usual sense, in this workflow as a list of data types. Constructively speaking, we first fix our exogenous parameters, then we fix the game-level parameters which characterize each player's capabilities. We also note the dependence between payoff structures and these exogenous parameters. The payoff structure can remain separate from the flow of the game.


In this chapter, we show how to use the Haskell environment to generate parameters and specify the parameter space of games. Afterwords, compatible games written in the DSL can be simulated using these parameters.

There are many computational tools that exist in order to solve for equilibria, produce extensive-form game-trees, and SMT-solvers. But what we would like to outline in this chapter is being able to simultaneously generate games in a declarative manner, where the game formulation process is aided by the open games Haskell DSL. We'll see how after a few attempts, generalizing these patterns allow for model \textit{reproducability} and \textit{reusability}, ultimately culminating in a small library of 2-player security games. We will see how this simple subset of game scan be used to rapidly generate game theoretic models in a variety of settings. By leveraging abstract data types, polymorphism, and the reader monad, we can parameterize these models with modules that help organize payoff modules and strategies. 


\subsubsection{Related iterative design processes}

% The spirit of this thesis has certainly been explored in other work, for example in the simulation procedure provided by \cite{Nochenson2012}. This thesis attempts to mechanize the claims for "easily extendable" or "replace lines 9-13 in Algorithm 1."

An iterative-style approach is further alluded to \cite{wellman2006methods}, a simulation-based approach to inform the general game-theoretic design process 

According to section 6.1 on IDS optimization in \cite{Collins2025}, there is a recommendation for characterizing and distinguishing different kinds of attackers and varying objectives.  

Many game-theoretic models in security rely on ad-hoc schemes \cite{Liang2013}. The authors also cite a need for standards for designing payoffs and more scalable methods to match the complexity of the security problem, such as building a model that considers more than three players. The cybersecurity problem specifications dictate the parameters and format of the model, creating a hyper-focused game. So translating the real-world security situation to a model using the same toolbox of game-theoretic mechanisms implies the need for the right sandbox to test different real-world translations and how they respond in the game-theoretic model. 

%Therefore, we need to develop abstractions that allow for systematic instantiation of game-theoretic models according to \textit{many} of these real-world translations. 
The work conducted in \cite{Caulfield2015}, \cite{Caulfield2014} closely resembles compositional and software-supported approach in security modelling by \textit{a priori} designing models that can be composed together later. Here the authors present a systems modelling theory for security policy design. Using a semantic-approach based on process theories to model elements of a security situation as resources of these theories, these concepts can be encoded in Julia to run simulations. They show composition of models is well-defined and demonstrate how to run these models based on individual expected utility. The result is a model to help inform security policy managers make better decisions about security systems and have a framework to convey this information to other stakeholders.  

This modelling approach is focused on the security of an organization comprised of three sequentially-composable models: (1) a device-loss model, (2) a tailgating model, and (3) a document-sharing model. The pitch most strongly reminiscent to this thesis is that a modeller can adaptively see how including or excluding elements of a model to the workflow affects the system in a reactive way. For example, the modeller can examine the simulated data of just the tailgate model with and without the presence of a security guard on the frequency of computer accesses, and then observe the impact of the same presence of a security guard in the large composed model. This layered approach of designing locations and resources on a layer under the decision-making layer of agents hints at a design approach that separates the concerns of the model from its instantiation. This thesis tackles a different class of security problems but mirrors the task of formalizing security problems in a compositional and iterative way.

Furthermore, an iterative, formalized process for refining games is not new. In particular, \textit{empirical game-theoretic analysis} is a methodology that learns payoff profiles and strategy spaces through simulated data to inform the game formulation. Specifically, the goal is to instantiate an empirical game which is parameterized by simulating expected payoffs according to a strategy profile. Two feedback mechanisms are leveraged: (1) payoff estimation and (2) strategy space exploration.  This methodology has seen its applicability in moving target defense \cite{Wellman2015} and adaptive cyber defense \cite{Wellman2019}. Further extensions for a software-induced workflow, including database support and use of Gambit, can be found in \cite{EGTAOnline}. Figure \ref{figure:Fig. 2} provides a pipeline for generating these games. 

\begin{figure}
	\begin{center}
		\includegraphics[width=0.75\linewidth]{EmpiricalAnalysisPipeline.png}
		\caption{A general modelling process from \cite{Wellman2015} \label{figure:Fig. 2}}
		
	\end{center}
\end{figure}

\begin{figure}
	\centering
	\includegraphics[width=0.75\linewidth]{EGTAFeedback.png}
	\caption{Empirical game-theoretic analysis pipeline from \cite{Wellman2019} \label{figure:Fig. 3}}
\end{figure}

%The modelling methodology that will be proposed in this thesis follow more closely to \cite{Nochenson2012} and \cite{sengupta2017game}. 
%\subsection{Towards generating libraries for security models}
%An ancillary benefit of using a methodology insisting on flexible, open-interfaces is self-documenting, executable models for reuse later. 
%\subsubsection{Empirical approach to designing utility functions}
%For Bayesian security games, payoffs can be associated with types assigned to each player. 
%\subsubsection{Empirical approach to designing strategies}



% Providing a small subset of games as a library, this falls short of a clear-cut executable script for a predetermined model. 



\subsubsection{Towards test-driven modelling}
Test-driven development (TDD) is a coding paradigm where a programmer begins with unit tests and iteratively refactors code to fulfill these tests and write new ones. A programmer doesn't move on to the next iteration until the entire test suite passes, ensuring that refactors don't cause breaking changes across a code-base. The very first test case in any situation is to verify the most basic assumptions for the behaviour of a program. And as the complexity and dependency of this program grows, these assumptions are always kept in check. TDD enables the coder to think about specifications first, and while those specifications are open to change over time, writing these tests document the expected behaviour of the program. 

Here I propose test-driven modelling as a way to guide experiments in a self-documented fashion, while also maintaining guarantees of a game before its eventual composition with others. 

It's a well-known fact that in the problem of a player allocating finite defensive resources across a series of subsystems, for example by employing maximum, high-cost 


% \subsection{A few SOLID principles}
% Open for extension ,closed for modification. The hallmark of this design strategy . Just as we might want to consider an additional player, we can easily replicate a utility-maximizing agent using the DSL. Similarly, if we would like to consider an additoinal model parameter or 

% Having a modular language allows us to construct games open for extension, by interacting with the interfaces exposed by each game. 

% IDEA: We want to encode our "assumptions" such as paraemter bounds, sign, and relative values. We cna quickcheck these as part of the simulation process in order to preliminarily check that test parameters used for simulation accurately reflect the given values. 

