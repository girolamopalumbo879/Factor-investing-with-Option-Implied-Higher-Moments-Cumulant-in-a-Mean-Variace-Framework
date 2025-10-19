# Factor-investing-with-Option-Implied-Higher-Moments-Cumulant-in-a-Mean-Variace-Framework
MATLAB implementation of mean–variance portfolio optimization models using market and option-implied higher-moment cumulants (variance, skewness, kurtosis).

# Single Index Model (SIM)
File: SIM.m

This script implements the Single Index Model (SIM), the baseline framework of the empirical analysis. It estimates expected returns using market exposure (β) to the S&P 500, computes the efficient frontier, and identifies the tangency portfolio (the portfolio with the maximum Sharpe Ratio). All subsequent models build upon this structure by adding option-implied cumulant factors.

# Double Index Model (DIM)
File: market_cum2.m

Extends the SIM by introducing a second factor — the change in the second cumulant (d(c,2)), which captures variance innovations derived from option-implied information. The file computes the efficient frontier and tangency portfolio for the Double Index Model (DIM), showing whether variance risk contains additional forward-looking information beyond market exposure.

# Market–Skewness Model (MSK)
File: market_cum3.m

Implements the Market–Skewness (MSK) model, where the third cumulant (d(c,3)) measures innovations in implied skewness — the asymmetry in the return distribution. This model examines whether sensitivity to changes in risk-neutral skewness improves portfolio efficiency or downside risk protection. As before, the script includes the efficient frontier and tangency portfolio.

# Market–Kurtosis Model
File: market_cum4.m

Implements the Market–Kurtosis (MK) model, which adds the fourth cumulant (d(c,4)) — capturing tail thickness or extreme event risk — as a second factor alongside the market. The file estimates expected returns, the covariance matrix, and the efficient frontier with the tangency portfolio, analyzing whether accounting for tail risk yields better performance.

# Covariance Estimation Functions
Files:

	•	compute_cov_SIM.m
	•	compute_cov_DIM.m
	•	compute_cov_MSK.m
	•	compute_cov_MK.m

These function files compute the variance–covariance matrices for each corresponding model.
Each function applies the relevant regression-based factor structure:

	•	SIM: market only
	•	DIM: market + variance
	•	MSK: market + skewness
	•	MK: market + kurtosis

They are called internally by the main scripts above to generate model-specific covariance estimations used in the portfolio optimization process.

# Option-Implied Cumulants: Time-Series Visualization
File: time_series_plots.m

Generates the time-series plots of the option-implied cumulant innovations — variance (d(c,2)), skewness (d(c,3)), and kurtosis (d(c,4)).
These plots provide intuition on how risk-neutral moments evolve over time and respond to major market events such as the Global Financial Crisis (2008–2009) or the COVID-19 crash (2020). They serve as a visual foundation for understanding the forward-looking information embedded in option prices.
