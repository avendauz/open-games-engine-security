\section{Working with open games}
\label{sec:opengames}
\subsection{Introduction}
We'll begin by recounting the construction of open games up to its current implementation. The goal of this section is to present the definitions that are used, and then to explain 
how to read the corresponding implementation, especially the various types and frequently-used functions. The hope is 
that this builds an intuition for modellers to be able to understand the bare minimimum for constructing 
models and effectively using the type system. 

\subsection{Concrete lenses and open games}
Open games that are used in this thesis first relies on machinery that enables the flow of "forwards" and "backwards" 
information flow. This is encoded using the language of 
\textit{lenses}. Historically, open games were constructed without any connection to 
lenses, but was most recently used for defining Bayesian games in \cite{BayesianOpenGames} using a more general 
definition which broadly encompasses
the more familiar term, \textit{lenses}. 

Lenses have been used in database theory, defining certain 
\textit{lens laws} associated with data accessors. These properties dictate the behaviour 
of a \textit{get} and \textit{put} operations (or colloquially, \textit{view} and \textit{update} operations).
High-level, \textit{get} allows you to view the contents of a substructure, and 
\textit{put} allows you to make updates to a substructure, and the lawfullness of these operations ensure that 
updates to the substrucuture are reflected accordingly in the larger structure. Thus a lens (given by $lens: S \rightarrowtail A$) is a pair of operations typed as $get: S \rightarrow A$
and $put: S \times A \rightarrow S$, where $A$ is the substructure of $S$. But we can relax the requirement of "substructure"
and generalize \textit{get} and \textit{put} to the definition of concrete lenses:

\begin{definition}(Concrete lenses from \cite[Definition 2.2.1]{BayesianOpenGames}) Let $S$, $T$, $A$, $B$ be objects of 
the category $\Set$. A \textit{concrete lens} l: $(S,T) \rightarrowtail (A,B)$ is a pair of functions 
$u: S \rightarrow A$ and $v: S \times T \rightarrow B$
\end{definition}


To see what this would look like in Haskell, we can treat $u$ and $v$ as the two parameters for instantiating 
a datatype


\begin{minipage}\textwidth
\begin{code}
data Lens s t a b where 
   Lens :: (s -> a) -> (s -> b -> t) -> Lens s t a b
\end{code}
\end{minipage}


One of the important features of these lenses is that they compose sequentially and in parallel,
or in other words, act as morphisms of a symmetric monoidal category where objects are pairs of sets. 
We term sequential composition as morphism composition and parallel composition as the tensor product of the 
symmetric monoidal category. Note that 
$S$ and $A$ are the types for domain and codomain of the
covariant morphisms and $R$ and $B$ are the domain and codomain for contravariant morphisms of these lenses.

To hint at where we are headed towards describing open games as \textit{processes that care about their environment}, intuitively
such a morphism would describe the behaviour of an agent given a certain strategy when operating 
in a given environment, where: 
\begin{itemize} \label{note:hint}
   \item Makes observations of type $S$
   \item Takes actions of type $A$
   \item Recieves some feedback from its local environment of type $T$
   \item Relays information back to the environment of type $B$
\end{itemize}
Thus given (1) a strategy $S \rightarrow A$, (2) an observation of type $S$, and (3) some continuation or feedback 
providing some payoff of type $B$, we will be able to describe what this strategic agent would do to maximize its expected payoff.

Considering the behaviour of agents using these lenses is enough to start constructing a category 
of open games that can model normal-form games \footnote{(see \cite{HedgesThesis,hedges2017morphismsopengames,BayesianOpenGames} to see how 
this is done and the construction of the category of open games)}. We'll only mention that this category of \textit{concrete open games}
exists, and choose to focus on the successor which is not limited to a deterministic setting. 
For security games or modelling realistic security scenarios, most current models use
mixed strategies, Bayesian games, or incomplete information games.

\subsection{Coend lenses and probability}
To accommodate the need for modelling games in a probabilistic setting, we would need a more generalized notion of lenses (and then a more general category of open games), where we can do things like take actions $A$ 
over some probability distribution, or give agents the ability to have some probabilistic belief about their type (as in classic Bayesian games). This turns out not to be as simple as attaching a probability monad 
to the current definition of lenses, specifically because the tensor product of the category of open games fails to be associative. 
\footcite[Section 3.4]{BayesianOpenGames}
Instead, the authors of 
\cite{3} use \textit{coend lenses} (or \textit{optics}). 

We recall the definition from \cite[Definition 2.0.1]{riley2018categories}

\begin{definition}[Coend lens] \label{Definition:Coends}
   Given a symmetric monoidal category $\C$ equipped with tensor product $\otimes$, and with pairs of
   objects $(S,T)$ and $(A,B)$, a \textit{coend lens} 
   $l: (S, T) \rightarrowtail (A, B)$ is an element of the set $\int^{\Theta:\C} \C(S, \Theta \otimes A) \times \C(\Theta \otimes R, T)$
\end{definition}

Treating $\C$ as $\mathbf{Set}$ produces the definition of the concrete lenses introduced in the previous section. 
Explicitly, we can treat this set as the pairs of functions $u: S \rightarrow \Theta \otimes A$ and $v: \Theta \otimes B \rightarrow T$
quotiented by the equivalence relations given by $((f \otimes A)u, v) ~ (u, v(f \otimes B))$ for any 
$f: \Theta \rightarrow \Gamma$, $u: S \rightarrow \Theta \otimes A$ and $v: \Gamma \otimes B \rightarrow T$. 

Effectful lenses have been studied in \cite{xie2025effectful,abou2016reflections}, but \cite[Section 4.9]{riley2018categories} implements some desired effectul properties as "effectful 
optics" using the coends as defined here with the appropriate monad (i.e. Writer, State). Since the specific application we 
are interested in for game theoretic modelling is the ability to describe, for example, \textit{behavioural strategies}
and moves of Nature, we use the finite distribution probability monad. 

Based on the intuition we've introduced in the previous section, a \textit{behavioural strategy} would 
then have to be represented by a function of type $S \rightarrow \Prob(A)$ where $\Prob(A)$ is the finitary probability distribution
monad over the actions $A$. This monad is an important type constructor 
used in the \textit{open-game-engine} for wrapping user-defined types, specifically 
the constructor |type Stochastic :: T Double|, where |T| is the probability monad 
given by the module |Numeric.Probability.Distribution|.  

\begin{mdframed}
\begin{example}[Deterministic functions]\label{examples:playDeterministically}
The \textit{open-game-engine} provides a helper function |playDeterministically :: a -> Stochastic a| to wrap any type to an observation that will be observed with probability 1. 

\begin{code}
definitelyHoneypot = playDeterministically Honeypot 
\end{code}
\end{example}
\end{mdframed}


A way of deriving a function $S \rightarrow \Prob(A)$ from $S \rightarrow A$ is 
to consider the Kleisli category of the finite distribution monad $\Prob$. 
Working in the Kleisli category is handy for composing these morphisms without having 
to open up the monad, but the most common use for our purposes is writing Kleisli arrows of the distribution monad
to write behavioural strategies for our models. Generally speaking, these will follow the format:
\begin{code}
someBehaviouralStrategy :: Kleisli Stochastic s a
\end{code}

In the classic game-theoretic sense, this strategy assigns some probabilistic action of type |a| for every observed type |s|. 

\begin{mdframed}
\begin{example}[Honeypot allocation randomization]
Say we want to describe a defensive strategy that deploys a high interaction honeypot 75\% of the time, a low-interaction honeypot 25\% of the time, and doesn't activate a honeypot 10\% of the time. We can use the helper function |distFromList| and a data type storing each kind of honeypot as our set of actions. Assuming we deploy this defensive strategy statically, without any observations, we use the type |()| to describe no input.

\begin{code}
defensiveStrategy :: Kleisli Stochastic () Honeypot
defensiveStrategy = Kleisli $ const $
      distFromList 
         [(HighInteraction, 0.75), 
         (LowInteraction, 0.20),
         (Normal, 0.05)]
\end{code}

\end{example}
\end{mdframed}


Using this Kleisli category over the finite distribution monad as the category of interest in Definition \ref{Definition:Coends}, we have a way of keeping track of 
joint probability distributions between \textit{unobservables} and directly observed inputs. 
Using $\Theta$ as a type variable to 
store priors as information to be used later, we can directly express Bayesian updating for agents. \footnote{See \href{Bruno Gavaranovic's blog post}{https://www.brunogavranovic.com/posts/2022-02-10-optics-vs-lenses-operationally.html} for an explanation for how composition works with a nice graphical simulation of how this "internal state" works} 

For the purposes of the \textit{open-game-engine}, the implementation that is used of coend lenses ties this definition together 
as a data type:

\begin{minipage}\textwidth
\begin{code}
   data StochasticOptic s t a b where
      StochasticOptic ::  (s -> Stochastic (z, a))
                           -> (z -> b -> Stochastic t)
                           -> StochasticOptic s t a b
\end{code}
\end{minipage}


Note the implicit quantification |forall z| as part of this data type, which was explicitly given as $\Theta$ in Definition \ref{Definition:Coends}. We retain the value of |z|, the "residual" to be used in computing the backwards pass, which is given as the second argument given to this data constructor. 

\begin{mdframed}
\begin{example}[Forward probabilistic function]\label{example:forward}
We can describe a class of stochastic optics |StochasticOptic s () a ()| which performs a probabilistic computation and disregards any contravariantly flowing information. So we can lift any morphism \mbox{$f: S \rightarrow \Prob(A)$} of $\KlD$ to an optic using the following Haskell function: 
\begin{code}

liftStochastic :: (s -> Stochastic a) -> StochasticOptic s () a () 
liftStochastic f = 
   StochasticOptic 
      ( \x -> do {y <- f x; return ((), y)} )
      (\() () -> return ())
\end{code}
Which ignores any residual, computes morphism $f$, and returns the output. 

\end{example}
\end{mdframed}

Furthermore, $\KlD$ is a symmetric monoidal category and can be used as the underlying category 
of a coend lens in \ref{Definition:Coends}. By \cite[Proposition 2.0.3]{riley2018categories}, there is a symmetric monoidal category 
of coend lenses $\mathbf{Optic}_{\KlD}$ where objects are pairs of sets, and morphisms are coend lenses. Composition and the tensor product is described by the |Optic| typeclass:

\begin{code}
class Optic o where
  lens :: (s -> a) -> (s -> b -> t) -> o s t a b
  (>>>>) :: o s t a b -> o a b p q -> o s t p q
  (&&&&) :: o s1 t1 a1 b1 -> o s2 t2 a2 b2 -> o (s1, s2) (t1, t2) (a1, a2) (b1, b2)
\end{code}

which we can parameterize with the datatype |StochasticOptic| to get our desired operations for "stochastic optics," located in |OpenGames.Engine.OpticClass|. Optic sequential and parallel composition will form the basis of how agent's game-theoretic behaviour compose, with extra details about how to interpret their local contexts given in the next section. We'll also use this opportunity to show how these optics plug together using the type parameters. First, note the type of |(>>>>)| enforces that the output type |a| and the contravariant input type |b| of the first optic correspond to the input type and the contravariant output type of the second optic. Similarly, the type of |(&&&&)| enforces that each of the input and output types are tupled together. Most IDEs will give a pop-up corresponding to the \textbf{ghc} typechecker to help a user line these types up when usingthese operations, or a direct error message will be given when trying to compile in \textbf{ghci}.  


\subsection{Open games}
Now that we've set our formalization for stochastic optics, we can introduce the  interpretation for these morphisms of $\mathbf{Optic}_{\KlD}$, which describes an \textit{open play} according to a supplied strategy. This open play along with a best-response relation over the possible strategies will be the components of an open game. We'll start with the formal definition of general open games from \cite[Definition 3.6.1]{BayesianOpenGames} and then demonstrate each of its components. 

\begin{definition}[Open game]
   An open game is comprised of the following data, with $(S,T)$ and $(A,B)$ objects of $\StochOpt((S,T), (A,B))$: 
   \begin{enumerate}
      \item A set of strategies $\Sigma$
      \item A \textit{play function} $P: \Sigma \rightarrow \StochOpt((S,T), (A,B))$
      \item A \textit{best-response function} $B: \Sigma \rightarrow \mathbb{C}((S,T), (A,B)) \rightarrow \mathcal{P}(\Sigma)$
   \end{enumerate}
\end{definition}

Given a strategy from the set of strategies from (1) that assigns an outcome of type |Stochastic a| representing probability distribution over actions for each observation of type |s|, we generate a stochastic optic that is "preloaded" with the behaviour of this strategy. This optic |StochasticOptic s t a b| is open in the sense that it's ready to respond by choosing an action according to its local \textit{context} \footnote{see the following section, \ref{sec:contexts}}. So we can describe a family of optics indexed by behavioural strategies using the Haskell function:
\begin{code}
play: Kleisli Stochastic s a -> StochasticOptic s () a Double
play strategy = StochasticOptic 
      ( \s -> do {y <- runKleisli strategy s; return ((), a)} )
      (\() _ -> return ())
\end{code}


This construction doesn't necessitate a strategic play, and can be used to model computations (processes with no preferences, as seen in \hyperref[example:forward]{Example 4}). This implementation follows from the play function given for \textit{Bayesian agent} in \cite[Definition 4.4.1]{BayesianOpenGames}, which makes an observation, computes an action according to the given strategy, and throws away any real-valued payoff propagated back to it. 

The final component in the definition of the open games is the best-response function, or the best-response relation. This is where the utility-maximization characterization of open games is encoded. Similarly defined according to the concept of best-response functions in classical game theory, the best-response function gives a strategy that a player would be incentivezed to follow given that every other player follows another strategy. Given a best-response function, a solution concept such as Nash equilibrium would be fixpoints of this function. 



With the following data type, we've reached the highest level for which modellers would be interacting with the open-game-engine when simulating and evaluating their models:  

\begin{minipage}\textwidth
   \begin{code}
   data OpenGame StochasticOptic StochasticContext x y s t a b = OpenGame {
      play :: List x -> o s t a b,
      evaluate :: List x -> c x s y r -> List y
   }
   \end{code}
\end{minipage}

\begin{mdframed}

\begin{example}[Nature open game]\label{example:nature}
The open-game-engine provides an operator |nature| for instantiating an open game according to a user-defined random draw. Nature corresponds to the terminology used in classical extensive-form Bayesian games, where the first node of the tree is the Nature player providing a type. 

In security games, a defender monitoring traffic cannot identify whether a user is adversarial or a normal consumer. Designing a game would involve fixing a common prior to represent the proportion of users that could be adversarial or not, and have Nature assign the types privately to the first-mover, in this case the user. A 75\% chance of encountering an adversary can be encoded as an open game as follows: 

\begin{code}

data UserType = Normal | Adversary deriving (Eq, Ord, Show)

natureUser = 
   nature $ 
      distFromList [(Adversary, threatPrior), (Normal, 1 - threatPrior)]
      where threatPrior = 0.75

\end{code}
   
\end{example}
\end{mdframed}

\subsection{The context aside}\label{sec:contexts}

So far we alluded to the idea of \textit{context} in open games. Contexts have taken many different forms in the literature, from more bare-bones necessitation of a \textit{history/cohistory} and \textit{continuation} pair, to more formally using a \textit{context functor} to define contexts as elements of $\mathbb{C}((S,T),(A,B))$. 


% Ideally, a modeller would only need to procedurally type games starting with |OpenGame StochasticOptic StochasticContext ... | and use |void| to , but this works against separation-of-concerns, when in fact the 

% Contexts form the arena for modellers to eventually parameterize and "run" the . Having the categorical definition for open games allows for a well-defined (and well-typed) context, and much of the work of the modeller goes into designing this context to understand how a game behaves given certain constraints. 

The name of the (open) game is to describe rational agents interacting with some environment. Thinking about Nash equilibrium in classical game theory, in equilibrium players are not incentivized to change their action assuming they know the other players' strategy. In the field of view of players, we act according to how we expect other players to act. Essentially we have a characterization of describing this pre/post behaviour of other players, which becomes part of the player's field of vision, or \textit{local context}. 

In the string-diagrammatic calculus of open games, a context is given by two components of a coend diagram, with (1) a triangle on the far-left side of the diagram and (2) a triangle on the far-right side of the diagram that essentially "close" our games. The graphical calculus gives an intuitive "hole" that describes this player's position, and the rest of the boxes to form the local context for that player.

In practice for the open-game-engine, the  characterization of contexts is the datatype: 

\begin{code}
data StochasticContext s t a b where
  StochasticContext :: Stochastic (z, s) -> (z -> a -> Stochastic b) 
      -> StochasticContext s t a b
\end{code}

which represents the aforementioned history/cohistory and continuation pair of functions to close an open game. The first parameter for the data constructor represents the initial state to input into a game representing the computations conducted before the open game, and the second parameter describes how to transform outputs of a game into a real-valued payoff or any feedback information from other games as part of that context. 



\begin{mdframed}
\begin{example}[A simple maximization problem with uncertainty]\label{example:context}
Consider the one-shot case adapted from \cite{la2016deceptive}, where a defender is responsible for ensuring the security of an IoT network using a honeypot deployment system. This defender is uncertain about the type of users attempting to access certain servers. Based on historical trends from access records and previous attacks, assume a prior probability of encountering an active attacker as 0.5, where an active attacker is attempting real-time exploits rather than passively collecting information and drawing less attention. In this game model, assuming the defender as the only strategic agent, must maximize his expected reward over the possible types of users he'll encounter. The defender can either For a worked-out example of the same structure, a biased coin, see \cite[Example 4.5.1]{BayesianOpenGames}. We'll consider a direct correlation between the prior and the actual behaviour of the attacker. Here, we can represent this with the following code: 

\begin{code}

\end{code}
\end{example}
\end{mdframed}




\subsection{The category of open games and operations}

By \cite[Theorem 3.10.2]{BayesianOpenGames}, a category of Bayesian open games exists where objects are pairs 
of objects in the Kleisli category of the distribution monad $\mathbf{Kl}(\textbf{D})$ and morphisms are equivalence classes of open games. So modellers will have access to operations that govern sequential and parallel composition of open games as |(>>>)| and |(&&&)| respectively. The same thought-process for piping together these games applies when piping together optics as described in a previous section. 


By precomposing a game that makes an observation with a copy operation (\cite[Definition 4.4.3]{BayesianOpenGames}), we give the rest of the model access to this observation. Now we can use the previous sections and build more explicitly on the ideas alluded to in Section \ref{note:hint}.
Without the DSL, we can write Haskell functions for the \textit{copy} and \textit{delete} operations to write a formula for completing \hyperref[example:nature]{Example 5} game as follows: 

\begin{code}
userGame:: OpenGame
  StochasticOptic
  StochasticContext
  `[Kleisli Stochastic Signal VisitorMove]
  `[[DiagnosticInfoBayesian Signal VisitorMove]]
  (Signal, Signal)
  ()
  (Signal, VisitorMove)
  ((), Double)
userGame = 
   natureUser >>> copyGame >>> 
   (deleteGame >>> (idGame &&& dependentDecision "Bob" [Normal,Adversary]))
\end{code}
Note that the tensor product of open games concatenates the resultant types into tuples. This eventually means in order to close a game using a tensor produce, we could be working with games that involve types like |((),())| which becomes unwieldy to work with, so we would have to precompose with |deleteGame| which flattens these tuples in the contravariant direction. Otherwise, we can read this expression as a guessing game (like a matching pennies game) where Bob needs to decide if it's encountering an adversary or or a normal user.

Reading this equationally is not as clear to give an interpretation, with deleting operations that do not provide any useful insight to the high-level flow of the problem. The next layer to enhance the understandability of this formula is through the DSL, which allows direct wiring of each of these games as code blocks.

The most important function for modellers to use that bakes in Bayesian updating and maximization of the expected payoff after updating their belief is the |dependentDecision| function which implements the selection function given in \cite[Definition 4.4.1]{BayesianOpenGames} for Bayesian agents. 




The intuition (as described in \cite[Section 2.1.1]{HedgesThesis}) is to begin thinking 
of an open game as a process, open to and interacting with its local environment through its inputs 
and outputs. A commonly-used representation of an open game is as a box (representing the process or morphism)
with two incoming and two outgoing wires (representing objects of the category).

\begin{figure}[h]
	\centering
	\includegraphics[width=0.5\linewidth]{images/GameSimple.png}
	\caption{A string diagram of an open game \label{figure:Fig. 10}}
	
\end{figure}


this $\Theta$ may be some prior distribution representing an agent's belief of their type. Given a prior joint distribution $\Prob(\Theta \times S)$ where $\Theta$ is the unobservables and $S$ is the observable states, the agent can update this prior to a posterior and maximize their expected utility. 


Starting to think of each of these open games as programs, an open game has four types associated with it. 
Here variables $X, Y$ are flowing covariantly (intuitively, flowing forwards) and $S, R$ are flowing contravariantly (which represent the feedback of information). Specifically: 
\begin{itemize}
	\item $X$ is the set of inputs that the open game can observe 
	\item $Y$ is the set of actions that the open game can take, or \textit{outcomes}
	\item $S$ is the set of \textit{co-outcomes} with the purpose of propagating information to precomposed games. 
	\item $R$ is the set of \textit{outcomes}
\end{itemize}

Note that there is no sense of agency attached to open games right off the bat. We have flexibility to define the behaviour of the open system according to our needs, whether as 
a representation of a utility-maximizing agent, or simply a function.  

The type of $\Sigma$, like a pure strategy profile in normal-form games, can be selecting an action from the set of actions. 
For sequential games, a strategy would typically involve choosing an action in response to each possible observed action played previously, 
thus such a strategy would be a function of type $X \rightarrow Y$. For the relevant functions that take these strategies as input, such as |evaluate|, these are types as |List x| i.e. a list of strategies. We have to supply a list of the same length as the number of |dependentDecision| operators present in an open game, or in other words a strategy for each utility-maximizing player. To construct this list, we use the |(::-)| operator, like: 

\begin{code}
stratp1 = playDeterministically Confess  
stratp2 = playDeterministically Silent 

prisonersDilemmaStrategy = stratp1 ::- stratp2 ::- Nil 
\end{code}

Note this list must also be ordered corresponding to the top-down or left-right sequencing of an open game, though the compiler will respond accordingly for any type mismatching.

\subsection{Reading the DSL}
Rather than constructing games using the aforementioned functions, we can use a DSL that compiles to Haskell. In this section, we'll explain the DSL syntax. We will use the following example of the prisoner's dilemma game.
\begin{mdframed}
\begin{example}[Prisoner's Dilemma in the DSL]\label{example:prisoner}
The following example is an open game representation of the well-known Prisoner's Dilemma. For simultaneous play, we would consider the tensor of two utility-maximizing agents each represented by an open game generated by the |dependentDecision| function. In the DSl, we can stack code blocks representing these agents, and pipe their fields together accordingly. The input fields remain blank because neither player makes any observations prior to making their move. Two variables are declared in the outputs fields, |decisionPlayer1| and |decisionPlayer2|, which makes these values accessible to other games. Although the player2 open game is below player1, the Haskell expression in the returns fields have access to both variables |decisionPlayer1| and |decisionPlayer2| to calculate the payoff that each agent recieves. 
\begin{code}
myOpenGame exoVar1 exoVar2 exoVar3 ... = [opengame|
   inputs    :      ;
   feedback  :      ;

   :----------------------------:
   inputs    :      ;
   feedback  :      ;
   operation : dependentDecision "player1" (const [Cooperate,Defect]);
   outputs   : decisionPlayer1 ;
   returns   : prisonersDilemmaMatrix decisionPlayer1 decisionPlayer2 ;

   inputs    :      ;
   feedback  :      ;
   operation : dependentDecision "player2" (const [Cooperate,Defect]);
   outputs   : decisionPlayer2 ;
   returns   : prisonersDilemmaMatrix decisionPlayer2 decisionPlayer1 ;

   :----------------------------:

   outputs   :      ;
   returns   :      ;

 |]

\end{code}
   \end{example}
\end{mdframed}


Here, |[opengame|...|]| is TemplateHaskell's quotation syntax, which returns the |OpenGame| data type. The syntax is divided into two sections, (1) the external components and (2) the internals of the open game. The external components are comprised of the two fields |inputs| and |feedback| above the delimiter |:----:|, and |outputs| and |returns| at the bottom. As introduced before in the formal definition of open games, these fields correspond to the pairs of objects corresponding to the type of the open game, with |inputs| and |feedback| as the pair $(S,T)$ amd |outputs| and |returns| as $(A, B)$. These fields designate the variables available for use, and the values produced by the internals of the game. Note that user-declared variables are in scope for the internals of the game and correspond with the |inputs| and |returns| fields. On the other hand, the remaining two fields designate the values that will be generated by the internals of the game to be passed to other games. As in the above example, the variables declared in the outputs field can be used in any of the inputs or returns fields.


We treat any parameters such as |exoVar| as exogenous parameters introduced outside the game. This ends up being an appropriate place to pipeline the infrastructure required to characterize payoff functions, parameterize strategies, and other techniques in order to keep the DSL syntax generic. See Chapter \ref{sec:designPatterns} for the infrastructure and coding patterns used to best utilize this concept.  

Threading these variables together through these fields is up to the discretion of the modeller. An open game can completely change with the smallest additions, for example putting |decisionPlayer1| into the inputs field of the |player2| code block. In this representation, |player1| moves first and |player2| will be able to observe the output. The compiler will be responsible for making sure the types line up accordingly, but matching the modeller's intention to what's being written as an open game is the modeller's responsibility.

There is some assistance from the type-checker, however, to make sure that dependencies are consistent when making changes like this. By exposing the first player's decision to the second, the model execution code should fail to compile because now the strategy of player 2 is dependent on this variable. The type-checker will follow a top-down ordering when typing, so when supplying a list of strategies to run this game, this should be a list ordered left-to-right lining up with the code blocks. We can read this from the type signature for each game, where the |`[]| constructor in the type parameters exactly corresponds with the strategies the game is expecting for each of the code blocks. We can also see that the final four parameters are |()|, which designates a closed game. 
\begin{minipage}\textwidth
\begin{code}
myOpenGame :: OpenGame
  StochasticOptic
  StochasticContext
  `[Kleisli Stochastic () PrisonerMove, 
   Kleisli Stochastic () PrisonerMove]
  `[[DiagnosticInfoBayesian () PrisonerMove], 
   [DiagnosticInfoBayesian () PrisonerMove]]
  ()
  ()
  ()
  ()
\end{code}
   
\end{minipage}


\subsection{Evaluation and reading analytics}
As mentioned previously, Nash equilibrium corresponds to fixpoints of the best-response function of games. Correspondingly in the typical engine output, modellers can read an optimal move and the strategic move and the corresponding expected payoffs for a certain strategy.

Specifying a context for a game to do this evaluation can happen in two ways: (1) specifying the initial history and continuation within in the DSL as embedded Haskell functions, (2) specifying the initial history and continuation payoffs when calling the |evaluate| function. To get a human-readable output In the case of (1), a game with a closed type can then be viewed with the following function: 

\begin{code}
  
runDiagnostics = generateOutput $ evaluate myClosedGame myStrategy void
\end{code}
where |void| is an identity context. 

It's possible to write wrappers in order to codify information into a CSV file with a simple parser, but we leave this for future work to expand the methodology pipeline to ingest real-time data. Thus we consider the open game engine solely as an equilibrium checker in this workflow, though extracting payoffs for repeated game analysis is certainly possible. 

For equilibrium-checking use-cases, |generateIsEq| goes over the diagnostic information and returns True if the strategy profile is optimal, and False along with the conditions for which the payoff is not optimal. This in particular would be the main entry point to conduct rational verification. 

% In a more simulation-focused case of determining the payoff for a particular action, we can "pre-load" the behaviour of an agent by calling |loadedAgent :: StochasticOptic s t a b = play agent1 strategy|, then 

However, outside a classical sense, we can construct \textit{Bayesian sequential games} from \cite[Example 7.7.1.4]{BoltThesis}. Using the diagnostic information, we will have to analyze the payoff for each "alternative world" that our system is simulated in, which can be read from the \textit{Unobservable state} field given in the output. This line manifests as a tuple for every possible state in the support over the distribution of inputs into a given game. This corresponds to "on-equilibrium" paths in the classical sense, where the second-mover must compute their expected payoff for each potential outcome that the first-mover dictates according to their strategy. Notably, this would \textbf{not} correspond to maximizing over all possible subgames. For example, in Figure \ref{figure:simpleDiagnostic}, since the guesser is maximizing over the possible outcomes of two coin flips, each of the four sub-outputs has in the \textit{Unobservable state} field one of four possible ways the coins can be flipped. Note that the resultant payoff in each of these scenarios according to the supplied strategy |guesserStrategy| is equal to the optimal payoff, which would designate this strategy profile as equilibrium.  

\begin{figure}[t]
   \centering
   \includegraphics[width=\textwidth, height=0.22\textheight, keepaspectratio]{SimpleDiagnostic.png}
   \caption{Diagnostic output when running the \textbf{BiasedCoin.hs} game in ghc} 
   \label{figure:simpleDiagnostic}
\end{figure}

% To see this, consider the following counterexample in the classic beer-quiche game of imperfect information, where the engine claims 



% First, 


