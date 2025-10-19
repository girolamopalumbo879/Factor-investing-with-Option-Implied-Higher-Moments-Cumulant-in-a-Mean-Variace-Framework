clc; clear; close all;

%% STEP 0: Load and preprocess data
stockData = readtable('dataset2.xlsx');
dates_stock = stockData.Date;
prices = stockData{:, 2:end-2};
market = stockData{:, end-1};
rf = (stockData{:, end} / 100) / 252;

stockReturns = price2ret(prices);
marketReturns = price2ret(market);
rf = rf(2:end);

excessStockReturns = stockReturns - rf;
excessMarketReturns = marketReturns - rf;
dates_returns = dates_stock(2:end);

%% STEP 1: Load cumulants (dc2 = variance, dc3 = skewness, dc4 = kurtosis)
load('DatasetRiskNeutralCumulantsForGirolamo.mat');
if ~isdatetime(dates)
    dates_cumulants = datetime(dates, 'ConvertFrom', 'datenum');
else
    dates_cumulants = dates;
end

dc2 = diff(c2);  % variance
dc3 = diff(c3);  % skewness
dc4 = diff(c4);  % kurtosis
dates_cumulants = dates_cumulants(2:end);

%% STEP 2: Align data
[common_dates, idx_r, idx_c] = intersect(dates_returns, dates_cumulants);
aligned_stockReturns = excessStockReturns(idx_r, :);
aligned_marketReturns = excessMarketReturns(idx_r);
aligned_dc2 = dc2(idx_c);
aligned_dc3 = dc3(idx_c);
aligned_dc4 = dc4(idx_c);

[Nobs, Nstocks] = size(aligned_stockReturns);

%% STEP 3: Rolling backtest settings
window_length = 126;
step_size = 21;
nSteps = floor((Nobs - window_length) / step_size);

returns_HIST = zeros(nSteps, 1);
returns_SIM  = zeros(nSteps, 1);
returns_DIM  = zeros(nSteps, 1);
returns_MSK   = zeros(nSteps, 1);
returns_MK   = zeros(nSteps, 1);

for t = 1:nSteps
    idx_train = (1:window_length) + (t-1)*step_size;
    idx_test  = window_length + (t-1)*step_size + (1:step_size);

    R  = aligned_stockReturns(idx_train, :);
    Rm = aligned_marketReturns(idx_train);
    dC2 = aligned_dc2(idx_train);
    dC3 = aligned_dc3(idx_train);
    dC4 = aligned_dc4(idx_train);
    R_test = aligned_stockReturns(idx_test, :);

    %% HIST
    mu_HIST = mean(R) * 252;
    cov_HIST = cov(R) * 252;

    %% SIM
    [cov_SIM, a_sim, b_sim] = compute_cov_SIM(R, Rm);
    mu_SIM = a_sim + b_sim * mean(Rm);
    mu_SIM = mu_SIM * 252;

    %% DIM
    [cov_DIM, a_dim, b_dim, g_dim] = compute_cov_DIM(R, Rm, dC2);
    mu_DIM = a_dim + b_dim * mean(Rm) + g_dim * mean(dC2);
    mu_DIM = mu_DIM * 252;

    %% MSK
    [cov_MSK, a_sk, b_sk, d_sk] = compute_cov_MSK(R, Rm, dC3);
    mu_MSK = a_sk + b_sk * mean(Rm) + d_sk * mean(dC3);
    mu_MSK = mu_MSK * 252;

    %% MK
    [cov_MK, a_mk, b_mk, th_mk] = compute_cov_MK(R, Rm, dC4);
    mu_MK = a_mk + b_mk * mean(Rm) + th_mk * mean(dC4);
    mu_MK = mu_MK * 252;

    %% Optimization setup
    Aeq = ones(1, Nstocks); beq = 1;
    lb = zeros(Nstocks,1); ub = ones(Nstocks,1);
    options = optimoptions('quadprog','Display','off');

    % HIST
    x_H = quadprog(2*cov_HIST, [], [], [], Aeq, beq, lb, ub, [], options);
    returns_HIST(t) = sum(R_test * x_H);

    % SIM
    x_S = quadprog(2*cov_SIM, [], [], [], Aeq, beq, lb, ub, [], options);
    returns_SIM(t) = sum(R_test * x_S);

    % DIM
    x_D = quadprog(2*cov_DIM, [], [], [], Aeq, beq, lb, ub, [], options);
    returns_DIM(t) = sum(R_test * x_D);

    % SK
    x_SK = quadprog(2*cov_MSK, [], [], [], Aeq, beq, lb, ub, [], options);
    returns_MSK(t) = sum(R_test * x_SK);

    % MK
    x_MK = quadprog(2*cov_MK, [], [], [], Aeq, beq, lb, ub, [], options);
    returns_MK(t) = sum(R_test * x_MK);
end

%% STEP 4: Cumulative returns with calendar dates
cum_HIST = ret2price(returns_HIST); cum_HIST = cum_HIST(2:end);
cum_SIM  = ret2price(returns_SIM);  cum_SIM  = cum_SIM(2:end);
cum_DIM  = ret2price(returns_DIM);  cum_DIM  = cum_DIM(2:end);
cum_MSK  = ret2price(returns_MSK);  cum_MSK  = cum_MSK(2:end);
cum_MK   = ret2price(returns_MK);   cum_MK   = cum_MK(2:end);

% Build a timeline for rolling windows: pick the last date of each test window
roll_dates = common_dates(window_length + (0:(nSteps-1))*step_size + step_size);

figure;
plot(roll_dates, cum_HIST, 'k-', 'LineWidth', 2); hold on;  
plot(roll_dates, cum_SIM,  'b--', 'LineWidth', 2);           
plot(roll_dates, cum_DIM,  'r-.', 'LineWidth', 2);           
plot(roll_dates, cum_MSK,  'g-', 'LineWidth', 2);     
plot(roll_dates, cum_MK,  'm:', 'LineWidth', 2);
legend('HIST', 'SIM', 'DIM', 'MSK', 'Location', 'northwest');
xlabel('Date');
ylabel('Cumulative Return');
title('Backtest Comparison: HIST vs SIM vs DIM vs MSK vs MK');
grid on;
