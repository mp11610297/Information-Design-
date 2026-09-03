%% Welfare Alpha Eval 
%  
%
% Welfare Model (alpha-weighted):
%   1. Randian:      W = (1-lambda) * (1-alpha) * (V_H + UBI)
%   2. Utilitarian:  W = lambda*alpha*(V_L + UBI) + (1-lambda)*(1-alpha)*(V_H + UBI)
%   3. Rawlsian:     W = lambda * alpha * (V_L + UBI)
%
%  alpha = 1   full weight on L-types  
%  alpha = 0   full weight on H-types 
%  alpha = 1/2 neutral weighting
%
clear all; close all; clc;

fprintf('Welfare Evaluation: Tax Problem (with Alpha Weighting)');

%% Parameters
lambda_grid  = 0.05:0.05:0.95;
n_points     = length(lambda_grid);
alpha_values = [1, 0.5, 0];
alpha_labels = {'\alpha=1 (L-priority)', ...
                '\alpha=1/2 (neutral)',  ...
                '\alpha=0 (H-priority)'};
alpha_colors = {'r', 'm', 'b'};

%% Pre-allocate
q_H_mono    = zeros(n_points, 1);
q_L_mono    = zeros(n_points, 1);
V_H_mono    = zeros(n_points, 1);
V_L_mono    = zeros(n_points, 1);
profit_mono = zeros(n_points, 1);

n_alpha       = length(alpha_values);
W_randian     = zeros(n_points, n_alpha);
W_utilitarian = zeros(n_points, n_alpha);
W_rawlsian    = zeros(n_points, n_alpha);
V_H_tax       = zeros(n_points, 1);
V_L_tax       = zeros(n_points, 1);


%% Main loop
for i = 1:n_points
    lam = lambda_grid(i);
    [q_H, q_L, V_H, V_L, profit, theta_H, theta_L] = get_screening_solution(lam);

    q_H_mono(i)    = q_H;
    q_L_mono(i)    = q_L;
    V_H_mono(i)    = V_H;
    V_L_mono(i)    = V_L;
    profit_mono(i) = profit;

    UBI        = profit;
    V_H_tax(i) = V_H + UBI;
    V_L_tax(i) = V_L + UBI;

    for j = 1:n_alpha
        al = alpha_values(j);
        W_randian(i,j)     = (1 - lam) * (1 - al) * V_H_tax(i);
        W_rawlsian(i,j)    =       lam *       al  * V_L_tax(i);
        W_utilitarian(i,j) = W_randian(i,j) + W_rawlsian(i,j);
    end
end

fprintf('Done!\n\n');

welfare_types  = {W_randian, W_utilitarian, W_rawlsian};
welfare_titles = {'Randian Welfare', 'Utilitarian Welfare', 'Rawlsian Welfare'};

%% Console output
lambda_display = [0.3, 0.5, 0.7];
fprintf('Results for Selected Lambda Values');
for lam_val = lambda_display
    idx = find(abs(lambda_grid - lam_val) < 0.01, 1);
    if ~isempty(idx)
        UBI_val = profit_mono(idx);
        lam     = lambda_grid(idx);
        fprintf('Lambda = %.2f | UBI = %.4f\n', lam, UBI_val);
        fprintf('  Post-UBI utilities:  V_H+UBI = %.4f   V_L+UBI = %.4f\n', ...
                V_H_tax(idx), V_L_tax(idx));
        for j = 1:n_alpha
            al = alpha_values(j);
            fprintf('  alpha = %.1f:  Randian = %.4f  |  Utilitarian = %.4f  |  Rawlsian = %.4f\n', ...
                    al, W_randian(idx,j), W_utilitarian(idx,j), W_rawlsian(idx,j));
        end
        fprintf('\n');
    end
end

%% -----------------------------------------------------------------------
%  FIGURE 1: Three diagonal cases
%  Diagonal mapping: p=1 Randian alpha=0 (col 3),
%                    p=2 Util   alpha=.5 (col 2),
%                    p=3 Rawls  alpha=1  (col 1)  => column = 4-p
% -----------------------------------------------------------------------
figure('Position', [50, 50, 1500, 480]);
sgtitle({'Three Welfare Criteria (Diagonal Alpha Cases)', ...
         'W = \alpha\lambda(V_L+UBI) + (1-\alpha)(1-\lambda)(V_H+UBI)'}, ...
        'FontSize', 13, 'FontWeight', 'bold');

diag_W     = {W_randian,  W_utilitarian, W_rawlsian};
diag_alpha = {'\alpha=0', '\alpha=1/2',  '\alpha=1'};
diag_title = {'Randian',  'Utilitarian', 'Rawlsian'};
diag_col   = {'b',        'm',           'r'};

for p = 1:3
    col = 4 - p;          
    w_vec = diag_W{p}(:, col);

    subplot(1, 3, p);
    plot(lambda_grid, w_vec, [diag_col{p}, '-'], 'LineWidth', 3);
    hold on;

    [~, imax] = max(w_vec);
    if imax > 2 && imax < n_points - 1   
        scatter(lambda_grid(imax), w_vec(imax), 120, 'k', 'filled', ...
                'DisplayName', sprintf('\\lambda^*=%.2f', lambda_grid(imax)));
        xline(lambda_grid(imax), 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
        legend('Location', 'best', 'FontSize', 9);
    end
    yline(0, 'k-', 'LineWidth', 0.8);
    xlabel('\lambda  (share of low types)', 'FontSize', 11);
    ylabel('Welfare', 'FontSize', 11);
    title({diag_title{p}, diag_alpha{p}}, 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
end

%% -----------------------------------------------------------------------
%  FIGURE 2: Overlay all alpha values — one panel per welfare criterion
% -----------------------------------------------------------------------
figure('Position', [100, 100, 1500, 500]);
sgtitle('Welfare Criteria: Overlay of All \alpha Values', ...
        'FontSize', 14, 'FontWeight', 'bold');

for p = 1:3
    subplot(1, 3, p);
    hold on;
    W_mat = welfare_types{p};
    for j = 1:n_alpha
        plot(lambda_grid, W_mat(:, j), ...
             [alpha_colors{j}, '-'], 'LineWidth', 2.5, ...
             'DisplayName', alpha_labels{j});
    end
    yline(0, 'k--', 'LineWidth', 0.8, 'HandleVisibility', 'off');
    xlabel('\lambda (Share of Low Types)', 'FontSize', 11);
    ylabel('Welfare', 'FontSize', 11);
    title(welfare_titles{p}, 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 9);
    grid on;
end

%% -----------------------------------------------------------------------
%  FIGURE 3: Randian vs Rawlsian gap by alpha
% -----------------------------------------------------------------------
figure('Position', [150, 150, 1500, 500]);
sgtitle('Randian--Rawlsian Gap by Alpha', 'FontSize', 14, 'FontWeight', 'bold');

for j = 1:n_alpha
    subplot(1, 3, j);
    gap = W_randian(:,j) - W_rawlsian(:,j);
    fill([lambda_grid, fliplr(lambda_grid)], ...
         [W_randian(:,j)', fliplr(W_rawlsian(:,j)')], [0.9 0.9 0.9], ...
         'FaceAlpha', 0.5, 'EdgeColor', 'none', 'DisplayName', 'Ideology gap');
    hold on;
    plot(lambda_grid, W_randian(:,j),  'b-',  'LineWidth', 2.5, 'DisplayName', 'Randian');
    plot(lambda_grid, W_rawlsian(:,j), 'r-',  'LineWidth', 2.5, 'DisplayName', 'Rawlsian');
    plot(lambda_grid, gap,             'k--', 'LineWidth', 2.0, 'DisplayName', 'Gap');
    yline(0, 'k-', 'LineWidth', 0.8, 'HandleVisibility', 'off');
    xlabel('\lambda', 'FontSize', 11);
    ylabel('Welfare', 'FontSize', 11);
    title({['Ideology Gap: ', alpha_labels{j}]}, 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 9);
    grid on;
end

%% -----------------------------------------------------------------------
%  FIGURE 4: Normalized welfare
% -----------------------------------------------------------------------
figure('Position', [200, 200, 1500, 500]);
sgtitle('Normalized Welfare by Criterion and Alpha', 'FontSize', 14, 'FontWeight', 'bold');

line_styles = {'-', '--', ':'};

for p = 1:3
    subplot(1, 3, p);
    hold on;
    W_mat = welfare_types{p};
    for j = 1:n_alpha
        w = W_mat(:,j);
        rng_w = max(w) - min(w);
        if rng_w > 1e-10
            w_norm = (w - min(w)) / rng_w;
        else
            w_norm = zeros(size(w));
        end
        plot(lambda_grid, w_norm, ...
             [alpha_colors{j}, line_styles{p}], 'LineWidth', 2.5, ...
             'DisplayName', alpha_labels{j});
    end
    xlabel('\lambda', 'FontSize', 11);
    ylabel('Normalized Welfare [0,1]', 'FontSize', 11);
    title(['Normalized: ', welfare_titles{p}], 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 9);
    ylim([-0.05, 1.05]);
    grid on;
end

%% -----------------------------------------------------------------------
%  Expected Welfare Summary Table
% -----------------------------------------------------------------------
fprintf('Expected Welfare (Uniform Distribution over Lambda)');
fprintf('%-12s  %-12s  %-14s  %-10s  %-12s\n', ...
        'Alpha', 'Criterion', 'E[Welfare]', 'Max at λ', 'Min at λ');
fprintf('%s\n', repmat('-', 1, 68));

mu = ones(n_points, 1) / n_points;
crit_names = {'Randian', 'Utilitarian', 'Rawlsian'};

for j = 1:n_alpha
    al = alpha_values(j);
    for p = 1:3
        W_mat = welfare_types{p};
        w     = W_mat(:,j);
        E_w   = sum(w .* mu);
        [~, imax] = max(w);
        [~, imin] = min(w);
        fprintf('alpha=%-5.1f   %-12s  %10.4f    λ=%.2f      λ=%.2f\n', ...
                al, crit_names{p}, E_w, lambda_grid(imax), lambda_grid(imin));
    end
    fprintf('\n');
end

fprintf('Analysis complete!\n');

%% -----------------------------------------------------------------------
%  Helper function
% -----------------------------------------------------------------------
function [q_H, q_L, V_H, V_L, profit, theta_H, theta_L] = get_screening_solution(lambda)
    [q_H, q_L, ~, ~, V_H, V_L, profit, theta_H, theta_L] = screening_problem(lambda);
end