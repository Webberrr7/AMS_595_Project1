function pi_hat = mc_pi_task3(sigfigs)
% mc_pi_task3  — Project 1, Task 3
% Estimate pi by Monte Carlo using a WHILE loop until a user-chosen
% number of significant figures is reached. The stopping rule does NOT
% use the true value of pi.
%
% Required features:
%  (1) Input: a user-defined precision (significant figures), e.g., 2, 3, 4.
%  (2) Live graphic: plot random points as they are generated:
%      points inside the quarter circle vs. outside in different colors.
%  (3) Output: the final value of pi, rounded to the requested precision,
%      is printed in the Command Window AND shown on the plot.
%  (4) Return: the computed (unrounded) pi_hat is returned by the function.
%
% Usage example:
%   >> pi_est = mc_pi_task3(3)    % target 3 significant figures


% Basic checks and simple settings
if nargin < 1 || ~isscalar(sigfigs) || sigfigs < 1
    error('Please pass a positive integer for significant figures, e.g., 3.');
end
sigfigs = floor(sigfigs);

rng(123);          % reproducible
z = 1.96;          % 95% confidence
batch = 2000;      % how many points to add each while-iteration
maxN  = 1e7;       % safety cap (avoid infinite loop)
plotCap = 2e4;     % keep at most this many points on screen for speed

% Set up the figure
figure('Name','Task 3: Monte Carlo \pi','Color','w');
axis([0 1 0 1]); axis square; hold on; box on;
xlabel('x'); ylabel('y'); title('Generating random points...');
% draw the quarter circle boundary for reference
t = linspace(0, pi/2, 200);
plot(cos(t), sin(t), 'k-', 'LineWidth', 1, 'DisplayName','Quarter circle');

% two scatter groups: inside vs outside
hIn  = scatter(NaN,NaN,8,'filled','DisplayName','Inside');
hOut = scatter(NaN,NaN,8,        'DisplayName','Outside');
legend('Location','southoutside');

% a small text box to show running info
hTxt = text(0.02, 0.98, '', 'Units','normalized','VerticalAlignment','top');

%Monte Carlo with a WHILE loop
inside = 0;    % number of points inside the quarter circle
N = 0;         % total number of points
pi_hat = NaN;  % current estimate
ci_half = Inf; % current 95% CI half-width

% store a limited number of recent points for display
Xin = []; Yin = [];
Xout = []; Yout = [];

while true
    % stop if we hit the safety cap
    if N >= maxN
        warning('Reached MaxN=%g before meeting precision (%d sig figs).', maxN, sigfigs);
        break;
    end

    % draw a small batch of random points
    b = min(batch, maxN - N);
    x = rand(b,1);
    y = rand(b,1);
    inMask = (x.^2 + y.^2) <= 1;

    % update counts
    cIn = sum(inMask);
    inside = inside + cIn;
    N = N + b;

    % estimate pi and a simple 95% CI
    p_hat = inside / N;                      % ≈ pi/4
    pi_hat = 4 * p_hat;
    se = 4 * sqrt(max(p_hat*(1 - p_hat), eps) / N); % std. error
    ci_half = z * se;                        % 95% CI half-width for pi_hat

    % tolerance that guarantees the requested significant figures
    if pi_hat == 0
        ord = 0;
    else
        ord = floor(log10(abs(pi_hat)));
    end
    tol_abs = 0.5 * 10^(ord - sigfigs + 1);

    % update points shown on screen
    Xin  = [Xin;  x(inMask)];
    Yin  = [Yin;  y(inMask)];
    Xout = [Xout; x(~inMask)];
    Yout = [Yout; y(~inMask)];
    if numel(Xin)  > plotCap, Xin  = Xin(end-plotCap+1:end);  Yin  = Yin(end-plotCap+1:end);  end
    if numel(Xout) > plotCap, Xout = Xout(end-plotCap+1:end); Yout = Yout(end-plotCap+1:end); end
    set(hIn,  'XData', Xin,  'YData', Yin);
    set(hOut, 'XData', Xout, 'YData', Yout);

    % show running info (rounded to the requested significant figures)
    rStr = round_sigfigs(pi_hat, sigfigs);
    set(hTxt, 'String', sprintf('N = %d\n\\pi_{est} = %s\n95%% CI half-width \\approx %.3g', ...
        N, rStr, ci_half));

    drawnow;  %screen update

    % stopping rule: CI half-width is small enough for the requested sig figs
    if ci_half <= tol_abs
        break;
    end
end

% Final printing and on-plot label
finalStr = round_sigfigs(pi_hat, sigfigs);
fprintf('Task 3 finished:\n  Target significant figures: %d\n  N used: %d\n  pi (rounded): %s\n', ...
    sigfigs, N, finalStr);

text(0.02, 0.08, sprintf('Final: \\pi \\approx %s  (N = %d)', finalStr, N), ...
    'Units','normalized','FontWeight','bold');
title(sprintf('Stopped at %d significant figures (N = %d)', sigfigs, N));

end

% round a number to n significant figures, return a string
function s = round_sigfigs(x, nSig)
% rounding to significant figures using log10 and round.
    if ~isfinite(x) || x == 0
        s = string(x);
        return;
    end
    k = floor(log10(abs(x)));      % order of magnitude
    nd = nSig - 1 - k;             % decimals for round(x, nd)
    y = round(x, nd);              % rounded numeric
    fmt = sprintf('%%.%dg', nSig); % print with nSig significant figures
    s = string(sprintf(fmt, y));
end
