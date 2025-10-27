clc; clear; close all;

%% STEP 0: Load and preprocess data
stockData = readtable('dataset2.xlsx');
dates_stock = stockData.Date;
prices = stockData{:, 2:end-2}; % stock prices
market = stockData{:, end-1};
rf = (stockData{:, end} / 100) / 252;

stockReturns = price2ret(prices);
marketReturns = price2ret(market);
rf = rf(2:end);  % align with returns

excessStockReturns = stockReturns - rf;
excessMarketReturns = marketReturns - rf;
dates_returns = dates_stock(2:end);

%% STEP 1: Load only dc3 (risk-neutral skewness)
load('DatasetRiskNeutralCumulants.mat');
if ~isdatetime(dates)
    dates_cumulants = datetime(dates, 'ConvertFrom', 'datenum');
else
    dates_cumulants = dates;
end
dc3 = diff(c3);
dates_cumulants = dates_cumulants(2:end);

%% STEP 2: Align data
[common_dates, idx_r, idx_c] = intersect(dates_returns, dates_cumulants);
aligned_stockReturns = excessStockReturns(idx_r, :);
aligned_marketReturns = excessMarketReturns(idx_r);
aligned_dc3 = dc3(idx_c);

Nstocks = size(aligned_stockReturns, 2);
Nobs = length(common_dates);

%% STEP 3: Compute covariance matrix via function
[cov_MSK, alphas, betas, deltas] = compute_cov_MSK(aligned_stockReturns, aligned_marketReturns, aligned_dc3);

%% STEP 4:Expected returns (orthogonalized model)
Rm_bar   = mean(aligned_marketReturns);   % daily market return mean
dc3_bar  = mean(aligned_dc3);             % daily mean of dc3
mu_model = alphas + betas * Rm_bar + deltas * dc3_bar;
mu_model = mu_model * 252;  % annualized

%% STEP 5: Efficient Frontier
r_min = min(mu_model);
r_max = max(mu_model);
r_targets = linspace(r_min, r_max, 50);

Aeq = ones(1, Nstocks); beq = 1;
lb = zeros(Nstocks, 1);
options = optimoptions('quadprog', 'Display', 'off');

portfolio_vols = zeros(length(r_targets), 1);
portfolio_returns = zeros(length(r_targets), 1);
portfolio_weights = zeros(Nstocks, length(r_targets));

for k = 1:length(r_targets)
    r_target = r_targets(k);
    A = -mu_model';
    b = -r_target;

    [x_opt, ~, exitflag] = quadprog(cov_MSK, [], A, b, Aeq, beq, lb, [], [], options);

    if exitflag == 1
        portfolio_returns(k) = mu_model' * x_opt;
        portfolio_vols(k) = sqrt(x_opt' * cov_MSK * x_opt);
        portfolio_weights(:, k) = x_opt;
    else
        portfolio_returns(k) = NaN;
        portfolio_vols(k) = NaN;
    end
end

%% STEP 6: Plot Efficient Frontier
figure;
plot(portfolio_vols, portfolio_returns, 'LineWidth', 2, 'Color', 'm');
xlabel('Volatility (σ)');
ylabel('Expected Excess Return (Annualized)');
title('Efficient Frontier - Market + Skewness (Orthogonalized)');
grid on;

%% STEP 6: Find the Tangency (Maximum Sharpe Ratio) Portfolio

rf_annual = mean(rf) * 252; % Annualized risk-free rate
excess_mu = mu_model - rf_annual; % Excess expected return over risk-free

% Solve the tangency portfolio: maximize Sharpe ratio
% equivalent to: minimize - (w'*(mu - rf)) / sqrt(w'*Cov*w)
Aeq = ones(1, Nstocks); beq = 1;
lb = zeros(Nstocks, 1);

% Optimization setup
sharpe_fun = @(w) -((w' * excess_mu) / sqrt(w' * cov_MSK * w));
options = optimoptions('fmincon','Display','off','Algorithm','sqp');
w_tangency = fmincon(sharpe_fun, ones(Nstocks,1)/Nstocks, [], [], Aeq, beq, lb, [], [], options);

% Compute tangency portfolio metrics
ret_tangency = mu_model' * w_tangency;
vol_tangency = sqrt(w_tangency' * cov_MSK * w_tangency);
SR_tangency  = (ret_tangency - rf_annual) / vol_tangency;

fprintf("\nTangency Portfolio (Max Sharpe):\n");
fprintf("Expected Return (annualized): %.4f\n", ret_tangency);
fprintf("Volatility (annualized): %.4f\n", vol_tangency);
fprintf("Sharpe Ratio: %.4f\n", SR_tangency);

% Add to the efficient frontier plot
hold on;
scatter(vol_tangency, ret_tangency, 80, 'r', 'filled');
text(vol_tangency, ret_tangency, '  Max SR Portfolio', 'Color','r', 'FontWeight','bold');
