# Factor-investing-with-Option-Implied-Higher-Moments-Cumulant-in-a-Mean-Variace-Framework
This repository contains the MATLAB implementation of a mean–variance portfolio optimization framework that integrates market-based and option-implied higher-moment information. The analysis explores whether incorporating forward-looking measures of variance, skewness, and kurtosis (derived from option prices) improves portfolio efficiency relative to traditional approaches.

The project builds progressively from the Single Index Model (SIM)—which captures stock return co-movements through exposure to the market factor—to more advanced factor-based specifications:
	•	DIM (Double Index Model): adds the variance innovation factor (option-implied variance).
	•	MSK (Market Skewness Model): introduces skewness innovation.
	•	MK (Market Kurtosis Model): incorporates kurtosis innovation.

Each model generates its own efficient frontier, tangency (maximum Sharpe) portfolio, and backtest performance through rolling-window simulations. The code also computes a comprehensive set of performance metrics (Sharpe ratio, Calmar ratio, Jensen’s alpha, Treynor ratio, Omega ratio) and visualizes cumulative returns and rolling Sharpe ratios over time.

The repository accompanies the empirical analysis presented in the author’s Master’s Thesis, “Factor Investing in a Mean–Variance Framework: Do Higher-Moment Factors Improve Portfolio Performance?” The work investigates how forward-looking option-implied cumulants behave across different market regimes and whether they enhance portfolio resilience during crises such as the 2008–2009 Global Financial Crisis and the COVID-19 turmoil in 2020.

The dataset includes daily prices for 360 S&P 500 stocks, the S&P 500 index, and the U.S. 10-Year Treasury yield as the risk-free rate, sourced from S&P Capital IQ.

# Dataset Description
File: dataset2.xlsx

The file dataset2.xlsx contains the input data used for the empirical analysis and backtesting of the Single-Index and higher-moment factor models developed in the thesis. The dataset includes daily prices for a panel of individual U.S. stocks, the S&P 500 market index, and the U.S. 10-Year Treasury Constant Maturity yield, which serves as the risk-free rate proxy.

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

# Comprehensive Backtest and Comparison
File: backtest_all_models.m

Runs a complete rolling-window backtest for all models (HIST, SIM, DIM, MSK, MK).
It generates cumulative return plots, rolling Sharpe ratio graphs, and summary tables comparing:

	•	Mean and volatility of returns
	•	Maximum drawdown
	•	Tail-sensitive metrics (CVaR, Omega, Modified Sharpe)
	
This script represents the core empirical comparison discussed in Chapter 4 of the thesis and summarizes the overall findings.

# Downside Risk Analysis
File: Maximum_drawdown.m

Computes and plots the maximum drawdown profiles of the portfolios across rolling periods. This metric quantifies the largest peak-to-trough loss, capturing the extent of downside exposure. The file allows visual comparison across models, showing how factor-based strategies (especially MSK and MK) mitigate extreme losses.

# Rolling Performance Evaluation
File: Rolling_window_12_24_SR_performance_metrics.m

Calculates rolling 12-month and 24-month Sharpe ratios to track how risk-adjusted performance evolves through time.
Also includes computation of extended performance metrics:

	•	Calmar Ratio (return/drawdown)
	•	Jensen’s Alpha (alpha over CAPM benchmark)
	•	Treynor Ratio (return per unit of systematic risk)
	•	Omega Ratio (probability-weighted gains vs. losses)
	
The results highlight how each model adapts during market crises and stable phases.
