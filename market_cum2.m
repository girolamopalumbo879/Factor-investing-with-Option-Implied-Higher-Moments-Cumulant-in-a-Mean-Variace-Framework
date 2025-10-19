clc; clear; close all;

%% STEP 0: Load and preprocess data
stockData = readtable('dataset2.xlsx');
dates_stock = stockData.Date;
prices = stockData{:, 2:end-2}; % stock prices
market = stockData{:, end-1};
rf = (stockData{:, end} / 100) / 252;

stockReturns = price2ret(prices);
marketReturns = price2ret(market);
rf = rf(2:end);  % align

excessStockReturns = stockReturns - rf;
excessMarketReturns = marketReturns - rf;
dates_returns = dates_stock(2:end);

%% STEP 1: Load cumulants
load('DatasetRiskNeutralCumulantsForGirolamo.mat');
if isdatetime(dates) == 0
    dates_cumulants = datetime(dates, 'ConvertFrom', 'datenum');
else
    dates_cumulants = dates;
end
dc2 = diff(c2);
dates_dc2 = dates_cumulants(2:end);

%% STEP 2: Align datasets
[common_dates, idx_returns, idx_c2] = intersect(dates_returns, dates_dc2);
aligned_stockReturns = excessStockReturns(idx_returns, :);
aligned_marketReturns = excessMarketReturns(idx_returns);
aligned_dc2 = dc2(idx_c2);

Nstocks = size(aligned_stockReturns, 2);
Nobs = length(common_dates);

%% STEP 3: Compute DIM covariance matrix via function
[cov_DIM, alphas, betas, gammas] = compute_cov_DIM(aligned_stockReturns, aligned_marketReturns, aligned_dc2);

%% STEP 4: Expected returns (orthogonalized model)
Rm_bar = mean(aligned_marketReturns);
dc2_bar = mean(aligned_dc2);  % note: orthogonalization is inside the function
mu_DIM = alphas + betas * Rm_bar + gammas * dc2_bar;
mu_DIM = mu_DIM * 252;

%% STEP 5: Efficient frontier
r_min = min(mu_DIM);
r_max = max(mu_DIM);
r_targets = linspace(r_min, r_max, 50);

Aeq = ones(1, Nstocks); beq = 1;
lb = zeros(Nstocks, 1);
options = optimoptions('quadprog', 'Display', 'off');

portfolio_vols = zeros(length(r_targets), 1);
portfolio_returns = zeros(length(r_targets), 1);
portfolio_weights = zeros(Nstocks, length(r_targets));

for k = 1:length(r_targets)
    r_target = r_targets(k);
    A = -mu_DIM';
    b = -r_target;

    [x_opt, ~, exitflag] = quadprog(cov_DIM, [], A, b, Aeq, beq, lb, [], [], options);

    if exitflag == 1
        portfolio_returns(k) = mu_DIM' * x_opt;
        portfolio_vols(k) = sqrt(x_opt' * cov_DIM * x_opt);
        portfolio_weights(:, k) = x_opt;
    else
        portfolio_returns(k) = NaN;
        portfolio_vols(k) = NaN;
    end
end

%% STEP 6: Plot Efficient Frontier
figure;
plot(portfolio_vols, portfolio_returns, 'LineWidth', 2, 'Color', 'r');
xlabel('Volatility (σ)');
ylabel('Expected Excess Return (Annualized)');
grid on;

%% STEP 6: Find the Tangency (Maximum Sharpe Ratio) Portfolio

rf_annual = mean(rf) * 252; % Annualized risk-free rate
excess_mu = mu_DIM - rf_annual; % Excess expected return over risk-free

% Solve the tangency portfolio: maximize Sharpe ratio
% equivalent to: minimize - (w'*(mu - rf)) / sqrt(w'*Cov*w)
Aeq = ones(1, Nstocks); beq = 1;
lb = zeros(Nstocks, 1);

% Optimization setup
sharpe_fun = @(w) -((w' * excess_mu) / sqrt(w' * cov_DIM * w));
options = optimoptions('fmincon','Display','off','Algorithm','sqp');
w_tangency = fmincon(sharpe_fun, ones(Nstocks,1)/Nstocks, [], [], Aeq, beq, lb, [], [], options);

% Compute tangency portfolio metrics
ret_tangency = mu_DIM' * w_tangency;
vol_tangency = sqrt(w_tangency' * cov_DIM * w_tangency);
SR_tangency  = (ret_tangency - rf_annual) / vol_tangency;

fprintf("\nTangency Portfolio (Max Sharpe):\n");
fprintf("Expected Return (annualized): %.4f\n", ret_tangency);
fprintf("Volatility (annualized): %.4f\n", vol_tangency);
fprintf("Sharpe Ratio: %.4f\n", SR_tangency);

% Add to the efficient frontier plot
hold on;
scatter(vol_tangency, ret_tangency, 80, 'r', 'filled');
text(vol_tangency, ret_tangency, '  Max SR Portfolio', 'Color','r', 'FontWeight','bold');
