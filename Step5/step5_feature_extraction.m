%% Step 5: Extract Features from Baseline vs Coordinated Attack
clear;
clc;
close all;

%% =========================================================
%  SYSTEM PARAMETERS
% ==========================================================

fc = 1575.42e6;
c = physconst('LightSpeed');
lambda = c / fc;

% 4-element ULA
array = phased.ULA( ...
    'NumElements', 4, ...
    'ElementSpacing', lambda/2);

% Collector
collector = phased.Collector( ...
    'Sensor', array, ...
    'PropagationSpeed', c, ...
    'OperatingFrequency', fc);

% Satellite direction
satellite_angle = [30; 0];

% Number of samples
numSamples = 1000;


%% =========================================================
%  SCENARIO A: BASELINE - SINGLE SPOOFER
% ==========================================================

spoofer_angle = [80; 0];

% Satellite signal
satelliteSignal = ...
    randn(numSamples,1) + ...
    1i*randn(numSamples,1);

% Strong single spoofer
spooferSignal = 5 * ( ...
    randn(numSamples,1) + ...
    1i*randn(numSamples,1));

% Satellite received at array
satAtArray = collector( ...
    satelliteSignal, ...
    satellite_angle);

% Spoofer received at array
spooferAtArray = collector( ...
    spooferSignal, ...
    spoofer_angle);

% Noise
noise = 0.1 * ( ...
    randn(numSamples,4) + ...
    1i*randn(numSamples,4));

% Total baseline received signal
receivedSignal_baseline = ...
    satAtArray + ...
    spooferAtArray + ...
    noise;


%% =========================================================
%  EXTRACT BASELINE FEATURES
% ==========================================================

[pc_base, es_base, dr_base] = ...
    extractFeatures(receivedSignal_baseline);


%% =========================================================
%  SCENARIO B: COORDINATED MULTI-SOURCE ATTACK
% ==========================================================

spoofer_angles = [25 30 35;
                  0  0  0];

% Spoofing strength
beta = [3, 5, 3];

% Common coherent spoofing signal
baseSpoofSignal = ...
    randn(numSamples,1) + ...
    1i*randn(numSamples,1);


% Satellite signal
satAtArray2 = collector( ...
    satelliteSignal, ...
    satellite_angle);


%% =========================================================
%  GENERATE COORDINATED SPOOFING SIGNALS
% ==========================================================

spoofAtArray = zeros(numSamples,4);

for k = 1:3

    spoofAtArray = spoofAtArray + ...
        collector( ...
        beta(k) * baseSpoofSignal, ...
        spoofer_angles(:,k));

end


%% =========================================================
%  ADD NOISE
% ==========================================================

noise2 = 0.1 * ( ...
    randn(numSamples,4) + ...
    1i*randn(numSamples,4));


% Total attack received signal
receivedSignal_attack = ...
    satAtArray2 + ...
    spoofAtArray + ...
    noise2;


%% =========================================================
%  EXTRACT ATTACK FEATURES
% ==========================================================

[pc_attack, es_attack, dr_attack] = ...
    extractFeatures(receivedSignal_attack);


%% =========================================================
%  PRINT FEATURE COMPARISON
% ==========================================================

fprintf('\n');
fprintf('===========================================\n');
fprintf(' STEP 5: Feature Extraction Results\n');
fprintf('===========================================\n');

fprintf('%-22s %12s %12s\n', ...
    'Feature', ...
    'Baseline', ...
    'Coord.Attack');

fprintf('-------------------------------------------\n');

fprintf('%-22s %12.4f %12.4f\n', ...
    'Phase Correlation', ...
    pc_base, ...
    pc_attack);

fprintf('%-22s %12.4f %12.4f\n', ...
    'Eigenvalue Spread', ...
    es_base, ...
    es_attack);

fprintf('%-22s %12.4f %12.4f\n', ...
    'Doppler Residual', ...
    dr_base, ...
    dr_attack);

fprintf('===========================================\n\n');


%% =========================================================
%  PREPARE DATA FOR PLOTS
% ==========================================================

features = { ...
    'Phase Correlation', ...
    'Eigenvalue Spread', ...
    'Doppler Residual'};

baselineVals = [ ...
    pc_base, ...
    es_base, ...
    dr_base];

attackVals = [ ...
    pc_attack, ...
    es_attack, ...
    dr_attack];


%% =========================================================
%  FIGURE: FEATURE COMPARISON
% ==========================================================

figure( ...
    'Color', 'w', ...
    'Position', [100 100 1200 550]);


%% =========================================================
%  SUBPLOT 1: PHASE CORRELATION
% ==========================================================

subplot(1,3,1);

vals1 = [ ...
    baselineVals(1), ...
    attackVals(1)];

b1 = bar( ...
    vals1, ...
    'FaceColor', 'flat', ...
    'BarWidth', 0.55);

% Baseline = Green
b1.CData(1,:) = ...
    [0.20 0.65 0.30];

% Attack = Red
b1.CData(2,:) = ...
    [0.85 0.20 0.20];


% X-axis
set(gca, ...
    'XTick', 1:2, ...
    'XTickLabel', { ...
    'Baseline', ...
    'Attack'});


% Axes formatting
ax1 = gca;

ax1.Color = 'w';
ax1.XColor = [0.05 0.05 0.05];
ax1.YColor = [0.05 0.05 0.05];

ax1.FontSize = 11;
ax1.FontWeight = 'bold';

ax1.LineWidth = 1.1;

grid on;

ax1.GridColor = [0.5 0.5 0.5];
ax1.GridAlpha = 0.30;

title( ...
    'Phase Correlation', ...
    'FontSize', 13, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);

ylabel( ...
    'Value', ...
    'FontSize', 11, ...
    'FontWeight', 'bold');


% Add values
for i = 1:2

    if vals1(i) >= 0
        yPos = vals1(i) + abs(max(vals1))*0.05;
    else
        yPos = vals1(i) - abs(max(vals1))*0.05;
    end

    text( ...
        i, ...
        yPos, ...
        sprintf('%.4f', vals1(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Color', [0.05 0.05 0.05]);

end


%% =========================================================
%  SUBPLOT 2: EIGENVALUE SPREAD
% ==========================================================

subplot(1,3,2);

vals2 = [ ...
    baselineVals(2), ...
    attackVals(2)];

b2 = bar( ...
    vals2, ...
    'FaceColor', 'flat', ...
    'BarWidth', 0.55);

% Colors
b2.CData(1,:) = ...
    [0.20 0.65 0.30];

b2.CData(2,:) = ...
    [0.85 0.20 0.20];


% X-axis labels
set(gca, ...
    'XTick', 1:2, ...
    'XTickLabel', { ...
    'Baseline', ...
    'Attack'});


% Axes formatting
ax2 = gca;

ax2.Color = 'w';

ax2.XColor = [0.05 0.05 0.05];
ax2.YColor = [0.05 0.05 0.05];

ax2.FontSize = 11;
ax2.FontWeight = 'bold';

ax2.LineWidth = 1.1;

grid on;

ax2.GridColor = [0.5 0.5 0.5];
ax2.GridAlpha = 0.30;


% Title
title( ...
    'Eigenvalue Spread', ...
    'FontSize', 13, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);

ylabel( ...
    'Value', ...
    'FontSize', 11, ...
    'FontWeight', 'bold');


% Add values
for i = 1:2

    if vals2(i) >= 0
        yPos = vals2(i) + abs(max(vals2))*0.05;
    else
        yPos = vals2(i) - abs(max(vals2))*0.05;
    end

    text( ...
        i, ...
        yPos, ...
        sprintf('%.4f', vals2(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Color', [0.05 0.05 0.05]);

end


%% =========================================================
%  SUBPLOT 3: DOPPLER RESIDUAL
% ==========================================================

subplot(1,3,3);

vals3 = [ ...
    baselineVals(3), ...
    attackVals(3)];

b3 = bar( ...
    vals3, ...
    'FaceColor', 'flat', ...
    'BarWidth', 0.55);


% Colors
b3.CData(1,:) = ...
    [0.20 0.65 0.30];

b3.CData(2,:) = ...
    [0.85 0.20 0.20];


% X-axis labels
set(gca, ...
    'XTick', 1:2, ...
    'XTickLabel', { ...
    'Baseline', ...
    'Attack'});


% Axes formatting
ax3 = gca;

ax3.Color = 'w';

ax3.XColor = [0.05 0.05 0.05];
ax3.YColor = [0.05 0.05 0.05];

ax3.FontSize = 11;
ax3.FontWeight = 'bold';

ax3.LineWidth = 1.1;

grid on;

ax3.GridColor = [0.5 0.5 0.5];
ax3.GridAlpha = 0.30;


% Title
title( ...
    'Doppler Residual', ...
    'FontSize', 13, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);

ylabel( ...
    'Value', ...
    'FontSize', 11, ...
    'FontWeight', 'bold');


% Add values
for i = 1:2

    if vals3(i) >= 0
        yPos = vals3(i) + abs(max(vals3))*0.05;
    else
        yPos = vals3(i) - abs(max(vals3))*0.05;
    end

    text( ...
        i, ...
        yPos, ...
        sprintf('%.4f', vals3(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Color', [0.05 0.05 0.05]);

end


%% =========================================================
%  OVERALL TITLE
% ==========================================================

sgtitle( ...
    'Feature Comparison: Baseline vs Coordinated Attack', ...
    'FontSize', 16, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);


%% =========================================================
%  FINAL OUTPUT
% ==========================================================

fprintf('Feature comparison figure generated successfully.\n');
fprintf('\n');

fprintf('Baseline Features:\n');
fprintf('  Phase Correlation : %.4f\n', pc_base);
fprintf('  Eigenvalue Spread : %.4f\n', es_base);
fprintf('  Doppler Residual  : %.4f\n', dr_base);

fprintf('\nCoordinated Attack Features:\n');
fprintf('  Phase Correlation : %.4f\n', pc_attack);
fprintf('  Eigenvalue Spread : %.4f\n', es_attack);
fprintf('  Doppler Residual  : %.4f\n', dr_attack);

fprintf('\n===========================================\n');