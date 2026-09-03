%% New secant attempt
%
% Method:
%   1. Grid of left pins  lambda_L  in [0.60, 1.0]
%   2. For each lambda_L, grid of right endpoints lambda_R > lambda_L
%   3. Secant slope = (W(lambda_R) - W(lambda_L)) / (lambda_R - lambda_L)
%   4. Tangent slope = dW/dlambda at lambda_R
%   5. gap(lambda_L, lambda_R) = |secant_slope - tangent_slope|
%   6. Find (lambda_L*, lambda_R*) = argmin gap
%      => the secant line between those two points is tangent to the curve
%
clear all; close all; clc;

fprintf('=== 2D Secant Scan for Tangent on Lower Hump ===\n\n');

%% Load original curve

lambda_grid = 0.005:0.001:0.999;
n_pts       = length(lambda_grid);
dl          = mean(diff(lambda_grid));

W_orig   = zeros(n_pts,1);
q_L_orig = zeros(n_pts,1);

for i = 1:n_pts
    [~, q_L, V_H, ~, profit, tH0, tL0] = get_screening_solution(lambda_grid(i));
    q_L_orig(i) = q_L;
    W_orig(i)   = (1 - lambda_grid(i)) * (V_H + profit);
end
dW_orig = gradient(W_orig, dl);
fprintf('theta_H=%.1f, theta_L=%.1f\n\n', tH0, tL0);

% Kink location (for ref)
i_kink   = find(q_L_orig > 0.01*max(q_L_orig), 1, 'first');
lam_kink = lambda_grid(i_kink);
fprintf('Kink at lambda = %.4f\n\n', lam_kink);

%%  Define left-pin and right-endpoint grids

lam_L_grid = 0.60 : 0.005 : 0.99;    % left pin: variable in [0.60, 1.0]
lam_R_grid = 0.60 : 0.005 : 0.99;    % right endpoints

n_L = length(lam_L_grid);
n_R = length(lam_R_grid);

% Pre-interpolate W and dW onto both grids
W_L  = interp1(lambda_grid, W_orig,  lam_L_grid, 'linear');
W_R  = interp1(lambda_grid, W_orig,  lam_R_grid, 'linear');
dW_R = interp1(lambda_grid, dW_orig, lam_R_grid, 'linear');

%% %  Compute gap matrix gap(i,j) = |secant_slope - tangent_slope at R|
%  Only valid for lambda_R > lambda_L
gap_mat = nan(n_L, n_R);

for i = 1:n_L
    for j = 1:n_R
        if lam_R_grid(j) <= lam_L_grid(i) + 0.01
            continue    % require lambda_R strictly > lambda_L
        end
        sec_slope  = (W_R(j) - W_L(i)) / (lam_R_grid(j) - lam_L_grid(i));
        gap_mat(i,j) = abs(sec_slope - dW_R(j));
    end
end

%%  Find global minimum of gap (best tangent)


[min_gap, lin_idx] = min(gap_mat(:));
[i_best, j_best]   = ind2sub([n_L, n_R], lin_idx);

lam_L_best = lam_L_grid(i_best);
lam_R_best = lam_R_grid(j_best);
W_L_best   = W_L(i_best);
W_R_best   = W_R(j_best);
sl_best    = (W_R_best - W_L_best) / (lam_R_best - lam_L_best);

fprintf('Best tangent:\n');
fprintf('  Left pin:      lambda_L = %.4f,  W = %.4f\n', lam_L_best, W_L_best);
fprintf('  Right point:   lambda_R = %.4f,  W = %.4f\n', lam_R_best, W_R_best);
fprintf('  Secant slope:  %.4f\n', sl_best);
fprintf('  dW at R:       %.4f\n', dW_R(j_best));
fprintf('  |gap|:         %.6f\n\n', min_gap);

% Also find top-5 distinct solutions
fprintf('Top 5 distinct tangent candidates:\n');
fprintf('  lambda_L   lambda_R   slope    |gap|\n');
fprintf('  --------   --------   -----    -----\n');
gap_copy = gap_mat;
for k = 1:5
    [gk, lk] = min(gap_copy(:));
    if isnan(gk), break; end
    [ik, jk] = ind2sub([n_L,n_R], lk);
    fprintf('  %.4f     %.4f     %+.3f   %.5f\n', ...
            lam_L_grid(ik), lam_R_grid(jk), ...
            (W_R(jk)-W_L(ik))/(lam_R_grid(jk)-lam_L_grid(ik)), gk);
    i_lo = max(1,ik-3); i_hi = min(n_L,ik+3);
    j_lo = max(1,jk-3); j_hi = min(n_R,jk+3);
    gap_copy(i_lo:i_hi, j_lo:j_hi) = nan;
end

%% FIGURE 1: curve + tangent line
figure('Position',[80,80,720,520]); hold on;
title({'Randian Welfare: Secant Tangent on Lower Hump', ...
       sprintf('\\lambda_L=%.3f  \\rightarrow  \\lambda_R^*=%.3f  (slope=%.3f)', ...
               lam_L_best, lam_R_best, sl_best)}, ...
      'FontSize',12,'FontWeight','bold');

% Full curve
plot(lambda_grid, W_orig, 'b-', 'LineWidth', 4, 'DisplayName', ...
     sprintf('W_{Rand} (\\theta_H=%.0f, \\theta_L=%.0f)', tH0, tL0));

% Tangent line: extend from lambda_L through lambda_R and a bit beyond
lam_tline = (lam_L_best-0.02) : 0.001 : min(lam_R_best+0.05, 0.999);
W_tline   = W_L_best + sl_best * (lam_tline - lam_L_best);
valid     = W_tline >= 0;
plot(lam_tline(valid), W_tline(valid), 'r-', 'LineWidth', 3, ...
     'DisplayName', 'Tangent line');

% Mark endpoints
scatter(lam_L_best, W_L_best, 200, 'k', 'filled', 'DisplayName', ...
        sprintf('Left pin  \\lambda_L=%.3f', lam_L_best));
scatter(lam_R_best, W_R_best, 200, 'r', 'filled', 'DisplayName', ...
        sprintf('Tangent pt \\lambda_R^*=%.3f', lam_R_best));

xline(lam_kink, 'k--', 'LineWidth',1.5, 'DisplayName', ...
      sprintf('\\lambda_{kink}=%.3f',lam_kink));
yline(0,'k-','LineWidth',0.8,'HandleVisibility','off');
xlabel('\lambda  (share of low types)','FontSize',12);
ylabel('W_{Rand} = (1-\lambda)(V_H + UBI)','FontSize',12);
legend('Location','northeast','FontSize',10);
xlim([0,1]); ylim([0, max(W_orig)*1.05]); grid on;

%% Helper
function [q_H, q_L, V_H, V_L, profit, theta_H, theta_L] = get_screening_solution(lambda)
    [q_H, q_L, ~, ~, V_H, V_L, profit, theta_H, theta_L] = screening_problem(lambda);
end