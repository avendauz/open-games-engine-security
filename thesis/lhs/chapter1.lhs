\section{Modularity in game theoretic cybersecurity modelling}
\label{sec:1}
\subsection{Overview}

The stark reality of designing effective cybersecurity games is bridging real-world security concerns with an accurate representation in a game-theoretic terms. Numerous models have been constructed and analyzed according to specific security problems, thus tying the models to their specification. Furthermore, these models often extend or adapt previously existing constructions by making new assumptions, using different payoff schemes, or integrating the model into an automated defensive infrastructure. Although this informal relationship between these models have been surveyed, there has yet to be a generalized framework for mechanizing this relationship as a standardized game formulation process. 

In this chapter, we examine a variety of security games and remark on similarities and differences between game-formulation methods. By identifying and encoding the commonly-used 2-player security game in the open-games-DSL, we show how to recover more complex models using this as a building block. By working in the open-games-DSL, a modeller can control information flow, introduce parallel subsystem security interactions, and reuse models. I review current security game analysis methods and present the possibility of integration with other tools. Finally, I propose an \textit{iterative development}-esque model generation process using the open-game engine.




%Indeed, the same code to analyze the intorduction of a single security interaction can analyze it in the context of a larger security infrastructure in a verifiable way.

%	 With an open-interfaced game representing a single security interaction, I demonstrate how a modeller can parameterize the game according to their security specification. 

%Finally, following
%The result of creating this representation is a game-theoretic model strictly tied to a security concern that is often encompassed by a larger security infrastructure. The system we may be trying to model is often comprised of subsystems. As attackers or defenders of this system we can think about an attack on the system as a whole or on its parts, or a mixture of both. 


 


% DOMAIN EXPERT

\subsection{Current state-of-the-art}
Using game theory to inform cybersecurity problems has seen growth in recent years with the development of a number of different models for evaluating Denial-of-Service attacks on cloud infrastructures, intrusion detection systems, and advanced persistent threats. Refer to the following surveys \cite{Pawlick2019}, \cite{Hausken2024}, \cite{Manshaei2013} for an overview of the wide collection of game-theoretic models. 

A general procedure for developing these models can be (roughly) summarized in the following steps: 
\begin{enumerate}
	\item Detail the security scenario and system, vectors of attack, and defensive capabilities
	\item Develop abstractions  and parameters for the players, actions, and payoff in a game-theoretic setting according to the security scenario
	\item Solve for a solution concept (i.e. Nash equilibrium, Subgame perfect Nash Equilibrium) using methods such as linear programming or Q-learning (for stochastic or repeated games)
	\item Deploy new strategies or technologies in the system according to the solution concept above
	\item Conduct simulations with a fixed strategy, determine the highest expected utility for players and evaluate system performance under these conditions
\end{enumerate}

However, the most recent concerns with evolving attacker threats and dynamic security situations requires more complex game-theoretic models. These games can be part of a larger automated defensive system to update defensive strategies in real time as part of a larger infrastructure such as in \cite{Jin2018}, \cite{Zhu2012}. The progression of these models often relies on the extension and variation of these game-theoretic models. For example, we may need to consider scalfing the number of players or repeating strategic interactions. The models presented in \cite{Chen2009}, \cite{Nochenson2012} suggest the use of the models as a basis for extensions and increased-complexity for other security scenarios. Similarly in \cite{Pawlick2015}, the signalling game structure are derived from \cite{Carroll2009}, with adjustments to the utilities. We'll see later how these models written in open games allow for easy extensionality.

According to \cite{Collins2025} evaluating 86 different game-theoretic models in cybersecurity, there already exists a sense of homogeneity between these models, where 76\% of models only cover a two-player security interaction, and 79\% use Nash (or variants of) equilibrium solution concepts for analysis. The authors also recommended a formal method for modellers to state their assumptions of the model that follow more in-line with cybersecurity concepts. Expanding on this idea in particular, we propose that code-based methods for stating assumptions allows for clear, testable specifications (see \ref{sec:2}). Only 24 or the 86 studies shown consider "multiple variants" of the constructed model. The specification of two criterion: (1) "Efficacy of Modelling" and (2) "Practicality of Solutions" serve as a framework for evaluating the tractability of game-theoretic models' representation of the underlying real cyber-interaction. The resulting recommendations are taken into account for the purposes of this thesis: 
\begin{enumerate}
	\item The need for a game space abstraction 
	\item Allow for more flexible assumptions
\end{enumerate}

In that same vein, \cite{Egan2025}, \cite{Liang2013} call for better scalability of models, in particular addressing models that account for more than two player games. Similarly, \cite{lye2005game} 
%\subsubsection{Qualitative to quantitiative parameterization}
%\cite{Rass2017}
%This necessitates collaboration between a domain expert (e.g. cybersecurity expert) and a game-theorist to translate sensible payoff schemes and parameters. 
%
%On the other hand, databases such as NIST and CSVV are directly used in \cite{MacQueen2020} \cite{Furuncu2015}. Diving deeper into \cite{Chen2009}, the work does not consider correlation between attack targets and leaves it for future work. The theoretical basis for the payoffs involving reputation, punishment for loss contrasts with other payoffs using server downtime or capital expenditure from NIST (CVSS) metrics. 

\subsubsection{Discussion on rational verification}
Rational verification is an approach to verifying the properties of multiagent systems where each agent is self-maximizing over some preference or utility. Inspired by classical model-checking paradigms, a specification is provided as a temporal logical formula describing a desired property of a multi-agent system. Then, the question is to verify whether a run (or simulation) of the system for some strategy profile is an equilibrium satisfying the property. Therefore, I consider open games as exactly the mechanism for expressively developing these systems with a built-in way to simulate behaviour. 

By using the PRISM-model checker and the PRISM property-specification language, it has been shown that security games can be mechanically verified. More recent work has extended PRISM to handle Stackelberg equilibrium for security games \cite{Phetmanee2024}. The complete software for two example models can be found at \cite{phetmanee_2024_13338608}. According to the proposed worfklow, there are automated tools to translate CVEs to attack-defense trees to Stackelberg Security Games, defined as a data structure storing the extensive-form representation of the game and atomic propositions that encode the reward structure as dictated in the attack-defense tree. For future work, encoding attack-defense trees defined in other models to be compatible with supplying payoffs in open games would be an interesting direction.

However, the models developed in \cite{Phetmanee2024} aren't built expressively for the reason of further extensionality in the future. The deliverable allows a user to provide a specific CVE and attacker action as a logical formula, and line-by-line entries for associated costs for specific attacker or defender actions. Finally, a security expert can input a certain patch or security property to test for Stackelberg equilibrium and whether that security property can be satisfied. 

The output of the StEve tool and the open-games diagnostic info are similar in terms of displaying each players associated payoff. However, the open-games-engine doesn't prove any satisfiability constraints, it's up to the modeller to check all possible states, whereas PRISM will be able to compute equilibrium automatically. Thus, StEve requires less understanding from security experts for running the game model, but prevents any amendments to game structure, such as an attacker being first-to-act rather than the defender. Working in the open-games environment necessitates more direct construction of the game with at most the import of the security games provided as a template in this thesis, but allows for greater maneuverability.

Comparatively, working in Haskell vs PRISM comes with the advantage of a type checker and various other language tools that will be expounded upon in the following chapter. An example difference is not needing to translate into a temporal logic formulae, but writing property tests using Hspec. The perceived downside is the inherent difference in computational complexity and running time for these models, which has yet to be determined. But from a useability point-of-view, a modeller can programmatically generate different attack or defense strategy profiles to test for any given model, with the tradeoff of not having a compact logic to run through the usual model-checking techniques. 

\subsubsection{Study methodology}
Based on these observations, the study of this thesis proceeded as follows.
\begin{enumerate}
	\item Identify pre-existing security game models in literature 
	\item Implement these models to reproduce the expected results using open games
	\item Identify and generalize constructions used across models
	\item Analyze flexibility of models and analytical techniques 
\end{enumerate}

For the final point, no metric has been established for conducting a comparative analysis with other tools. We leave this for a future behavioural study, for security modellers across disciplines and skillsets to follow the presented design patterns to generate models. Possible metrics could involve productivity or real-system performance parameterized by the findings given by the model. 

\subsection{A first-attempt example}
In this section I'll detail a contrived example, as a first-pass to using the open-game-engine. I'll briefly cover how to interpret some of the fundamental parts of using the engine and understanding the diagnostic information provided in the output of an evaluation. I'll use code snippets to illustrate the thinking behind constructing each game, but I refer readers to the provided codebase for complete and executable models.

Breaking this down, we'll say the \textit{attackerDefenderGame} is a generic 2-player security game, in this case with the defender being able to observe the attacker's decision. We can represent a utility-maximizing attackers and defenders in code using the \textit{dependentDecision} function, which returns an open game. 

In games of \textit{incomplete information}, players have their own private types that are hidden from others. This is a common structure for security games, where a defender has to optimize their defensive strategies with uncertainty of the type of the adversary. This is a common structure used in Bayesian security games, typically by identifying behaviour of either an attacker or defender and their capabilities. In this case, the \textit{nature} game can be parameterized by a distribution over user-defined visitor types.  

As a modeller, I'm concerned with instantiating this interaction to my needs by supplying the required parameters given as arguments for \textit{attackerDefenderGame}. A well-researched optimization problem in cybersecurity is resolving a networks uncertainty about a user that has logged into the system, whether the user is a typical, honest user or an adversary \cite{}. The following details a way to instantiate this game with the arguments: 

\begin{enumerate}
	\item  \textit{distType} as a distribution \textit{distFromList[(User, 0.5), (Attacker, 0.5)]} to demonstrate a 50\% chance of encountering an attacker. \textit{distFromList} is a function that returns a distribution according to a list of tuples corresponding to the probability a certain type is drawn. 
	\item  \textit{actionSpaceAttacker} as a list \textit{[Access, NotAccess]} 
	\item \textit{actionSpaceDefender} as a list \textit{[Open, Close]}
\end{enumerate}

As with Bayesian security games, payoff behaviour is inherently tied to the types of the players. A simple hard-coded set of Haskell functions can be used to associate payoffs as \textit{Double} to be supplied to each player as \textit{attackerPayoff} and \textit{defenderPayoff}. Since there has to be a payoff for each possible outcome of the game, that would be exponential in the size of the action space of the model, in this case ${2^3}$ For defining payoffs, we can use a variety of sources but up to the discretion of the way we choose to model this encounter. In the commonly-used story-book style of describing this, we can say if the visitor is an attacker that attempts to access a server and the defender allows this access, the payoff is 100, which corresponds to a base payoff for a successful attack.

Thus this may be written as a Haskell function that pattern matches over each of these possibilities, partially written as: 

Thinking in a classical game theory style, this game can be represented as a balanced extensive form game tree, with sequentially-played subgames corresponding to each possible type doled out by the Nature player at the root node. Under each of the two types, the attacker can make two choices, and for each of these two choices, the defender can make two choices. As expected, each of the 8 leaves of the tree have the corresponding payoffs that would match the above payoff function.

Finally, given this payoff function (or more formally, a context to close the game), we would like to determine whether a strategy profile is included in the best-response relation generated by this model. Let's take a pure strategy profile such that the visitor always accesses regardless of type, and the defender opens access regardless of the visitor's choice. We can write these strategies as Kleisli arrows as follows: 


A straightforward to read the type signature of these strategies, assuming no previous knowledge of Kleisli arrows, is providing the \textit{Kleisli} constructor with a function that takes as input exactly what the player observes as input in their open game representation. In this case, for the attacker strategy, the "inputs" field is the \textit{visitorType}, so we need the attacker's corresponding strategy to have \textit{visitorType} as input. Similarly, the return type of the function we pass to the \textit{Kleisli} constructor almost exactly matches up with the "output" field of the open game, again for the attacker the type \textit{VisitorMove}. The only catch is that we're allowing for probabilistic choices as dictated by the \textit{Stochastic} type constructor, so we use the handy \textit{playDeterministically} helper function which wraps the value into this type, "playing" that value with probability 1. 

Now we have the bare ingredients to do some analysis on this game. The basic question we can now ask is, are these strategies for the attacker and defender a Nash Equilibrium? In other words, are the strategies such that no player is incentivized to unilaterally deviate their strategy? The current form of the diagnostics provided by the open-game-engine include payoffs given each player plays according to their supplied strategy, and the maximum possible payoff for another strategy. To put it more explicitly, each \textit{OpenGame} implements functionalities corresponds to the definitions in (\cite{HedgesThesis}, \cite{BayesianOpenGames}), as \textit{play} and \textit{evaluate}. 

\begin{enumerate}
	\item \textit{play} corresponds to the play function which takes a strategy as input, and returns an optic describing the behaviour of the game. 
	\item \textit{evaluate} encapsulates the best-response relation (or equilibrium function) found in open games literature, which takes a context and strategy as input, and determines whether that strategy profile is in the best-response set. 
\end{enumerate}





\subsection{Identifying compositional trends}
%Open games aren't necessarily a catch-all for solving any modelling problem, as briefly outlined in \cite{Hedges2019}. At risk of "overengineering" a problem (another term taken from software design), we'll first verify that the inherent structural similarities of preexisting models are already indicative of a need for a compositional approach. The following figure was inspired from a talk about "flexiformal mathematics" given by Michael Kohlhase at a kick-off meeting about applying LLMs for improving proof assistants, depicting the relationship between formality  and functionality. In the context of this thesis, we'll adapt this relationship such that we'll consider formality brought on by compositionality, hence the figure's depiction of the relationship between compositionality and functionality. 
We can begin to see some of the advantages of treating game-theoretic modelling in a compositional way: these functionalities are well-defined under the composite of games, so we can observe the behaviour of players relative to each other using the same infrastructure. The interchange of these analytics and how to separate the moving pieces to effectively compare and contrast models thus ends up as a problem of organizing this infrastructure. The following chapter will detail exactly how software-engineering principles exactly encapsulate this infrastructure. 




\begin{Definition}[2-player security game]
	A 2-player security game is a strategic interaction between two utility-maximizing agents dubbed \textit{attacker} and \textit{defender}, where an attacker seeks to access, gain control, or cause damage to a system, and a defender seeks to deploy countermeasures and prevent damage and intrusion.
\end{Definition}

This definition is made purposefully vague, with no indication of sequence of play or how exactly we quantify "seeks to ..." in our model. This will be our most general definition of security game, which we will  adapt according to our specification of the problem. This immediately begins to address the issue remarked by Liang in \cite{Liang2013}, which remarks on how rigid security models can be. 

\subsubsection{Model adaptation}
After reviewing the literature, I identified where compositionality would prove effective for generating these models using open games: 

\begin{enumerate}
	\item Characterizing an attacker and a defender as an open game
	\item Lifting 2-player attacker-defender interactions to a multiplayer, layered security scenario
\end{enumerate}

A prime example of model adaptation in literature is \cite{Pawlick2015} specifically adapts a signalling game from \cite{Carroll2009}, maintaining the same game structure and payoff scheme. 

\subsubsection{Subsystem specification}
Consider the architecture of a typical IDN as seen in Figure \ref{figure:Fig. 3}. This work formulates a two-layer stochastic, two-player game between an attacker and an IDN, where the states of the game are defined by the status of each subsystem. Here, the assumption is that the capabilities of each of the IDSs and their respective attackers as homogenous. In particular in the \textit{Simulation} section, the proposed model is evaluated with a specific set of parameters in a network of three IDSs and three independent attackers. It's self-evident that if the assumption of homogeneity was to change, the parameters used to evaluate the model must also change. Maintaining consistency across the model requires flexbility, but current game formulation techniques aren't necessarily built with the notion of seamless integration.

From a security design point-of-view, this interaction between subsystems is vital, especially if a vulnerability in one system affects the defensive capabilities of another. After designing games for a subsystem, we can easily direct the flow of the result of the game to a level-higher for resource management. In the typical style of "separation of concerns," designing these models using open games allows us to work on each subsystem separately from the aggregation mechanism. The disjoint nature of these parts allows for testing the efficacy of a different aggregation mechanisms or subsystems. 


\begin{figure}
	\centering
	\includegraphics[width=0.5\linewidth]{IDNBlockDiagram.png}
	\caption{A block diagram for an IDN, for three subsystems from \cite{Jin2018} \label{figure:Fig. 3}}
	
\end{figure}

In order to run simulations using the constructed model formulation, the authors assigned values such as the detection libraries available to each IDS system $i$ and attacking libraries for each attacker $j$. \cite{He2015} 


The spirit of this thesis has certainly been explored in other work, for example in the simulation procedure provided by \cite{Nochenson2012}. This thesis attempts to mechanize the claims for "easily extendable" or "replace lines 9-13 in Algorithm 1" by providing a procedure that randomizes machine vulnerability values for each of 50.000 iterations, 

An iterative-style approach is further alluded to \cite{wellman2006methods}, a simulation-based approach to inform the general game-theoretic design process 

According to section 6.1 on IDS optimization in \cite{Collins2025}, there is a recommendation for characterizing and distinguishing different kinds of attackers and varying objectives.  

\subsection{Constructing an iterative design process}
\subsubsection{Addressing the ad-hoc design process}
Many game-theoretic models in security rely on ad-hoc schemes \cite{Liang2013}. The authors also cite a need for standards for designing payoffs and more scalable methods to match the complexity of the security problem, such as building a model that considers more than three players. The cybersecurity problem specifications dictate the parameters and format of the model, creating a hyper-focused game. So translating the real-world security situation to a model using the same toolbox of game-theoretic mechanisms implies the need for the right sandbox to test different real-world translations and how they respond in the game-theoretic model. 

%Therefore, we need to develop abstractions that allow for systematic instantiation of game-theoretic models according to \textit{many} of these real-world translations. 
The work conducted in \cite{Caulfield2015}, \cite{Caulfield2014} closely resembles compositional and software-supported approach in security modelling by \textit{a priori} designing models that can be composed together later. Here the authors present a systems modelling theory for security policy design. Using a semantic-approach based on process theories to model elements of a security situation as resources of these theories, these concepts can be encoded in Julia to run simulations. They show composition of models is well-defined and demonstrate how to run these models based on individual expected utility. The result is a model to help inform security policy managers make better decisions about security systems and have a framework to convey this information to other stakeholders.  

This modelling approach is focused on the security of an organization comprised of three sequentially-composable models: (1) a device-loss model, (2) a tailgating model, and (3) a document-sharing model. The pitch most strongly reminiscent to this thesis is that a modeller can adaptively see how including or excluding elements of a model to the workflow affects the system in a reactive way. For example, the modeller can examine the simulated data of just the tailgate model with and without the presence of a security guard on the frequency of computer accesses, and then observe the impact of the same presence of a security guard in the large composed model. This layered approach of designing locations and resources on a layer under the decision-making layer of agents hints at a design approach that separates the concerns of the model from its instantiation. This thesis tackles a different class of security problems but mirrors the task of formalizing security problems in a compositional and iterative way.

Furthermore, an iterative, formalized process for refining games is not new. In particular, \textit{empirical game-theoretic analysis} is a methodology that learns payoff profiles and strategy spaces through simulated data to inform the game formulation. Specifically, the goal is to instantiate an empirical game which is parameterized by simulating expected payoffs according to a strategy profile. Two feedback mechanisms are leveraged: (1) payoff estimation and (2) strategy space exploration.  This methodology has seen its applicability in moving target defense \cite{Wellman2015} and adaptive cyber defense \cite{Wellman2019}. Further extensions for a software-induced workflow, including database support and use of Gambit, can be found in \cite{EGTAOnline}. \ref{figure:Fig. 2} provides a pipeline for generating these games. 

\begin{figure}
	\begin{center}
		\includegraphics[width=0.5\linewidth]{EmpiricalAnalysisPipeline.png}
		\caption{A general modelling process from \cite{Wellman2015} \label{figure:Fig. 2}}
		
	\end{center}
\end{figure}

\begin{figure}
	\centering
	\includegraphics[width=0.5\linewidth]{EGTAFeedback.png}
	\caption{Empirical game-theoretic analysis pipeline from \cite{Wellman2019} \label{figure:Fig. 3}}
\end{figure}

%The modelling methodology that will be proposed in this thesis follow more closely to \cite{Nochenson2012} and \cite{sengupta2017game}. 
%\subsection{Towards generating libraries for security models}
%An ancillary benefit of using a methodology insisting on flexible, open-interfaces is self-documenting, executable models for reuse later. 
%\subsubsection{Empirical approach to designing utility functions}
%For Bayesian security games, payoffs can be associated with types assigned to each player. 
%\subsubsection{Empirical approach to designing strategies}







\subsubsection{Proposed design methodology}
After conducting these translations and adaptations from pre-existing models in literature, it was clear that there were ways to improve how these models interacted or organizing the same code i.e. DRY ("don't repeat yourself"). A methodology to promote greater synergy between the initial conception of a security problem to it's game-theoretic translation is needed. 
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

At this point, a modeller may be asking questions such as "is equilibrium reached under this system configuration." Writing the bare-minimum code as per the usual test-driven development paradigm, we can write an identity open game parameterized by these exogenous parameters, verify the test passes, and continue. We'll see in the next chapter how Hspec has a nice tradeoff of writing human-readable specifications, and how to implement \textit{Gen} for these parameters to generate random test-cases for property-based tests. 

\subsubsection{Game-level specifications}
One level lower, we can consider game-level specifications, or in other words, the variables we consider directly in the game. These consist of action spaces in the usual sense, in this workflow as a list of data types. Constructively speaking, we first fix our exogenous parameters, then we fix the game-level parameters which characterize each player's capabilities.
 

% \tikzstyle{startstop} = [rectangle, rounded corners, 
% minimum width=3cm, 
% minimum height=1cm,
% text centered, 
% draw=black, 
% fill=red!30]

% \tikzstyle{io} = [trapezium, 
% trapezium stretches=true, % A later addition
% trapezium left angle=70, 
% trapezium right angle=110, 
% minimum width=3cm, 
% minimum height=1cm, text centered, 
% draw=black, fill=blue!30]

% \tikzstyle{process} = [rectangle, 
% minimum width=3cm, 
% minimum height=1cm, 
% text centered, 
% text width=3cm, 
% draw=black, 
% fill=orange!30]

% \tikzstyle{decision} = [diamond, 
% minimum width=3cm, 
% minimum height=1cm, 
% text centered, 
% draw=black, 
% fill=green!30]
% \tikzstyle{arrow} = [thick,->,>=stealth]
% \begin{figure}
% 	\centering
% 	\begin{tikzpicture}[node distance=2cm]
		
% 		\node (start) [startstop] {Security specification};
% 		\node (game) [startstop, below of=start] {Game specification};
% 		\node (pro1) [process, below of=game] {Process 1};
% 		\node (dec1) [decision, below of=pro1, yshift=-0.5cm] {Decision 1};
		
% 		\node (pro2a) [process, below of=dec1, yshift=-0.5cm] {Process 2a
% 			text text text text
% 			text text text 
% 			text text text};
		
% 		\node (pro2b) [process, right of=dec1, xshift=2cm] {Process 2b};
% 		\node (out1) [io, below of=pro2a] {Output};
% 		\node (stop) [startstop, below of=out1] {Stop};
		
% 		\draw [arrow] (start) -- (game);
% 		\draw [arrow] (game) -- (pro1);
% 		\draw [arrow] (pro1) -- (dec1);
% 		\draw [arrow] (dec1) -- node[anchor=east] {yes} (pro2a);
% 		\draw [arrow] (dec1) -- node[anchor=south] {no} (pro2b);
% 		\draw [arrow] (pro2b) |- (pro1);
% 		\draw [arrow] (pro2a) -- (out1);
% 		\draw [arrow] (out1) -- (stop);
		
% 	\end{tikzpicture}
% 		\caption{The proposed workflow}
% \end{figure}

