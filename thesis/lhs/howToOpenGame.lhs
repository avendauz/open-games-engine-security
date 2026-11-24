\section{Working with open games}
\label{sec:opengames}
\subsection{Introduction}
A weaker element of the previous chapter is the reusability of the CyberBattleSim models. As soon as a CyberBattleSim model is created, there is no direct relationship or data retention between past and future iterations given our methodology. Tools like \cite{EGTAOnline} are able to accomplish this, but more generally speaking, the experiments generated from that methodology remain disjoint and bounded to specific cybersecurity games, despite repetitive game structures and analyses. 

However, among the class of cybersecurity models based on game theory, developments in compositional game theory could enable greater reusability and model analysis techniques. We'll begin by recounting the construction of open games up to its current implementation. The goal of this section is to present the definitions that are used, and then to explain 
how to read the corresponding implementation, especially the various types and frequently-used functions. The hope is 
that this builds an intuition for modellers to be able to understand the bare minimimum for constructing 
models and effectively using the type system. This section could be read as documentation for the engine, in the sense that a synthesis of the theory that has been implemented in the engine. We progressively make our way through simple open games, which loosely characterize non-stochastic normal form games. Then, we recall the use of coend calculus to capture Bayesian games.

\subsection{Concrete lenses and open games}
Open games that are used in this thesis first relies on machinery that enables the flow of "forwards" and "backwards" 
information flow. This is encoded using the language of 
\textit{lenses}. Historically, open games were constructed without any connection to 
lenses, but was most recently used for defining Bayesian games in \cite{BayesianOpenGames}. 

Lenses have been used in database theory, defining certain 
\textit{lens laws} associated with data accessors. These properties dictate the behaviour 
of a \textit{get} and \textit{put} operations (or colloquially, \textit{view} and \textit{update} operations).
High-level, \textit{get} allows you to view the contents of a substructure, and 
\textit{put} allows you to make updates to a substructure, and the lawfullness of these operations ensure that 
updates to the substructure are reflected accordingly in the larger structure. Thus a lens (given by $lens: S \rightarrowtail A$) is a pair of operations typed as $get: S \rightarrow A$
and $put: S \times A \rightarrow S$, where $A$ is the substructure of $S$. But we can relax the requirement of "substructure"
and generalize \textit{get} and \textit{put} to the definition of concrete lenses:

\begin{definition}(Concrete lenses from \cite[Definition 2.2.1]{BayesianOpenGames}) Let $S$, $T$, $A$, $B$ be objects of 
the category $\Set$. A \textit{concrete lens} l: $(S,T) \rightarrowtail (A,B)$ is a pair of functions 
$u: S \rightarrow A$ and $v: S \times B \rightarrow T$
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
covariant morphisms and $T$ and $B$ are the domain and codomain for contravariant morphisms of these lenses.

To hint at where we are headed towards describing open games as \textit{processes that care about their environment}, intuitively
such a morphism would describe the behaviour of an agent given a certain strategy when operating 
in a given environment, where: 
\begin{itemize} \label{note:hint}
   \item Makes observations of type $S$
   \item Takes actions of type $A$
   \item Recieves some feedback from its local environment of type $B$
   \item Relays information back to the environment of type $T$
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
Explicitly, we can treat this set as the pairs of functions $u: S \rightarrow \Theta \otimes A$ and $v: \Theta \otimes B \rightarrow T$ quotiented by the equivalence relations given by $((f \otimes A)u, v) \sim (u, v(f \otimes B))$ for any 
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
Say we want to describe a defensive strategy that deploys a high interaction honeypot 75\% of the time, a low-interaction honeypot 25\% of the time, and doesn't activate a honeypot 5\% of the time. We can use the helper function |distFromList| and a data type storing each kind of honeypot as our set of actions. Assuming we deploy this defensive strategy statically, without any observations, we use the type |()| to describe no input.

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

\begin{definition}[Open game]\label{Definition:OpenGame}
   An open game is comprised of the following data, with $(S,T)$ and $(A,B)$ objects of $\StochOpt$: 
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
      play :: List x -> StochasticOptic s t a b,
      evaluate :: List x -> StochasticContext s t a b -> List y
   }
   \end{code}
\end{minipage}

At this level, we can operate on a well-constructed game through the |play| and |evaluate| functions. For |play|, users supply a strategy profile in $x \in \Sigma$, or a list of behavioural strategies as previously defined, ordered in top-down sequential order of the players written in the code block. Thus, a valid strategy profile to supply to |play| for a two-player simultaneous game like Prisoner's Dilemma would be written as |behaveStrat1 ::- behaveStrat2 ::- Nil|, and the expected type would look like |[Kleisli Stochastic s a, Kleisli Stochastic s, a]| For |evaluate|, since we are computing the strategies that are a best-response to the supplied strategy profile, we expect a subset $y \in \mathcal{P}(\Sigma)$ corresponding to these best-response strategy profiles. To ease the use for the modeller, rather than directly outputting these strategies, the engine computes the payoffs according to each of these strategies, . In Section \ref{sec:eval}, we will see how to read this diagnostic information that corresponds to this output and delve into the type of |y|. 

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

To summarize, we've provided data types that formally define stochastic open games, built on-top of an implementation of the category of stochastic optics. However, the point of compositional game theory is the ability to compose open games. While the tensor and sequential composition have been made clear in |class Optic|, how would these operators work for |data OpenGame|? 

First, we need to show how this composition works along |play| and along |evaluate|. Since supplying a strategy to |play| results in an optic, it is clear that composing along the play function is simply optic composition. But how does best-response behave under composition? To do this, we will examine the concept of |StochasticContext|.



\subsection{The context aside}\label{sec:contexts}

Contexts have taken many different forms in the literature, from more bare-bones necessitation of a \textit{history/cohistory} and \textit{continuation} pair, to more formally using a \textit{context functor} to define contexts as elements of $\mathbb{C}((S,T),(A,B))$. Though the double lens categorical structure of $\mathbb{C}$ is useful for diagrammatic proofs \footnote{The string diagrammatic representation of contexts can be seen as a "hole" that describes this player's position, and the rest of the boxes to form the local context for that player.}
 and showing coherence, we can primarily focus on instantiating a context for evaluating a model.



% Ideally, a modeller would only need to procedurally type games starting with |OpenGame StochasticOptic StochasticContext ... | and use |void| to , but this works against separation-of-concerns, when in fact the 

% Contexts form the arena for modellers to eventually parameterize and "run" the . Having the categorical definition for open games allows for a well-defined (and well-typed) context, and much of the work of the modeller goes into designing this context to understand how a game behaves given certain constraints. 

The name of the (open) game is to describe rational agents interacting with some environment. Thinking about Nash equilibrium in classical game theory, in equilibrium players are not incentivized to change their action assuming they know the other players' strategy. In the field of view of players, we act according to how we expect other players to act. Essentially we have a characterization of describing this pre/post behaviour of other players, which becomes part of the player's field of vision, or \textit{local context}. The formation of this \textit{local context} is a vital mechanism for computing best-response for each agent in a game, but internal and not necessarily important for game simulation.


In practice for the open-game-engine, the characterization of contexts is the datatype: 

\begin{code}
data StochasticContext s t a b where
  StochasticContext :: Stochastic (z, s) -> (z -> a -> Stochastic b) 
      -> StochasticContext s t a b
\end{code}

which represents the aforementioned history/cohistory and continuation pair of functions to close an open game. The first parameter for the data constructor represents the initial state of type |s| to input into a game representing the computations conducted before the open game, and the second parameter of type |b| describes how to transform outputs of a game into a real-valued payoff \footnote{This can be of type \textit{Double} to represent payoffs} or any feedback information from other games as part of that context. Thus, the |StochasticContext| datatype is best-suited as the place to define the logic for supplying payoffs at the top-level of any open game. 

\begin{mdframed}
   \begin{example}[Instantiating a context]
   Assume we have an open game with type (in shorthand) |myGame :: OpenGame () () Action Double| corresponding to a game that outputs an "action" and expects a payoff. In order to evaluate a strategy for |myGame|, we need to supply it an appropriate context. First, we can use the type-checker to draw two conclusions: (1) there is no history that needs to be pipelined in and (2) the continuation function should be a function |payoff :: Action -> Stochastic Double|. We can start with implementing the payoff function, and injecting it into the |StochasticContext| datatype in the second argument, as follows: 

   \begin{code}
   myContext :: StochasticContext () () Action Double 
   myContext = StochasticContext 
      (return ((),())) (\_, action -> payoff action)

   \end{code}
   Thus, we have a context that typechecks with |myGame|, and allows for analysis of |myGame| tied with the implementation of the payoff function. Note this already hints at a code-based dependence between the analysis and execution of models, which we seek to concretize in Chapter \ref{sec:designPatterns}. We also once again see the residual |z| placeholder variable, but can be disregarded for any direct manipulation or observation by a practitioner.
   \end{example}
\end{mdframed}




Getting back to the concept of \textit{local context}, we can define the best-response of a composite game by computing the best-response for each of the components of the game, under their modified \textit{local context}. Defining these modified contexts are encapsulated as part of the engine and automatically calculated, as long as the types match up appropariately. For technical brevity, we omit these details in the thesis, and leave the explanation of the implementation of |StochasticContext|\footnote{See \textbf{OpenGames.Engine.OpticClass} and \textbf{OpenGames.Engine.OpenGames}} and its operations to later work. But conceptually, we can summarize how these modified contexts are formed. 

For a composite game $\mathcal{G} \circ \mathcal{H}$ by sequential composition, we want to evaluate the best-response of the composite game given strategy profiles for its constituent parts $\mathcal{G}$ and $\mathcal{H}$, where the constituent parts each satisfy Definition \ref{Definition:OpenGame}. The context of $\mathcal{G} \circ \mathcal{H}$ is the product of the best-response strategies determined by $\mathcal{G}$ and $\mathcal{H}$. These best-response strategies are calculated using their respective \textit{local contexts}, which each assumes the other game has executed their strategy in the proper order. That is, the best-response strategies of $\mathcal{G}$ is determined by running |evaluate| with a context that assumes a history where we ran |play| for $\mathcal{H}$. Similarly, the best-response strategies of $\mathcal{H}$ is determined with |evaluate| under a context that assumes the continuation (payoff) was calculated using the result of |play| for $\mathcal{G}$. The same conceptual argument applies for tensor composite games $\mathcal{G} \otimes \mathcal{H}$, with a different ordering of |play| relative to the constituent game. One major difference is that the constituent game does \textbf{not} observe or react (covariantly) to the |play| of the other, whereas in the sequential case $\mathcal{G}$ can. For readers interested in the explicit formulation of \textit{local contexts} for composed open games, refer to \cite[Section 3.7]{BayesianOpenGames}. 




\subsection{The category of open games and operations}

By \cite[Theorem 3.10.2]{BayesianOpenGames}, a category of Bayesian open games exists where objects are pairs 
of objects in the Kleisli category of the distribution monad $\mathbf{Kl}(\textbf{D})$ and morphisms are equivalence classes of open games. So modellers will have access to operations that govern sequential and parallel composition of open games as |(>>>)| and |(&&&)| respectively. 

By precomposing a game that makes an observation with a copy operation (\cite[Definition 4.4.3]{BayesianOpenGames}), we give the rest of the model access to this observation. Now we can use the previous sections and build more explicitly on the ideas alluded to in Section \ref{note:hint}.
Without the DSL, we can write Haskell functions for the \textit{copy} and \textit{delete} operations to write a formula for completing Example \hyperref[example:nature] game as follows: 

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


We strongly motivate the usage of open games in the Haskell environment, but preceding this interpretation of open games is directly through the formal syntax known as string diagrams (as described in \cite[Section 2.1.1]{HedgesThesis}). Since the category of open games is symmetric monoidal, we can present the boxes (morphisms) as open games and input and output wires of the boxes (objects) as the types $S, T, A, B$ as presented throughout this chapter. An interesting direction to take in the context of this study is whether collaborative model development benefits from first sketching string diagrams to easily represent the information flow of a game. Several string diagrammatic tools exist that allow digital manipulation of these diagrams, which would allow some visual context for the template games and how they may compose. While this could be useful from a conceptual, brainstorming standpoint, mechanising the process to a software-development workflow gives computational results.  

\begin{figure}[h]
	\centering
	\includegraphics[width=0.5\linewidth]{images/GameSimple.png}
	\caption{A string diagram of an open game \label{figure:Fig. 10}}
	
\end{figure}


\subsection{Reading the DSL}
Rather than constructing games using the aforementioned functions, we can use a DSL that compiles to Haskell, which automatically induces the kind of composition of games as described in the previous section. In this section, we'll explain the DSL syntax. We will use the following example of the prisoner's dilemma game.
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

\begin{mdframed}
\begin{example}[Bayesian agent maximizing utility]\label{example:context}
% Consider the one-shot case adapted from \cite{la2016deceptive}, where a defender is responsible for ensuring the security of an IoT network using a honeypot deployment system. This defender is uncertain about the type of users attempting to access certain servers. Based on historical trends from access records and previous attacks, assume a prior probability of encountering an active attacker as 0.5, where an active attacker is attempting real-time exploits rather than passively collecting information and drawing less attention. In this game model, assuming the defender as the only strategic agent, must maximize his expected reward over the possible types of users he'll encounter. For a worked-out example of the same structure, a biased coin, see \cite[Example 4.5.1]{BayesianOpenGames}. We'll consider a direct correlation between the prior and the actual behaviour of the attacker. Here, we can represent this with the following code: 
To better understand a context for a utility-maximizing agent under uncertainty, we can consider the following example derived from \cite{BayesianOpenGames}. Here, two identically-biased coins are flipped. One is flipped in secret, another is flipped and observed by the agent. The coin is equally likely to be biased towards heads or tails, with a 75\% of favouring a side. The joint probabilitIES for all the resultant outcomes of the two flips from $\mathcal{D}(\{Heads, Tails\}^{2})$ can be represented as a Haskell function: 
\begin{code}
coinFlip = distFromList [
   ((Heads, Heads), 5/16), 
   ((Tails, Tails), 5/16), 
   ((Heads, Tails), 3/16), 
   ((Tails, Heads), 3/16)]

\end{code}


We would like to model this interaction as an open game. An open game representing a Bayesian agent is insantiated with the |dependentDecision| operator. We can wrap this agent into a code block to expose the decision the agent makes, and provide it with the payoff feedbacked from its environment. To work towards a separation-of-concerns approach to creating these games, the coin flipping and payoffs are determined externally (in the environment, or context) of the game.   
\begin{code}
guesser = [opengame|

   inputs : coinObserved, coinSecret;
   feedback: ;
   :----------------------------:


   inputs: coinObserved;
   feedback: ;
   operation: dependentDecision "guesser" (const [WasHeads, WasTails]);
   outputs: guess;
   returns: payoff;

   :----------------------------:

   outputs: coinSecret, guess;
   returns: payoff;


|]


\end{code}



For the agent |guesser|, we expect two inputs, expect it to produce two outputs, and expect some payoff piplined back to the agent. Notice the passthrough of |coinSecret|, which is a necessary variable for calculating the payoff. We can instantiate the compatible context by supplying a history that does the coin-flipping, and an arbitrary function satisfying the type |guesserPayoff :: (Move, Guess) -> Double|. 

\begin{code}

biasedCoinContext = 
   StochasticContext resCoinToss 
      (\_, (m, g) -> playDeterministically $ guesserPayoff (m,g))
         where resCoinToss = fmap (\(t1, t2) -> ((), (t1, t2))) coinFlip
\end{code}

Here, |resCoinToss| is necessary to kick-off the empty residual type |()| and retaining the result of the two coin tosses to send to the agent. |t1| and |t2| are the observed and secret results of the coin tosses, respectively, corresponding to the |coinObserved| and |coinSecret| declared variables in the |guesser| game 

\end{example}
\end{mdframed}

\subsection{Evaluation and reading analytics}\label{sec:eval}
As mentioned previously, Nash equilibrium corresponds to fixpoints of the best-response function of games. Correspondingly in the typical engine output, modellers can read an optimal move and the strategic move and the corresponding expected payoffs for a certain strategy.

Specifying a context for a game to do this evaluation can happen in two ways: (1) specifying the initial history and continuation within in the DSL as embedded Haskell functions, (2) specifying the initial history and continuation payoffs when calling the |evaluate| function. To get a human-readable output In the case of (1), a game with a closed type can then be viewed with the following function: 

\begin{code}
  
runDiagnostics = generateOutput $ 
   evaluate myClosedGame myStrategy void
\end{code}
where |void| is an identity context. 

It's possible to write wrappers in order to codify information into a CSV file with a simple parser, but we leave this for future work to expand the methodology pipeline to ingest real-time data. Thus we consider the open game engine solely as an equilibrium checker in this workflow, though extracting payoffs for repeated game analysis is certainly possible. 

For equilibrium-checking use-cases, |generateIsEq| goes over the diagnostic information and returns True if the strategy profile is optimal, and False along with the conditions for which the payoff is not optimal. This in particular would be the main entry point to conduct rational verification. 

% In a more simulation-focused case of determining the payoff for a particular action, we can "pre-load" the behaviour of an agent by calling |loadedAgent :: StochasticOptic s t a b = play agent1 strategy|, then 

However, outside a classical sense, we can construct \textit{Bayesian sequential games} from \cite[Example 7.7.1.4]{BoltThesis}. Using the diagnostic information, we will have to analyze the payoff for each "alternative world" that our system is simulated in, which can be read from the \textit{Unobservable state} field given in the output. This line manifests as a tuple for every possible state in the support over the distribution of inputs into a given game. This corresponds to "on-equilibrium" paths in the classical sense, where the second-mover must compute their expected payoff for each potential outcome that the first-mover dictates according to their strategy. Notably, this would \textbf{not} correspond to maximizing over all possible subgames. For example, in Figure \ref{figure:simpleDiagnostic}, since the guesser is maximizing over the possible outcomes of two coin flips, each of the four sub-outputs has in the \textit{Unobservable state} field one of four possible ways the coins can be flipped. Note that the resultant payoff in each of these scenarios according to the supplied strategy |guesserStrategy| is equal to the optimal payoff, which would designate this strategy profile as equilibrium.  

\begin{figure}[t]
   \centering
   \includegraphics[width=\textwidth, height=0.5\textheight, keepaspectratio]{SimpleDiagnostic.png}
   \caption{Diagnostic output when running the \textbf{BiasedCoin.hs} game in ghc} 
   \label{figure:simpleDiagnostic}
\end{figure}

Explicitly, the output of |evaluate| is a (nested) list of lists of type |DiagnosticInfoBayesian|. Since these are defined "player-wise," interpreting a game-wide strategy profile is achieved by zipping together lists of |DiagnosticInfoBayesian|. However, we can see how each of the player's strategies correspond to one another by observing the unobservable state. Since the engine only computes payoffs for all possible actions with positive probability, the unobservable state field exactly details which strategy a player is responding to. To see this, we can follow the diagnostic output from \textbf{IDS.IDSA}. We can see that the output is separated between four-blocks, with \textit{Alice}-blocks on top and \textit{A}-blocks below that. Since \textit{Alice} is the first-mover with a private type, the engine maximizes over her two possible types, as depicted by the first tuple of the unobservable state field. Given that she has a fixed strategy (i.e. always accessing a server), the second-mover \textit{A} will only have to maximize over the possibility of seeing an access move. Expectedly, the third block detailing \textit{A}s payoff is in the situation where \textit{Alice} had type attacker and accessed. If \textit{Alice} was given a mixed strategy instead, then we would expect a total of six blocks, where \textit{A} would have four blocks. 

\begin{figure}[t]
   \centering
   \includegraphics[width=\textwidth, height=0.5\textheight, keepaspectratio]{DiagnosticExample.png}
   \caption{Diagnostic output when running the \textbf{IDS.IDSA} game in ghc} 
   \label{figure:diagnosticIDS}
\end{figure}

% To see this, consider the following counterexample in the classic beer-quiche game of imperfect information, where the engine claims 



% First, 


