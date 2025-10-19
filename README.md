# Factor-investing-with-Option-Implied-Higher-Moments-Cumulant-in-a-Mean-Variace-Framework
MATLAB implementation of mean–variance portfolio optimization models using market and option-implied higher-moment cumulants (variance, skewness, kurtosis).

# Single Index Model (SIM)
File: SIM.m

This script implements the Single Index Model (SIM), the baseline framework of the empirical analysis. It estimates expected returns using market exposure (β) to the S&P 500, computes the efficient frontier, and identifies the tangency portfolio (the portfolio with the maximum Sharpe Ratio). All subsequent models build upon this structure by adding option-implied cumulant factors.

# Double Index Model (DIM)
File: market_cum2.m

Extends the SIM by introducing a second factor — the change in the second cumulant (d(c,2)), which captures variance innovations derived from option-implied information. The file computes the efficient frontier and tangency portfolio for the Double Index Model (DIM), showing whether variance risk contains additional forward-looking information beyond market exposure.
