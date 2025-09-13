% mc_pi_task2  — Project 1, Task 2
% Monte Carlo π with a WHILE loop to a user-specified precision.
% Idea: Treat hits as Binomial(N, p) with p ≈ pi/4. Use the plug-in estimate p_hat
% to compute a 95% CI half-width for pi_hat = 4*p_hat. Stop when the CI half-width
% is smaller than the absolute tolerance required to guarantee the requested
% number of significant figures for the CURRENT estimate.
%
% Outputs:
%  - A table listing: required significant figures, total samples N to achieve it,
%    final estimate pi_hat, and the 95% CI half-width at stopping.
%  - A simple summary figure (error bars of the final 95% CI for each target).
%
% How "sig-fig tolerance" is checked WITHOUT true pi:
%   For s significant figures, rounding is stable if the uncertainty is less than
%   half of the unit in the s-th digit. For a number x, the absolute tolerance is
%       tol_abs = 0.5 * 10^(floor(log10(|x|)) - s + 1).

clear; clc; close all;
rng(123);                 % reproducibility
sigfigs_list = [2 3 4];   % target significant figures
z = 1.96;                 % 95% confidence
batch = 1e5;              % draw this many points per while-iteration
maxN  = 5e7;              % safety cap to avoid infinite loops

% results table
Results = table('Size',[numel(sigfigs_list) 5], ...
    'VariableTypes', {'double','double','double','double','string'}, ...
    'VariableNames', {'SigFigs','N','pi_hat','CI_half','Rounded'});

for i = 1:numel(sigfigs_list)
    s = sigfigs_list(i);

    % running stats
    N = 0;
    inside = 0;
    pi_hat = NaN;
    ci_half = Inf;

    % while loop: keep sampling until CI half-width below the sig-fig tolerance
    while true
        % draw a block of random points to speed things up
        b = min(batch, maxN - N);
        if b <= 0
            warning('Reached maxN=%g before meeting precision for %d sig figs.', maxN, s);
            break;
        end

        x = rand(b,1);
        y = rand(b,1);
        inside = inside + sum(x.^2 + y.^2 <= 1);
        N = N + b;

        % plug-in estimates
        p_hat = inside / N;                              % ≈ pi/4
        pi_hat = 4 * p_hat;                              % estimator of pi
        se = 4 * sqrt(max(p_hat*(1 - p_hat), eps) / N);  % std error of pi_hat (binomial CLT)
        ci_half = z * se;                                % 95% CI half-width for pi_hat

        % absolute tolerance that guarantees s significant figures for CURRENT estimate
        order = floor(log10(abs(pi_hat)));
        tol_abs = 0.5 * 10^(order - s + 1);

        if ci_half <= tol_abs
            break;
        end
    end

    % rounded string to s significant figures
    pi_rounded = round_sigfigs(pi_hat, s);

    % store
    Results.SigFigs(i) = s;
    Results.N(i)       = N;
    Results.pi_hat(i)  = pi_hat;
    Results.CI_half(i) = ci_half;
    Results.Rounded(i) = pi_rounded;
end

% Display results
disp('--- Task 2 Results (while-loop stopping WITHOUT true pi) ---');
disp(Results);

% Simple plot: final 95% CI for each target s
figure('Name','Task 2: Final 95% CI at Stopping','Color','w');
xpos = Results.SigFigs;
errorbar(xpos, Results.pi_hat, Results.CI_half, 'o', 'LineWidth', 1); grid on;
xlabel('Target significant figures (s)');
ylabel('Final estimate of \pi with 95% CI');
title('Stopping when CI half-width matches s significant-figures tolerance');
xticks(sigfigs_list);

% round to s significant figures
function s = round_sigfigs(x, nSig)
% Return a string of x rounded to nSig significant figures.
% Works for scalar x (finite, non-NaN).
    if ~isfinite(x) || x == 0
        s = string(x);
        return;
    end
    k = floor(log10(abs(x)));
    % number of decimals for MATLAB round(x, ndp)
    ndp = nSig - 1 - k;
    y = round(x, ndp);
    % Use sprintf to control significant figures in output string
    fmt = sprintf('%%.%dg', nSig);
    s = string(sprintf(fmt, y));
end
