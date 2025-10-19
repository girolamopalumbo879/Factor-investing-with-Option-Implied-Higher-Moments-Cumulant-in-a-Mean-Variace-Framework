# Factor-investing-with-Option-Implied-Higher-Moments-Cumulant-in-a-Mean-Variace-Framework
MATLAB implementation of mean–variance portfolio optimization models using market and option-implied higher-moment cumulants (variance, skewness, kurtosis).

# Single Index Model (SIM)
File: SIM.m
Single Index Model (Baseline Reference)
This script implements the Single Index Model (SIM), the baseline framework of the empirical analysis. It estimates expected returns using market exposure (β) to the S&P 500, computes the efficient frontier, and identifies the tangency portfolio (the portfolio with the maximum Sharpe Ratio). All subsequent models build upon this structure by adding option-implied cumulant factors.
