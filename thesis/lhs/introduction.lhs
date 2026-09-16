\section{Introduction}


\subsection{Game-theoretic modelling as a software problem}

Tackling a complex problem by decomposing it into bite-sized pieces is perhaps the name-of-the-game in software engineering. A software engineer needs to design the correct abstractions for composing, removing, and extending blocks of code that can be conceived in isolation but ultimately brought together for a complete solution to a problem. On top of that, maintaining a code-base can often be a collaborative effort, with ever-changing requirements and unforseen bugs that stretches across different modules. Some solutions to maintaining the efficiency and stability of the code-base typically involve continuous integration, design patterns (i.e. Gang of Four), or perhaps just some human-readable variable names. 

Let's try to generalize the software engineering process as follows: a software engineer observes the problem, hypothesizes a solution and lists assumptions, they prototype an implementation as some program, tests the solution, observes the output of the program to verify assumptions, and adjusts the implementation accordingly, not unlike the process shown in Figure~\ref{figure:Fig. 1}. 

Similarly, the transition from real-world phenomena to a game-theoretic model requires observing the real-world, developing abstractions according to standard game-theoretic concepts, and observe the behaviour of the game under certain conditions. Evaluation metrics include observing the respective payoffs of players under certain conditions, or determining whether a strategy profile is a Nash equilibrium. The task is left to collate these metrics and derive expectations of the players' as rational and utility-maximizing. Indeed \textit{mechanism design} is specifically concerned with sculpting these games to achieve a hypothesized outcome under certain conditions. 

The process of instantiating these games are (expectedly) domain-specific. Building a model too general fails to become useful, and a model too specific. Drawing from \cite{Zahn2024}, compositional game theory has enabled a strong correspondence between game-theoretic models and code. With the proper abstractions for piecing models together, developing a library of economic models that can be easily loaded and run as for simulations is within grasp. Focusing in again on "models as code", we can naturally correspond software engineering principles to game-theoretic modelling principles. The practical implications of compositional game theory were first explored in \cite[section 2.3.12]{HedgesThesis}, developing the first steps to compositionally designing problems. Constructing games for these problems using string diagrams ultimately transitioned to an implementation of the category of games as a Haskell library. Hence, we have a mechanical process that can be used to assist a modeler to understand a problem in terms of compositional game theory. However, there has yet to be a more explicit methodology for effectively using the tool, specifically outside microeconomic analysis. Rather than taking a domain-constrained approach to the tool, this thesis seeks to identify techniques using this DSL as part of a larger software-development process in order to build effective models.



%Something about ACT in general

%The advent of categorical cybernetics in applied category theory, such as categorical systems theory or categorical cybernetics or perhaps more generally a study of composable systems. The interpretation of processes in quantum physics to baking cakes to agent-based modelling for epidemiology research. Using the diagrammatic language provided by symmetric monoidal categories as a formal way of examining these systems.

%A particular development in this area is compositional game theory. While initially conceived for microeconomic analysis and adoption by economists, the expressive power of the language warranted exploration of different game theoretic applications. At the beginning of this study, I was in the unique position of learning game theory and cybersecurity modelling from the bottom-up and had to approach these topics through a lens of compositionality. In reference to the conclusion of \cite{HedgesThesis}, this thesis aims to concretely realize the mechanization of the game theoretic modelling process.  

%The secondary underlying inspiration for this study is a software-engineering approach to game-theoretic modelling.The development of these models can benefit from a collaborative, iterative process reminiscent of software-engineering methodologies. Composing games, as we will see in this thesis, is structural in the sense that a modeller has a language to visualize and derive new games using a common language. While the open games DSL was built expressly for the purpose of having user-defined open interfaces, this thesis pushes further by providing abstractions for model instantiation and payoff schemes that can be interchanged or tested independently. 






\subsection{Why cybersecurity games?}

The development of cybersecurity models are increasingly more important in today's landscape of technological interconnectivity. It's a modeller's responsibility is to accurately reflect dynamic attack and defensive scenarios, from DDoS (Distributed Denial of Service) attacks on smart grid networks, to intrusion detection and response systems in distributed computer networks. Game-theoretic models have been widely accepted as a tool for enhancing the defensive capabilities of a system. By modelling the interaction between an attacker and defender, where the players are rational actors maximizing their utility, a modeller can derive an optimal defensive strategy or predict an attacker strategy. Using these findings, a security administrator can deploy countermeasures preemptively, or evaluate real-time adjustments to a defensive strategy. 

There has been growing interest in developing these game-theoretic models in a variety of security domains, requiring collaborative expertise between game modelling and cybersecurity. Based on the inherent relationships between these models, we propose a methodology to expressively derive these security games from smaller games using compositional game theory. But why study these relationships in the first place? The answer is to towards developing an answer to an auxiliary question: how do we develop the "correct" models? Or more tractably, which models actually improve the performance of security systems? Evaluating a security system means considering system performance, internal impact between subsystems, and different adversary capabilities. Though the game formulation process is grounded by the same game-theoretic concepts across these models, 

So beyond developing a system to just construct security games from smaller ones, the game formulation process should be a \textbf{experiential} and \textbf{collaborative} effort. By modularizing this game formulation process, we can create greater interoperability and rapid model adjustment. Essentially by inverting the process by starting at simple components, we allow for generalization to a security situation through parameterization to \textit{grow} the model, rather than \textit{restrict} a security scenario to fit the confines of the game. 

%For example, consider Figure 2. of a multi-layered security setting from \cite{Jin2018}, strategic interactions are composed graphically as a self-reinforced communication between communicating IDSs and an administrative IDS. 

Repeating the direction provided by \cite{Zhu2024}, \cite{Zhu2025}, \cite{Egan2025}, there is a need to promote cross-collaboration and platforms for better integration of real data. Here we build this platform by giving a wide sandbox to test out new ideas and their impact on a game-theoretic model. 



\begin{figure}
	\begin{center}
		\includegraphics[width=0.5\linewidth]{ModellingProcesspym.png}
		\caption{A general modelling process from \cite{Caulfield2014} \label{figure:Fig. 1}}
		
	\end{center}
\end{figure}

\subsection{On using Haskell} 
This thesis fully embraces the Haskell for designing these cybersecurity games. By the end, we hope the reader will have benefited from an explicit account of using the open game engine in its current form. However, the software abstractions needed to engage in this workflow effectively can obfuscate the purpose of the study, namely to bridge the design and simulation of these game-theoretic models in a declarative way. While this thesis strongly persists in using software methodologies to facilitate this design process, ultimately the DSL portion and Haskell portion of this work coalesce. Nonetheless, as this study progressed, we found that Haskell language features such as using monads or property-based testing were effective for simulation, test data generation, and model parameterization. 

On the other hand, a user should  be able to use the DSL as a sufficient environment for the purposes of visualizing information flow and structuring players while hiding the implementation details needed to instantiate the game. This ends up being a significant learning curve by requiring a user to translate simple real-valued reward functions to a Haskell function, or adding model parameters as part of an abstract data type. But the hope is that by adopting this layer as an intermediate language and taking the time to encode these calculations as Haskell functions, this will enable quick-and-easy compatibility of models. Thus a particular area that this thesis addresses is formalizing a "how-to" for games beyond the syntax for using the open-games DSL. 

\subsection{Formatting and structure of thesis}

This thesis was written in Literate Haskell and compiled using \cite{loeh2012lhs2tex} which provided the pretty typesetting for the Haskell code snippets and even allowed in-lining code. We follow a paragraph-style of writing, but intersperse some of the ideas with written code examples, which are boxed for readability. Some frequently-used Haskell datatypes that exist outside these boxes will be in-line and coloured, like |myDataType|. References to Haskell files that are implemented as part of the companion codebase to this thesis are in bold, such as \textbf{IDSModel.hs}

The structure of the thesis is as follows:

\begin{itemize}
	\item Chapter \ref{sec:prelims} briefly outlines some source material and motivation to assist readers for the remainder of the thesis 
	\item Chapter \ref{sec:opengames} analyzes the open-games-engine, gives use-case examples, and details the relevant theory
	\item Chapter \ref{sec:designPatterns} proposes novel design patterns and a overarching workflow to generate models 
	\item Chapter \ref{sec:multiagent} is the culmination of a 4-month internship at Telecom Paris, during which we developed a middleware to iteratively improving cybersecurity models through model-checking
\end{itemize}
