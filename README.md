# Hawkes process on gold
Undergraduate paper for Math 467 at the University of Oregon. Im applying a bivariate Hawkes process to 1-minute gold data to model intraday volatility clustering,  using normalized candle size and trading volume as mutually exciting  processes.

## Process

- Pulls 1-minute GLD data via yfinance 
- Estimates the Hawkes decay rate kappa from the rolling ACF of each series
- Runs a bivariate recurrence tracking range and volume intensities
- Detects high/low volatility regimes using rolling quantile thresholds
- Runs momentum exit strategy and robustness grid 
- Attempts HMM cross-validation
- 
## Results

The model finds stationary self-exciting behavior in both range and 
volume (n_r = 0.33, n_v = 0.38), positive cross-excitation in both 
directions (alpha_vr = 0.153, alpha_rv = 0.126), and a momentum exit 
strategy that achieves a profit factor of 1.65 on the held-out test 
set with 24/25 parameter combinations profitable.

## Setup

Python 3.9 or higher

Install dependencies:

pip install numpy pandas matplotlib scipy yfinance hmmlearn seaborn pytz

Or all at once:

pip install -r requirements.txt


## File structure

hawkes_bivariate.ipynb    main notebook with all model code and plots
references.bib            bibliography for the paper
paper.typ                 Typst source for the full paper

## Requirements

numpy
pandas
matplotlib
scipy
yfinance
hmmlearn
seaborn
pytz

## Notes

yfinance only provides 1-minute data for the last 7 calendar days 
so the dataset will be different each time you run it. If you want 
to reproduce the exact results from the paper, exceuted from data on june 6th 2026, you can save the raw 
dataframe to a CSV after the download cell and reload from that 
instead of pulling live data.

## References
Full bibliography in references.bib.
