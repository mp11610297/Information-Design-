function [q_H_star, q_L_star, p_H_star, p_L_star, U_H, U_L, total_profit, theta_H, theta_L] = screening_problem(lambda)
% need to run it with a lambda 
% SCREENING_PROBLEM Solves monopolistic screening with quadratic cost
%
% Cost function: c(q) = (1/2)*q^2, so MC = q
% Consumer utility: U(q,p) = theta*q - p
%
% Input:
%   lambda - Share of Low types (with high type derived from this)
%
% Outputs:
%   q_H_star, q_L_star - Optimal quantities
%   p_H_star, p_L_star - Optimal prices
%   U_H, U_L - Consumer utilities
%   total_profit - Monopolist's total profit
%   theta_H, theta_L - Type valuations (returned for reference)

%% Parameters
theta_H = 10;     % High type valuation
theta_L = 3;      % Low type valuation

%% Analytical Solution

% Consumer utility: U(q, p) = theta*q - p
% Producer cost: c(q) = (1/2)*q^2
% Producer profit per unit: p - c(q) = p - (1/2)*q^2

% Binding constraints:
% - Low type IR binds: U_L(q_L, p_L) = 0
%   => theta_L * q_L - p_L = 0
%   => p_L = theta_L * q_L
% - High type IC binds: U_H(q_H, p_H) = U_H(q_L, p_L)  
%   => theta_H * q_H - p_H = theta_H * q_L - p_L

% Monopolist problem:
% max_{q_H, q_L, p_H, p_L} (1-lambda)[p_H - (1/2)q_H^2] + lambda[p_L - (1/2)q_L^2]
% s.t. Low IR: p_L = theta_L * q_L
%      High IC: p_H = theta_H * q_H - (theta_H - theta_L) * q_L

% Substituting constraints into objective:
% max_{q_H, q_L} (1-lambda)[theta_H*q_H - (theta_H-theta_L)*q_L - (1/2)q_H^2] 
%                + lambda[theta_L*q_L - (1/2)q_L^2]

% FOCs:
% dProfit/dq_H = (1-lambda)[theta_H - q_H] = 0  =>  q_H = theta_H
% dProfit/dq_L = -(1-lambda)(theta_H - theta_L) + lambda[theta_L - q_L] = 0
%   => lambda*theta_L - lambda*q_L - (1-lambda)(theta_H - theta_L) = 0
%   => q_L = theta_L - [(1-lambda)/lambda]*(theta_H - theta_L)

q_H_star = theta_H;
q_L_star = theta_L - ((1-lambda)/lambda)*(theta_H - theta_L);
q_L_star = max(0, q_L_star);  

% Prices from binding constraints
p_L_star = theta_L * q_L_star;
p_H_star = theta_H * q_H_star - (theta_H - theta_L) * q_L_star;

% Utilities
U_H = theta_H * q_H_star - p_H_star;  % Information rent
U_L = theta_L * q_L_star - p_L_star;  % Check- should be 0 

% Profits
profit_H = (1-lambda) * (p_H_star - 0.5 * q_H_star^2);
profit_L = lambda * (p_L_star - 0.5 * q_L_star^2);
total_profit = profit_H + profit_L;

end