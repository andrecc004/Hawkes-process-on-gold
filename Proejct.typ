#set document(title: "Stochastic Processes in Gold Price Dynamics", author: "Andre Cachoua")
#show figure: set text(size: 9pt)
#set page(
  paper: "us-letter",
  margin: (x: 1in, y: 1in),
  numbering: "1",
  number-align: center,
)
#set cite(style: "alphanumeric")

#set text(
  font: "New Computer Modern",
  size: 11pt,
  hyphenate: false,
)

#set par(
  leading: 1.5em,        // 1.5 spacing (use 2em for true double spacing)
  spacing: 2em,          // space between paragraphs
  first-line-indent: 1em,
  justify: true,
)

#set heading(numbering: "1.")


#show heading: it => [
  #v(1em)
  #text(weight: "bold", size: 12pt)[#it]
  #v(0.5em)
]

#set page(
  paper: "us-letter",
  margin: (x: 1in, y: 1in),
)

#set text(font: "New Computer Modern", size: 11pt)

#align(center)[
  #v(1fr)
  
  #text(size: 16pt, weight: "bold")[
    Stochastic Processes in Gold Price Dynamics
  ]
  
  #v(0.5em)
  
  #text(size: 12pt)[
    Andre Cachoua
  ]
  
  #v(0.3em)
  
  #text(size: 11pt, style: "italic")[
    Math 467 — Stochastic Processes
  ]
  
  #text(size: 11pt, style: "italic")[
    University of Oregon
  ]
  
  #v(1fr)
]


#align(center)[

  = Abstract

Volaitlity clustering is the tendency of large price moves to precede larger prices moves, and its one of the most observed behaviors in financial markets. In this paper I investigate wether a bivariate Hawkes process, applied jointly to normalized candle
range, a proxy for volatility, and trading volume, provide a viable framework for
identifying this self exciting behavior in intraday gold market data. Using one minute candles for the _GLD_ ticker over
seven trading days, I propose an
estimation procedure in which the decay rate $kappa$ is recovered
from the exponential decay of the autocorrelation
function within a rolling window, requiring only the window length $W$ as an input. The model yields mean
branching ratios of $n_r = 0.327$ and $n_v = 0.384$ for the range
and volume processes respectively, confirming stationary
for the self exciting behavior, and cross excitation coefficients of 
$alpha_(v r) = 0.153$ and $alpha_(r v) = 0.126$, providing 
evidence that volume and volatility mutually reinforce each other as wekk.
 A momentum trading strategy derived from the intensity then achieves a profit factor of 1.651 on a
held out test set, with multiple parameter combinations producing profit factors above 1, capturing market structure. 


]

#pagebreak()


  = Introduction

  
  
 The premise is based on the idea that stock market prices, particularly those not driven by firm-specific or microeconomic factors, are largely random. In previous work, I attempted to identify variables from other stocks and indices that correlate with movements in the price of gold, finding that they explain only a small portion of its behavior. Gold operates in a market large enough that only major global economic events meaningfully impact its price. Unlike many assets, gold is not dependent on a single market; it functions simultaneously as a commodity, a forex instrument, a luxury good, and a hedge against inflation. This unique role suggests that while gold exhibits an underlying trend and expected behavior, its short-term price movements oscillate largely at random around that trend.


Because of gold’s role in financial markets, we can form expectations about its behavior and treat price prediction as more of a probabilistic problem rather than a gamble. I aim to observe the rate and frequency at which gold's price fluctuations occur, and when do these dramatic changes or rapid movements happen, its _volatility_ to be clear. I also aim to determine whether these movements can be modeled using stochastic principles. 

The approach given at this problem was that of understanding the underlying _regimes_ for gold's price dynamics, those being some period where price exhibits a specific and persistent statistical behavior, the focus on this paper will be that of the underlying behavior from _volume_ and _volatility_. 

  Within these regimes, one important pattern emerges, _volatility clustering_. Rather than spikes in volatility appearing randomly and independently, we can observe that high volatility periods tend to cluster, and large price movements are followed by movements of variably similar magnitude, and periods of small fluctuations in price, are followed by similar .#cite(<dingModelingVolatilityPersistence1996>)#cite(<hawkes1971b>)

This clustering behavior is especially notable in the relationship derived from volatility and volume. High _volume events_, the number of high quantities of shares traded,  trigger subsequent _volatility_, which in turn attracts more trading. This behavior in nature exemplifies a _self exiting process_, when the occurrence of an event increases the likelihood of future events occurring. In the context of markets it's self reinforcing, being its not derived intrinsically from noise, such that its a "systematic feature" of the market's nature #cite(<mandelbrot1963>) . 





In this paper I  will investigate whether a dual variable Hawkes process based on candle range and volume can identify market volatility regimes. The methodology builds from existing Hawkes models by estimating the decay parameter (\kappa) through a rolling autocorrelation procedure rather than fixing it, modeling range and volume as mutually exciting processes, and validating regime classifications against a _HMM_. The resulting regimes are evaluated for developing a trading strategy.  The goal is to determine whether self exciting process models actually provide an edge on prediction, and show useful framework for capturing market regime structure. An introduction to the relevant definitions and methodology is also provided.




#let vol = "vol"












\




= Preliminaries

== Point Processes and Intensity Functions


A *point process* is a stochastic model for the random arrival of events 
over time. Let $0 < t_1 < t_2 < t_3 < dots$ denote a sequence of random 
arrival times. The associated *counting process* $N(t)$ records the total 
number of events that have occurred up to time $t$:

$
N(t) = \#{T_n : T_n <= t}
$

That is, $N(t)$  counts how many arrivals have happened by time $t$. 
It starts at zero, increases by one at each arrival, and never decreases.

Its behavior is described by its *intensity function* 
$lambda(t)$, which represents the instant rate of arrival at time $t$ 
given everything that has happened up to that point:

$
lambda(t) Delta t approx PP("one event arrives in" [t, t + Delta t))
$

$
lambda (t) = lim Delta → ∆−1E N t+∆ −N t | scr(F) t]
$

Intuitively, $lambda(t)$ answers the question: given the history of the 
process up to time $t$, how fast are events expected to arrive right now? 
A large $lambda(t)$ means arrivals are coming rapidly. A small $lambda(t)$ 
means the process is slow / quiet.

The simplest example is a * Poisson process*, in which 
$lambda(t) = mu$ is constant, so the arrival rate never changes regardless 
of history. For my purposes, the _Hawkes process _generalizes this by allowing $lambda(t)$ 
to depend on the history of past arrivals, returning the self exciting 
behavior mentioned from financial volatility data. #cite(<engle1982>)
 



=== The Hawkes Process

The *Hawkes process* is a form of a point process in where the intensity function depends on the occurrence of past arrivals. This is what makes it self exiting, each new arrival increases the intensity, further increasing the probability of future arrivals. The general form is the following:




$
lambda(t) = mu + sum_(t_k < t) phi(t - t_k)
$

#align(center)[
  Where $mu > 0$ is the baseline intensity
]

In the absence of any past excitation of the process, $mu$ is the arrival rate constant, and $phi(t - t_k)$ is the excitation kernel, describing that past influence of occurrences on the arrival rate at step $t_k$ is exerting at the current intensity at time $t$. This process therefore is not _memoryless_#footnote["memoryless"          → : formally the Markov property,
                        P(future | full history) = P(future | present)] thus every past event contributes some term $phi(t - t_k)$ in the sum, but the further in the past that event is, the less it should influence. As for this, we then require  $lim_(s->infinity) phi(s) = 0$. #cite(<bacryHawkesProcessesFinance2015>)

So the choice of kernel $phi$ will determine the memory structure of the process. 
For this paper I'm going to adopt the *exponential kernel*, introduced by Hawke's originally in $(1971)$ #cite(<hawkesSpectraSelfexcitingMutually1971>) and widely adopted 
in financial applications is defined as:

,




$
phi(t - t_k) = alpha e^(-kappa(t - t_k))
$

which yields the specific intensity function used throughout:

$
lambda(t) = mu + sum_(t_k < t) alpha e^(-kappa(t - t_k))
$
This was my ultimate choice as it comes standard in financial applications, for three reasons #cite(<bacryHawkesProcessesFinance2015>).
First, the exponential kernel produces a more computationally efficient recurrence form, that is, a more  optimized way to compute on the candles data. Second, it makes the process Markovian, $lambda(t)$ 
depends only on the previous intensity value, not the full history of arrivals, this might come as confusing from the previous definition but we can show from:

$
lambda(t)=mu+e^(−kappa Delta t)(lambda (t−Delta t)−mu)
$

$lambda$ now, you only need $lambda$
 one step ago — because $lambda_(t-1)
$​ already has the full history embedded in it from when it was computed. Each previous step folded all prior history into a single number, and you just carry that number forward discounted by $e^(−kappa Delta t)$ where $kappa > 0$ is the decay rate of the exponential kernel, and $Delta t$ is 
the fixed time interval between consecutive observations, in this setting 
one candle, so that $e^(-kappa Delta t)$ is the factor by which the accumulated intensity is discounted at each bar

 Third lastly, a process with exponential kernel implies an 
autocorrelation function that itself decays exponentially, a property 
exploited in Section *3.0.3 *to estimate $kappa$ directly from the data. 
\
\

=== The Exponential Kernel

The general Hawkes process uses $phi(t - t_k)$ excitation kernel, 
as a placeholder for any valid decay function to describe the influence 
of past events. For this paper I will specify $phi$ as the exponential 
kernel:

$
phi(t - t_k) = alpha e^(-kappa(t - t_k))
$

so that $kappa$, the decay rate, and $alpha$, the excitation amplitude,
fully characterize the memory structure of the process. So we will replace $phi$ onwards, so that all expressions use 
$alpha$ and $kappa$ directly. #cite(<bacryHawkesProcessesFinance2015>)

For these two parameters. The first being, $alpha > 0$, 
our excitation amplitude, that being the size of the initial spike in intensity 
caused by each arriving event. The second mentioned, $kappa > 0$, the decay rate, 
 the speed at which that spike dissipates over time. So the structure of both interacting is as follows:

 - A large value of $kappa$ means the sighting of each event influences the event to decay faster, and, the process then has a short memory, only very recent arrivals will matter.
 
- A small value of $kappa$ will conversely influence the decay slowly, and events from further in the past will continue to contribute slightly to the current intensity.



For the model $kappa$ is not fixed, It will be estimated from the data
within a rolling window, as per the generation of new candles, and limiting the compute requirement for the model at each time step $t$. 

For this estimation procedure, we use another porperty from the exponential kernel itself, that is, that its autocorrelation function $"ACF"(ell)$ generated bby a process with the exponential kernel, has an exponential decay with the same rate $kappa$ 
\
\
=== Autocorrelation function
\
#let Cov = "Cov"

Recall the covariance formula is given by:
$
Cov(X,Y)=EE[X Y]−EE[X]E[Y]
$
The _autocovariance_ of a process $X(t)$ is just covariance of the process with its own past:
$
C_X (s,t)=Cov(X(s),X(t))=EE[X(s)X(t)]
$
Changing the inputs to
$ell$, the lag#footnote[ℓ (lag, number of candles back)], $x_t​ $ then is the normalized candle range at the current time t, and 
$x_(t−ell)$ is the normalized candle range at time $t−ell$, meaning $ell$
candles back from the current candle



$
C_X​(ℓ)=Cov(x_t​,x_(t−ell))=EE[(x_(t​)-mu))(x_(t−ell)​−mu))]
$
#align(center)[
Where $μ=1/W sum x_t$ is the window mean of the input series#footnote[W (rolling window length in candles)]

]

Recall then that for an independent series like fair coin flips, knowing the $n-1$ flip tells us nothing about then $n$th. The series is _memoryless_, so for a _self exciting_ series like _volatility_, knowing the previous candle range does tell us something about the current.


So we can use _Autocorrelation_ as a measure and quantifier for that memory, instead of correlating two different variables, we correlate a series with its own past, with the objective to know how similar is $x_t$
to $x_(t−ell)$ #cite(<dafonseca2014>)


#let ACF = "ACF"
#let Var = "Var"

Staring with $ell$ at $t=0$ we are comparing the series with itself 
$
C_X​(0)=Cov(x_t​,x_t​)=EE[(x_t ​−μ)^2]=Var(x_t)
$
Then normalizing the _correlation function_#footnote[Correlation between two different random variables $X$ and $Y$ is defined as
$rho(X, Y) = frac("Cov"(X, Y), sqrt("Var"(X) "Var"(Y)))$
] by the variance $ C_X (0)=Var(x_t)$
 gives the autocorrelation function:
$
ACF(ell)=(C X​(ell)​)/(C X​(0))= (Cov(x_t​,x_(t−ell))​)/(Var(x_t​))
$
A value of $ACF (ell)$ close to 1 is indicating a strong correlation of memory at that lag $ell$, meaning large candles are being followed by large candle ranges, A value near 0 indicates the series has no memory at that lag. 

A property from the $ACF$ is that it decays at the same rate $kappa$. Recall that $kappa$ controls the decay rate, and since each event contributes to the intensity $lambda(t)$, and the contribution decays exponentially from:

$
e^(-kappa (t - t_k))
$

as time advances from the time $t_k$.


The $ACF$, measures the similarity of a time $x_t$ and its past $x_(t-ell)$, since the effect of this past event on the current intensity is decaying at rate $kappa$, then the dependence between observations $x_t$ and $x_(t-ell)$ likewise decreases as the lag increases. As consequence,  the autocorrelation function is expected to exhibit approximately exponential decay:

$
"ACF"(ell) approx C dot e^(-kappa ell)
$ 

where $C$ is the amplitude constant, height the curve starts at (at $ell = 0$), that captures the overall strength. Fitting this curve to the observed sample $"ACF"$ therefore 
recovers $kappa$ directly from the data's own memory structure. $C$ and $kappa$
are estimated via nonlinear least squares#footnote[
  Nonlinear least squares finds the values of $C$ and $kappa$ 
  that minimize the total squared difference between the observed 
  $"ACF"(ell)$ values and the model curve $C e^(-kappa ell)$ 
  across all lags. It is applied using the python library SciPy 
], and  $C$
gets discarded after the fit, so $kappa$ is retained as the parameter of interest.
\

=== The Branching Ratio
\


Having established that $kappa$ (decay rate) can be recovered from 
the ACF, we now turn to the branching ratio $n$, the primary 
interpretive output of the model. Recall the exponential kernel:

$
phi(t - t_k) = alpha e^(-kappa(t - t_k))
$

We can then obtain the 
total influence that a single event exerts over all future time, by integrating the kernel from zero to infinity, 0 from the moment the event occurs, and its influence starts, to infinity at the theoretical future end where the exponential fully decayed.

$
n = integral_0^infinity alpha e^(-kappa t) d t = alpha / kappa
$
We will define this integral as the _branching ratio_. It evaluates exactly into $alpha / kappa$
representing the average of how many future events does a single event produce before 
the excitement dies out? As an example, if $n = 0.6$, one volatile candle generates 
a cluster of $1 slash (1 - 0.6) = 2.5$ candles in total before the 
intensity returns to baseline $mu$.

For the process eventually die out 
rather than growing indefinitely we require:

$
n_t = alpha_t / kappa_t < 1
$

This is the stationarity condition. When $n >= 1$ each event 
produces at least one offspring on average and clusters grow without 
bound. The following are the cases explaining its behavior:

- *$n = 0$*: There is no self excitation at all. Therefore every arrival is independent 
  of the past and the process reduces to a  Poisson process 
  with constant rate $mu$.

- *$n -> 1$*: the process approaches an _explosive regime_. Each event 
  produces nearly one offspring, clusters persist 
  indefinitely, and the intensity $lambda(t)$ never 
  returns to the baseline.

For this paper the rolling branching ratio $n_t$  is computed at each 
bar $t$ within the rolling window $W$ 
using the estimates $hat(alpha)_t$#footnote[$hat(alpha)_t$ = fitted excitation amplitude] and 
$hat(kappa)_t$ recovered from the ACF fitting 
procedure. So a rising $n_t$ signals a building volatility cluster, and a
falling $n_t$ signals the cluster is exhausting / decaying.

=== Discrete Recurrence Form

The intensity function defined so far is continuous in time, but we run into a problem where in 
practice, the candle data arrives within some  equally spaced intervals, so let
$Delta t$ be the length of one candle interval, so the continuous integral has to be 
translated into a form computable on a bar by bar basis, and in discrete form.

Recall the continuous intensity:

$
lambda(t) = mu + sum_(t_k < t) alpha e^(-kappa(t - t_k))
$

 At each new 
candle $t$, every term in the sum is the same term from the previous 
one, multiplied by the additional decay factor $e^(-kappa Delta t)$ 
, thediscount factor per candle, plus the new candle $x_t$. This gives:

$
lambda_t = x_t + e^(-kappa) dot lambda_(t-1)
$

where $lambda_t$ is intensity at candle $t$, $x_t$ the current candle 
input, $e^(-kappa)$ per candle discount factor, and $lambda_(t-1)$ 
. This is exactly equal  to the 
continuous form above when we set the observations to arrive at fixed intervals, so no information is lost in the change.

This recurrence has a useful characteristic though, to compute $lambda_t$ we 
only need $lambda_(t-1)$ and $x_t$. We dont need the full history of arrivals as it is already part of
$lambda_(t-1)$ from when it was computed. This is the Markov property of the intensity, 
the current value contains all the information needed to compute 
the next, making the recurrence memoryless in storage and mroe computationally efficient.



= Parameter Estimation
== Overview and order of operations
All parameters are estimated from the data within a rolling window 
$W$ (window length in candles). No parameters are set by hand except 
$W$ itself, so the estimation follows a strict order:

$
W arrow.r kappa_t arrow.r mu_t arrow.r alpha_t arrow.r n_t
$

where $kappa_t$, $mu_t$, $alpha_t$ 
, and $n_t$  are all derived 
from the data within the current window. Finally $n_t$ will always be the final 
output.

== Rolling Window $W$

The input for W is formally defined as follows: At each candle $t$ the estimation is performed on the most recent $W$ 
candles $[t - W, t]$. The window then rolls forward one candle and 
all parameters get re-estimated. This lets the model be continuously changing and adapt to the conditions of the market, it will be the only set parameter by me, if its defined too short then the _ACF_ estimates get too noisy, and if its too large we risk loosing adaptability, If using fine scaled the a large $W$ would also be computationally expensive.


=== Decay Rate $kappa_t$

Recall from Section 3 that the Hawkes process with the exponential kernel 
implies theres an autocorrelation function that itself decays exponentially 
at a rate $kappa$. This property then lets $kappa_t$ be 
estimated from the observed memory of the data, 
without needing a full likelihood maximization.

Within each rolling window of length $W$ 
ending at candle $t$, we can compute the sample ACF of the candle sequence, for 
either volatility or volume, at lags $ell = 1, dots, L$ 
(lag, candles back), where $L$ is set as a fixed fraction of $W$ 
such that ACF estimates at the longest lags that remain reliable. This 
produces $L={"ACF"_t (1), "ACF"_t (2), dots, 
"ACF"_t (L)}$, creating a snapshot of how much the series remembers its own past within the current window.

We then can fit the exponential curve $C e^(-kappa ell)$ to the 
observed values by solving:

$
kappa_t = arg min_kappa sum_(ell=1)^(L) 
("ACF"_t (ell) - C e^(-kappa ell))^2
$

where $C$, our amplitude constant#footnote[C is estimated from the least squares fit, as the optimizer solves for values of C and $kappa$ until the curve sits close to all $L$ points, C returns what height should the curve start at to best fit the data, and is discardable as it carries no information about rest of the process, but without it the curve would be forced to start at exactly 1.0], and $kappa_t$ are 
estimated jointly, $C$ is discarded after the fit and $kappa_t$ 
is retained. The quantity being minimized is the total squared 
difference between the observed ACF values and the model curve 
at each lag. The $kappa_t$ that minimizes this is the decay rate 
most consistent with the memory structure of the data in the 
current window.

As menitoned, having a fast decaying ACF produces a large $kappa_t$, meaning excitement 
dies quickly and clusters are short lived. A slow decaying ACF then
produces a small $kappa_t$, thus clusters persist, but because the 
window rolls forward one candle at a time, $kappa_t$ updates at 
every bar and reflects the current autocorrelation regime rather 
than a fixed historical estimate, and this is what makes the model 
adaptive rather than static.

=== Baseline Intensity $mu_t$

Recall, $mu > 0$ is the baseline intensity

and in the absence of any past excitation of the process, $mu$ is the arrival rate constant. To futher this idea, the baseline intensity is the rolling mean of the for the input data 
within the current window, requiring no fitting:

$
mu_r = 1/W sum_(i=t-W)^(t) r_i, quad
mu_v = 1/W sum_(i=t-W)^(t) v_i
$

where $r_i$ (normalized range at candle $i$, metric for volatility) and $v_i$ (volume 
at candle $i$).

=== Excitation Coefficient $alpha_t$
We defined $alpha$ as, $alpha > 0$, 
the excitation amplitude,  being the size of the initial spike in intensity 
caused by each arriving event, then
$alpha_t$ is derived from the same ACF fit using the lag one 
autocorrelation:

$
alpha_t = n_"ACF" dot kappa_t, quad
n_"ACF" = "ACF"_t (1) / (1 - "ACF"_t (1))
$

where $"ACF"_t (1)$ (lag-one autocorrelation within the current 
window).

=== Branching Ratio $n_t$
The final variable is 
the rolling branching ratio, and is computed last as:

$
n_t = alpha_t / kappa_t = "ACF"_t (1) / (1 - "ACF"_t (1))
$

Notice that $n_t$ is simplified entirely to a function corresponding to the lag one autocorrelation, $"ACF"_t (1)$, this being correlation between to adjacent candles. What this conveys is if $"ACF"_t (1)$ returns a high value, it means adjacent candles are 
strongly correlated, which directly implies high self excitation trend, and a large $n_t$ and low $"ACF"_t (1)$ indicates the adjacent candles 
are mostly independent, which implies a low contagion and a small $n_t$. As mentioned $n_t$ is the primary indicator for the regime of the model, so instead of looking at the market as being discretely in high or low volatility, $n_t$ gives a continuous measure of how self exiting the process is currently is, thus rising $n_t$ indicates 
a building _volatility cluster_ thus each candle is increasingly 
pushing the next, and a falling $n_t$ shows exhaustion from the cluster, meaning it is decaying out and the process is returning towards baseline 
$mu_t$
\
When $n_t arrow 1$ the model shows 
an abnormally persistent cluster where excitement is no longer 
self correcting itself, and the values for the metric fall within a single interpretable number that sits between 0 and 1 for 
a stable process.

= Model

== Data

The data collected to sample the candles for the models is imported using the yahoo finance public python API, the data produces a matrix of vectors for volume along with Open, High, Low, and Close prices. The window W of time can be divided in intervals for candle frequency and time series length, here the time series day is for 7 days of 1 minute data, returning 2,730 candles, each bar then has a measure of open, high, low, close, volume. I chose the 1 minute frequency  as it is the finest granularity freely available via yfinance, and it provides sufficient resolution to observe short term volatility clustering while remaining computationally cheap.\

For the purpose of training the model, the data must be split in chronological order to avoid lookahead bias, so the model trained on 70% past most data, and tested on the 30% most present.


== Input Construction

Two input series are constructed from the raw candle data and fed 
separately into the bivariate Hawkes system: so we will model the normalized range 
$r_t$ (volatility proxy) and volume $v_t$ 
\
\

== Normalized Range volatility$r_t$

As mentioned for each interval of time, yfinance provides an observation for a high price $H_t$ and a low price $L_t$, 
representing the maximum and minimum price reached within that 
1-minute window, the raw range $H_t - L_t$ would measure the absolute 
price spread of the bar in dollar terms, but this is not directly 
useful, since a \$1 move in a \$200 asset is very different from a \$1 
move in a \$20 asset. so taking the logarithm of both prices before differencing solves 
this:

$
log(H_t) - log(L_t) = log(H_t / L_t)
$

And this returned the proportional range, regardless of whether GLD 
is trading at \$180 or \$220, A candle with a 1% spread looks the 
same at any price level.

Now
we then normalize by the average true range $"ATR"_W$, so the 
rolling mean of the log range over the past $W$ candles:

$
"ATR"_W = 1/W sum_(i=t-W)^(t) (log(H_i) - log(L_i))
$

I did this with the objective to measure then volatility relative to recent typical conditions rather than in absolute terms.
 giving the final normalized range:

$
r_t = frac(log(H_t / L_t), "ATR"_W)
$

 A value of $r_t = 2$ would then mean its twice as volatile compared to the mean.
== Volume $v_t$

The volume data is the raw number of shares or units traded 
in each 1-minute bar, taken directly from the yfinance output:

$
v_t = "Volume"_t
$

But different from the range, volume is not normalized by ATR,  it is however 
z-score standardized within the rolling window to make it 
comparable in magnitude to $r_t$ and to remove the intraday 
volume seasonality#footnote[Intraday volume follows a well known 
U-shaped pattern, where its high at the open, low at midday, high at the 
close. Z-score standardization within the rolling window removes 
this systematic variation so that the models intensity responds 
to unusual volume relative to the current local level, instead to the excitation of
the time of day.]

$
tilde(v)_t = frac(v_t - mu_v, sigma_v)
$

where $mu_v$ is our rolling mean of volume within window $W$ and 
$sigma_v$ rolling standard deviation of volume within window 
$W$,  $tilde(v)_t$ is our volume input for the model.



== The Bivariate Hawkes Process



So far I mentioned the Hawkes process to be applied to a single series 
the normalized range $r_t$ and didn't quite explain the reference to this bivariate process.  Volatility and volume do not 
evolve independently. A sudden spike in trading volume often 
precedes or accompanies a large price move, and a large price 
move tends to attract further volume. Each series can excite 
not only itself but the other, its mutually exciting, its nothing I'm going to prove, but rather validate with the model.



=== Joint Intensity Functions

We can define $lambda^r (t)$ (range intensity, arrival rate of volatility 
events) and $lambda^v (t)$ (volume intensity, arrival rate of 
volume events). 
\
Each intensity has two sources of excitation, 
its own past and the other process:

$
lambda^r (t) = mu_r + integral_(-infinity)^(t) 
alpha_(r r) e^(-kappa_r (t-s)) d N^r (s)
+ integral_(-infinity)^(t) 
alpha_(v r) e^(-kappa_v (t-s)) d N^v (s)
$

$
lambda^v (t) = mu_v + integral_(-infinity)^(t) 
alpha_(v v) e^(-kappa_v (t-s)) d N^v (s)
+ integral_(-infinity)^(t) 
alpha_(r v) e^(-kappa_r (t-s)) d N^r (s)
$

where $mu_r, mu_v$ (baseline intensities), $kappa_r, kappa_v$ 
(decay rates for range and volume respectively), and 
$d N^r (s), d N^v (s)$ (past arrivals of range and volume 
events). The first integral in each equation is the 
self excitation term for past range events exciting future range and
past volume events exciting future volume. The second integral 
is the cross excitation term, where past events in one series 
directly raise the intensity of the other.

As mentioned, the Hawkes process is defined in continuous time, where 
the intensity at time $t$ accumulates the decaying influence of 
every past event via an integral over the full history. In 
practice though, we know candle data arrives at fixed discrete intervals 
of $Delta t = 1$ minute, so there's no notion of an event arriving 
between bars. Under equally spaced observations the continuous 
integral collapses exactly into the recurrence derived in Section 
3.0.6. 

$
lambda_t^r = r_t + e^(-kappa_r) dot lambda_(t-1)^r 
           + alpha_(v r) dot e^(-kappa_v) dot lambda_(t-1)^v
$

$
lambda_t^v = tilde(v)_t + e^(-kappa_v) dot lambda_(t-1)^v 
           + alpha_(r v) dot e^(-kappa_r) dot lambda_(t-1)^r
$




where $r_t$ is the normalized range, $tilde(v)_t$  is the standardized 
volume, $e^(-kappa_r)$ and $e^(-kappa_v)$ are the  per candle discount 
factors, and $lambda_(t-1)^r, lambda_(t-1)^v$ the previous 
intensity values. Now, each candle the range intensity depends on the previous 
volume intensity through $alpha_(v r)$, and the volume intensity 
depends on the previous range intensity through $alpha_(r v)$.

=== Cross-Excitation Coefficients

So following the previous, the four excitation coefficients are:

#table(
  columns: (auto, auto),
  [*Coefficient*], [*Meaning*],
  [$alpha_(r r)$], 
  [How strongly a large range candle excites future range],
  [$alpha_(v v)$], 
  [How strongly a large volume candle excites future volume],
  [$alpha_(v r)$], 
  [How strongly elevated volume excites future volatility],
  [$alpha_(r v)$], 
  [How strongly elevated volatility excites future volume],
)

 The off diagonal terms $alpha_(v r)$ and 
$alpha_(r v)$ are the cross excitation coefficients and are the 
central of the model. If both are 
statistically significant and positive, volume and volatility 
do not merely cluster in parallel, so they actively drive each 
other. 
So let $H_0$:

$
H_0: alpha_(v r) = 0 quad "and" quad alpha_(r v) = 0
$


=== Regime Signal

As I described, the output at each bar $t$ is a 
pair of intensity values $lambda_t^r$ for range intensity and 
$lambda_t^v$ for volume intensity. So instead of  treating these as 
raw numbers, I convert them into a regime signal by comparing 
each intensity against its own recent distribution using a rolling 
quantile threshold#footnote[A quantile threshold is simply a percentage of the distribution within a cutoff is placed in which the percentage of values of fall into, rolling implies this cutoff is not fixed. It is recomputed at every bar using only the last W observations, so it adapts as the intensity level shifts over time. ].

At each bar $t$ we compute the 5th and 95th percentile of 
$lambda_t^r$ over the past $W$ candles:

$
Q^r_(0.05) = "quantile"_(0.05)(lambda^r_(t-W), dots, lambda^r_t)
$
$
Q^r_(0.95) = "quantile"_(0.95)(lambda^r_(t-W), dots, lambda^r_t)
$

Thus I can define the regime at bar $t$ as:

$
R_t = cases(
  "High" quad & "if" lambda_t^r > Q^r_(0.95),
  "Low"  quad & "if" lambda_t^r < Q^r_(0.05),

)
$

So a  High regime means the range intensity has risen above its 
typical recent level and a volatility cluster is forming. 
A Low regime means the opposite, the cluster exhausted and the process 
is returning toward baseline $mu_r$.

I chose the 95th and 5th percentile thresholds to be able to identify 
genuinely extreme intensity values, those from the outer 5% of 
the recent distribution, as a significance level. I believe it will also minimize false 
positive regime signals at the cost of potentially missing 
smaller clusters.

The same thresholding is applied to $lambda_t^v$ to produce 
a volume regime signal $R_t^v$, allowing comparison of whether 
range and volume regimes coincide.

The regime sequence of $R_t$ is what gets carried forward into 
Section 6, where it is cross-validated against an HMM  on the return series. If the two 
methods agree on regime timing without having shared any 
information, that agreement gives external validation 
that the Hawkes intensity is capturing data structure.


=== Validation: Hidden Markov Model

As an independent cross-validation of the regime structure 
identified by the Hawkes process, I fit a Hidden 
Markov Model directly to the 1-minute GLD log return series 
using the pomegranate library #cite(<qwareeqModelingHistoricalGold2025>). The HMM 
assumes three latent states of low, and high volatility each with a Gaussian  distribution. 
#cite(<jurafskySpeechLanguageProcessing2026>).

The HMM has no access to the Hawkes intensity, thus it discovers states purely from the return distribution. I will not delve into explaining the Hidden Markov Model, but it will be defined in the Apendix.
\
\
= Results

== Data Overview

Starting on GLD 1-minute bars spanning seven trading 
days, filtered only to New York stock exchange market hours (9:30--16:00 ET), yields 2,730 
usable observations after removing overnight and weekend gaps that distort the rolling window estimates. The 
first 1,910 bars (70%) constitute the training set and the remaining 
820 bars (30%) the test set. The normalized range $r_t$ and 
standardized volume $tilde(v)_t$ are constructed from each bar's 
OHLCV#footnote[OHLCV = open, high, low, close, volume] data as described in Section 5, with rolling window $W = 50$ 
candles (approximately 50 minutes of local data) and maximum ACF 
lag $L = 20$ candles #cite(<scipy2020>).

#figure(
image("GLD 1-Minute Data, Training Set .png"),caption: [ GLD Close, Normalized range, Standardized volume])


== Parameter Estimates

#table(
  columns: (auto, auto, auto, auto),
  [*Parameter*], [*Symbol*], [*Range*], [*Volume*],
  [Decay rate (mean rolling)],
  [$kappa_t$], [$0.821$], [$1.061$],
  [Branching ratio (mean rolling)],
  [$n_t$], [$0.327$], [$0.384$],
  [Cross-excitation],
  [$alpha_(v r), alpha_(r v)$], [$0.153$], [$0.126$],
)


The decay rate for $kappa_r = 0.821$ is implying that for each candles volatility's influence on future intensity is being decayed by a factor of
$e^(-0.821) approx 0.44$ thus within one candle, roughly half the
self excitement dissipates in a single minute. The volume model
decays faster at $kappa_v = 1.061$, which confirms that volume spikes expand less than volatility spikes. This asymmetry is somewhat 
surprising but not out of the ordinary, with the observed of the structure of gold markets, and markets in general, to some extent large range
candles tend to trigger sustained follow through while volume bursts
are more reactive and short lived.

The mean branching ratios $n_r = 0.327$ and $n_v = 0.384$ are indicating
both processes are stationary, each volatile candle generates
about 0.33 offspring before the cluster dies, implying a total
expected cluster size of $1 slash (1 - 0.327) approx 1.5$ candles.
The rolling $n_t$ series does exhibit occasional short lived spikes above
the explosive level, here above 1, in both processes, corresponding to
brief near explosive episodes visible in the branching ratio plots.
These excursions are notably almost immediatwly self correcting and look consistent with a
 market that would show locally intense behavior during
intraday price shocks.
#figure(
image("ratios.png"), caption: [Regime indicators - Ratio estimates])

== Cross-Excitation

The central question was whether volume and volatility
mutually excite each other beyond what either process generates
independently. The estimated cross-excitation coefficients are:

$
alpha_(v r) = 0.153, quad alpha_(r v) = 0.126
$
#figure(
image("cross exitation.png"),caption: [Cross-excitation, Estimate $alpha_{v->r}$  and $alpha_{r->v}$  
cross-correlation ])
Both were positive through the training period and remain positive on the test set, which shows evidence that there exists a feedback loop between volume and volatility, and that its persistent instead of unpredictable or by episodes. The stronger of a volume to range coefficient $alpha_(v r) > alpha_(r v)$, the more volume leads the feedback loop, in this case we see volume shows to be a stronger predictor of volatility rather than the contrary. In a context of markets this follows the logic that large volume behavior for firms and market makers happens before the impact on price change.






== Regime Signal and Visual Interpretation

Recall the range intensity $lambda_t^r$ was compared against rolling
5th and 95th percentile thresholds to produce a binary regime
signal. In this case the signal for Medium was discarded, a High regime is declared when $lambda_t^r > Q_(0.95)$
,the intensity is in the top 5% of its recent distribution,
indicating an active volatility cluster. A Low regime is declared on the complement.
#figure(
image("image.png"), caption: [Intensities + binary regime])
Inspection of the training set price chart shows that the High regime
bars (red) cluster at the onset of sharp intraday price moves, 
notably at the beginning of the strong rally on 2026-05-29 and at
the initial selloff on 2026-06-01, the low regime periods (blue)
correspond to the quieter consolidation phases between these moves,
where the intensity has decayed back toward its baseline
$mu_r$. 

The test set had surprising results, the regime signal generalizes visibly. The sharp
selloff beginning on 2026-06-05 is flagged as a High regime
episode at its early stages and the previous day, with the intensity rising sharply above
$Q_(0.95)$ and decaying gradually as selling pressure exhausted
itself. The High regime bars again appear at the most volatile
moments of the test period. During this time, all markets had a sharp selloff due to increase in rate hike expectation and shift in capital allocation, yet the model displays this out of the ordinary behavior even from the previous day's close, something hard to observe simply from price action on a chart, which corroborates the practicality of the process. 
A limitation on the capture efficiency relies on the nature of gold markets. While testing on more volatile assets, like _QQQ_ or _NVDA_, the model seemed to identify intraday volatility with significantly higher accuracy, using an asset like _Bitcoin_ with no market hour's limitation, display of this accuracy improves greatly. 
#figure(
image("test set.png"),caption: [ Test Set Evaluation, model on held-out 30% using cross-excitation coefficients from training. $kappa$ re-estimated on test data.])
== Trading Strategy Performance

An attempt was made to cross-validate the Hawkes implied regime 
sequence against the Hidden Markov Model mentioned, fitted independently on the 
GLD return data. The HMM was fitted via the_ Baum-Welch algorithm _
with three Gaussian states on both 1-minute and 5-minute resampled 
returns. In both cases the model produced solutions with near null variance,
in which two states were statistically indistinguishable 
($sigma_1 = 0.00327$, $sigma_2 = 0.00328$ at 1-minute resolution), thus
reflecting insufficient return variation in GLD at intraday 
resolution to support a cross validation. I then attempted to implement a simple trading strategy as means of validating the practicality of the model. The Hawkes regime signal is applied as a momentum exit
strategy. The entry rule fires when $lambda_t^r$ crosses above
$Q_(0.95)$, and the direction of the trade is set by the price change
since $lambda_t^r$ last crossed below $Q_(0.05)$, so long if
price has risen and short if it has fallen. The exit signal then fires when
$lambda_t^r$ crosses back below $Q_(0.05)$, signaling that the
self exciting cluster has exhausted itself. I then measured performance simply 
by the profit factor, the ratio of total winning returns to total
losing returns, where a value above 1 indicates a profitable
strategy, #cite(<mckinney2010>)#cite(<harris2020>)



#figure(
image("returns.png"),caption: [Cumulative returns derived from Hawkes intensity. Profit Factor = total winning returns / total losing returns ])
#align(center)[
#table(
  columns: (auto, auto, auto),
  [*Metric*], [*Training Set*], [*Test Set*],
  [Profit Factor], [$1.079$], [$1.651$],
  [PF $>$ 1 combinations], [$17 slash 25$], [$24 slash 25$],
)
]
The profit factor on the training set was 1.079, indicating some modest
but positive performance. More notably for me, the profit factor on the
test set was 1.651, substantially higher than training, which could suggest
the strategy generalizes strongly to unseen data rather than
over fitting, yet this interpretation should be viewed cautiously, as there is not enough training and testing data to meaningfully display long term profitability for the model. Regardless, the out-of-sample result is the more meaningful
metric, as it reflects performance on data the model had no access
to during parameter estimation.

== Robustness Analysis

I mentioned previously, the only variable selected by me was the input for _W_, so I must assess whether the results depend on a specific parameter
choice, so the strategy was evaluated across a grid of 25 combinations
spanning five window sizes for $W in {20, 30, 50, 75, 100}$ and five
quantile threshold pairs fir
$Q_"low" in {0.10, 0.15, 0.20, 0.25, 0.30}$,
$Q_"high" = 1 - Q_"low"$. The profit factor heatmap in
Figure 7 shows the result for each combination on both training
and test sets.
#figure(
image("heatmap.png"), caption: [Robustness Heatmap, window $W$ values controlling the quantile lookback
Quantile threshold pairs ($q_"low"$, $q_"high"$)],)


On the training set, 17 of 25 combinations or about 68% produce a profit
factor above 1. On the test set, 24 of 25 combinations or 96%
produce a profit factor above 1, with values ranging from 1.46 to
1.85 across nearly the entire grid. The single underperforming
cell ($W = 20$, $q = 0.10$) corresponds to the shortest window
and tightest threshold, and seems to be a configuration that generates very few
trades and highly sensitive to noise.

Its surprising the profitability on the test set across parameter
combinations is a strong result, we can extract that the Hawkes regime signal is capturing some structural feature of
GLD intraday volatility rather than an artifact of any single
parameter choice.

= Limitations

An intent to cross validate the bivariate Hawkes structure against the _HMM_ was done, which proved inconclusive, as two of the regime structures the _HMM_ displayed were indistinguishable from eachother. The sample period of 7 days proved to be narrow, while the rolling estimation simply depends on the number of candle data rather than the window itself, a larger sample would allow for a more through statistical reinforcement for estimating the coefficients.
The 1-minute bar frequency was the finest granularity freely available via the Yahoo Finance API. Tick level or second level data would align much better with the process, and would allow for a faster response on live markets. 


= Conclusion




This paper looks into whether a bivariate Hawkes process, applied
jointly to normalized candle range and volume, allows for a
way to identify volatility regimes in 
gold markets. Using GLD 1 minute data , all
parameters are estimated within a rolling parameter from the autocorrelation and structure of the data, requiring no inputs beyond the window
length $W$.
Both volatility and volume display self exiting behavior, with cross correlation excitation between volume and range, mutually reinforcing each other, with volume leading the feedback loop. The range intensity $lambda_t^r$
produced a binary regime signal that effectively identifies the beginning
of intraday price moves and their decay back to baseline.
A momentum exit strategy was built on this signal and achieves a profit
factor of 1.651 on the held out test set, with 24 of 25 parameter
combinations in the robustness grid producing profit factors above
1, this almost uniform profitability displays evidence that the Hawkes process is
capturing genuine market structure.

== Future Work
To me 
several natural extensions present themselves. I still want to consider a cross-validation
against an HMM, fitted on a higher-volatility instrument or a
much longer sample at finer resolution. Perhaps even adding to the bivariate model to include
additional mutually exciting series, such as the bid ask spread or
option put to call ratio imbalance, it would be interesting to test whether the mutual excitation
structure extends beyond volatility and volume. Most importantly, applying
the model to live markets and enabling _W_ itself to change dynamically depending on some signal, for example shrinking _W_ when $n_t$ is rising fast, since market is changing quickly, you need more local data, and expanding _W_ when $n_t $is stable, as market being calm allows to use longer history and reduce noise.
#pagebreak()
= References 
#bibliography("stochastic.bib")
#pagebreak()

= Appendix A 

The full implementation is available at:
#link("https://github.com/yourusername/hawkes-gld")

The repository contains the Jupyter notebook 
#text("hawkes_bivariate-5.ipynb") with all data, 
parameter estimation, model execution, strategy backtesting, 
and visualization code used to produce the results in this paper.


`====================================================
BIVARIATE HAWKES — FULL SUMMARY
====================================================
Data:          GLD 1-min (trading hours only)
Total bars:    2730
Train:         1910
Test:          820
W:             50 candles  |  L: 20 lags

--- Parameters ---
kappa_r:       0.8212
kappa_v:       1.0608
n_r:           0.3265
n_v:           0.3835
alpha_vr:      0.1530  (volume -> range)
alpha_rv:      0.1257  (range -> volume)

--- Strategy ---
PF train:      1.0791
PF test:       1.6511
PF>1 train:    17/25 parameter combinations
PF>1 test:     24/25 parameter combinations

--- Stability ---
n_r < 1:       True
n_v < 1:       True
====================================================`

== Stability

The stationary condition $n_t < 1$ holds on average for both
processes throughout both the training and test periods
($overline(n)_r = 0.327$, $overline(n)_v = 0.384$). Its trivial to
identify volatility clusters are self-limiting, they only amplify
briefly then decay back toward baseline $mu_t$ rather than growing
without some limit.

== Hidden markov model

A Hidden Markov Model (HMM) extends a standard Markov chain by
adding a layer of latent states, unlike a Markov chain where
the state at each step is directly observable, in an HMM the
underlying states are hidden and can only be inferred through a
sequence of observations emitted from each state's specific probability
distributions. Parameters are estimated via the Baum-Welch
algorithm and the most likely state sequence is recovered via the
Viterbi algorithm 
#cite(<rabiner1989>)#cite(<article>)

$
PP{Y_n = y | Z_0, dots, Z_n, Y_0, dots, Y_(n-1)} = PP{Y_n = y | Z_n}
$