# Factor-investing-with-Option-Implied-Higher-Moments-Cumulant-in-a-Mean-Variace-Framework
MATLAB implementation of mean–variance portfolio optimization models using market and option-implied higher-moment cumulants (variance, skewness, kurtosis).
Single Index Model (Baseline Reference)
This script implements the Single Index Model (SIM), the baseline framework of the empirical analysis. It estimates expected returns using market exposure (β) to the S&P 500, computes the efficient frontier, and identifies the tangency portfolio (the portfolio with the maximum Sharpe Ratio). All subsequent models build upon this structure by adding option-implied cumulant factors.
clc; clear; close all;

%% STEP 0: Load and preprocess data
data = readtable('dataset2.xlsx');
dates = data.Date;
prices = data(:, 2:end-2);  % exclude date, market, rf
market = data{:, end-1};
rf = (data{:, end} / 100) / 252;  % convert to daily rate

% Daily returns
priceMatrix = table2array(prices);
stockReturns = price2ret(priceMatrix);
marketReturns = price2ret(market);
rf = rf(2:end);  % align

% Excess returns
excessStockReturns = stockReturns - rf;
excessMarketReturns = marketReturns - rf;
[Nobs, Nstocks] = size(excessStockReturns);

%% STEP 1: Historical mean and covariance
mu_historical = mean(excessStockReturns) * 252;
cov_hist = compute_cov_historical(excessStockReturns);

%% STEP 2: SIM Covariance Matrix
[cov_SIM, alphas, betas] = compute_cov_SIM(excessStockReturns, excessMarketReturns);

%% STEP 3: Expected returns via SIM (annualized)
Rm_bar = mean(excessMarketReturns);        % mean of market excess return
mu_SIM = alphas + betas * Rm_bar;          % expected excess return
mu_SIM = mu_SIM * 252;                     % annualize

%% STEP 4: Efficient Frontier Optimization
r_min = min(mu_SIM);
r_max = max(mu_SIM);
r_targets = linspace(r_min, r_max, 50);

P = cov_SIM;
Aeq = ones(1, Nstocks); beq = 1;
lb = zeros(Nstocks, 1);
options = optimoptions('quadprog','Display','off');

portfolio_vols = zeros(length(r_targets),1);
portfolio_returns = zeros(length(r_targets),1);
portfolio_weights = zeros(Nstocks, length(r_targets));

for k = 1:length(r_targets)
    r_target = r_targets(k);
    A = -mu_SIM'; b = -r_target;

    [x_opt, ~, exitflag] = quadprog(P, [], A, b, Aeq, beq, lb, [], [], options);

    if exitflag == 1
        portfolio_returns(k) = mu_SIM' * x_opt;
        portfolio_vols(k) = sqrt(x_opt' * P * x_opt);
        portfolio_weights(:,k) = x_opt;
    else
        portfolio_returns(k) = NaN;
        portfolio_vols(k) = NaN;
    end
end

%% STEP 5: Plot Efficient Frontier
figure;
plot(portfolio_vols, portfolio_returns, 'b-', 'LineWidth', 2);
xlabel('Volatility (σ)');
ylabel('Expected Excess Return (Annualized)');
grid on;

%% STEP 6: Find the Tangency (Maximum Sharpe Ratio) Portfolio

rf_annual = mean(rf) * 252; % Annualized risk-free rate
excess_mu = mu_SIM - rf_annual; % Excess expected return over risk-free

% Solve the tangency portfolio: maximize Sharpe ratio
% equivalent to: minimize - (w'*(mu - rf)) / sqrt(w'*Cov*w)
Aeq = ones(1, Nstocks); beq = 1;
lb = zeros(Nstocks, 1);

% Optimization setup
sharpe_fun = @(w) -((w' * excess_mu) / sqrt(w' * cov_SIM * w));
options = optimoptions('fmincon','Display','off','Algorithm','sqp');
w_tangency = fmincon(sharpe_fun, ones(Nstocks,1)/Nstocks, [], [], Aeq, beq, lb, [], [], options);

% Compute tangency portfolio metrics
ret_tangency = mu_SIM' * w_tangency;
vol_tangency = sqrt(w_tangency' * cov_SIM * w_tangency);
SR_tangency  = (ret_tangency - rf_annual) / vol_tangency;

fprintf("\nTangency Portfolio (Max Sharpe):\n");
fprintf("Expected Return (annualized): %.4f\n", ret_tangency);
fprintf("Volatility (annualized): %.4f\n", vol_tangency);
fprintf("Sharpe Ratio: %.4f\n", SR_tangency);

% Add to the efficient frontier plot
hold on;
scatter(vol_tangency, ret_tangency, 80, 'r', 'filled');
text(vol_tangency, ret_tangency, '  Max SR Portfolio', 'Color','r', 'FontWeight','bold');
