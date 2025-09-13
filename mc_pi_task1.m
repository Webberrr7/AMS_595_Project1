% mc_pi_task1  — Project 1, Task 1
% Monte Carlo Estimation of pi — for-loop + timing + plots
% How to run: in MATLAB, run `mc_pi_task1` in the folder of this file.

clear; clc; close all;
rng(123);  % Fix random seed for reproducibility
N_max    = 1e6;                                % Max samples for the running estimate
N_values = [1e3 5e3 1e4 5e4 1e5 2e5 5e5 1e6];  % Sample sizes for timing & accuracy

% Part A: Running estimate and error vs. sample size

inside = 0;                          % cumulative hits inside the quarter circle
pi_estimates = zeros(N_max, 1);      % running estimates
n = (1:N_max)';                      % sample indices

for k = 1:N_max
    x = rand;                        % sample on [0,1]
    y = rand;                        % sample on [0,1]
    if x^2 + y^2 <= 1                % inside quarter circle
        inside = inside + 1;
    end
    pi_estimates(k) = 4 * inside / k;  % running estimate
end

abs_err = abs(pi_estimates - pi);    % absolute error vs. truth

% Plots: top — running estimate; bottom — absolute error
figure('Name','Task 1: Running Estimation','Color','w');
subplot(2,1,1);
plot(n, pi_estimates, 'LineWidth', 1);
hold on;
yline(pi, '--');                     % true pi
xlabel('Sample size n'); ylabel('Estimate of \pi');
title('Running Estimate of \pi (for-loop)');
legend('Estimate','True \pi','Location','best'); grid on;

subplot(2,1,2);
plot(n, abs_err, 'LineWidth', 1);
xlabel('Sample size n'); ylabel('|\pi_{hat} - \pi|');
title('Absolute Error vs. n'); grid on;

% Part B: Timing and final accuracy across different N

time_taken   = zeros(size(N_values));
final_errors = zeros(size(N_values));

for i = 1:numel(N_values)
    N = N_values(i);
    inside = 0;
    tic;                              % start timer
    for k = 1:N
        x = rand; y = rand;
        if x^2 + y^2 <= 1
            inside = inside + 1;
        end
    end
    time_taken(i) = toc;              % stop timer
    pi_hat = 4 * inside / N;          % estimate for this N
    final_errors(i) = abs(pi_hat - pi);
end

% Plots: left — error vs N; right — error vs time
figure('Name','Task 1: Cost vs Precision','Color','w');
subplot(1,2,1);
plot(N_values, final_errors, '-o', 'LineWidth', 1);
xlabel('Sample size N'); ylabel('Absolute Error |\pi_{hat} - \pi|');
title('Error vs. Sample Size'); grid on;

subplot(1,2,2);
plot(time_taken, final_errors, '-o', 'LineWidth', 1);
xlabel('Runtime (s)'); ylabel('Absolute Error |\pi_{hat} - \pi|');
title('Precision vs. Computation Cost'); grid on;

% Small table for quick view in the console
T = table(N_values(:), time_taken(:), final_errors(:), ...
    'VariableNames', {'N','Time_s','AbsError'});
disp('--- Timing & Error Results ---');
disp(T);
