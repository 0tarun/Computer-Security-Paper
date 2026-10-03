%% Step 3: Baseline MVDR - Single-Source Spoofing Attack
clear;
clc;
close all;

%% =========================================================
%  STEP 3: SYSTEM PARAMETERS
% ==========================================================

fc = 1575.42e6;                         % GPS L1 frequency
c = physconst('LightSpeed');            % Speed of light
lambda = c / fc;                        % Wavelength

% 4-element ULA
array = phased.ULA( ...
    'NumElements', 4, ...
    'ElementSpacing', lambda/2);

% Signal directions [Azimuth; Elevation]
satellite_angle = [30; 0];
spoofer_angle   = [80; 0];

% Number of samples
numSamples = 1000;


%% =========================================================
%  GENERATE SATELLITE AND SPOOFER SIGNALS
% ==========================================================

% Desired satellite signal
satelliteSignal = ...
    randn(numSamples,1) + ...
    1i*randn(numSamples,1);

% Stronger spoofing signal
spooferSignal = 5 * ( ...
    randn(numSamples,1) + ...
    1i*randn(numSamples,1));


%% =========================================================
%  SIGNAL COLLECTION
% ==========================================================

collector = phased.Collector( ...
    'Sensor', array, ...
    'PropagationSpeed', c, ...
    'OperatingFrequency', fc);

% Satellite signal received by array
satAtArray = collector( ...
    satelliteSignal, ...
    satellite_angle);

% Spoofer signal received by array
spooferAtArray = collector( ...
    spooferSignal, ...
    spoofer_angle);


%% =========================================================
%  ADD NOISE
% ==========================================================

noise = 0.1 * ( ...
    randn(numSamples,4) + ...
    1i*randn(numSamples,4));

% Total received signal
receivedSignal = ...
    satAtArray + ...
    spooferAtArray + ...
    noise;


%% =========================================================
%  MVDR BEAMFORMER
% ==========================================================

mvdrBeamformer = phased.MVDRBeamformer( ...
    'SensorArray', array, ...
    'PropagationSpeed', c, ...
    'OperatingFrequency', fc, ...
    'DirectionSource', 'Property', ...
    'Direction', satellite_angle, ...
    'WeightsOutputPort', true);

% Apply MVDR
[beamformedSignal, weights] = ...
    mvdrBeamformer(receivedSignal);


%% =========================================================
%  STEERING VECTORS
% ==========================================================

steeringvec = phased.SteeringVector( ...
    'SensorArray', array, ...
    'PropagationSpeed', c);

% Satellite steering vector
sv_satellite = steeringvec( ...
    fc, satellite_angle);

% Spoofer steering vector
sv_spoofer = steeringvec( ...
    fc, spoofer_angle);


%% =========================================================
%  CALCULATE ARRAY GAIN
% ==========================================================

gain_satellite_dB = ...
    10 * log10(abs(weights' * sv_satellite)^2);

gain_spoofer_dB = ...
    10 * log10(abs(weights' * sv_spoofer)^2);

% Null depth
nullDepth = ...
    gain_satellite_dB - gain_spoofer_dB;


%% =========================================================
%  DISPLAY RESULTS IN COMMAND WINDOW
% ==========================================================

fprintf('\n');
fprintf('===========================================\n');
fprintf(' STEP 3: Baseline - Single-Source Spoofing\n');
fprintf('===========================================\n');

fprintf('Satellite direction        : %d deg\n', ...
    satellite_angle(1));

fprintf('Spoofer direction          : %d deg\n', ...
    spoofer_angle(1));

fprintf('-------------------------------------------\n');

fprintf('Gain at satellite          : %7.2f dB\n', ...
    gain_satellite_dB);

fprintf('Gain at spoofer            : %7.2f dB\n', ...
    gain_spoofer_dB);

fprintf('NULL DEPTH                 : %7.2f dB\n', ...
    nullDepth);

fprintf('===========================================\n\n');


%% =========================================================
%  FIGURE 1: MVDR BEAM PATTERN
% ==========================================================

figure( ...
    'Color', [0.96 0.96 0.96], ...
    'Position', [100 100 800 650]);

pattern( ...
    array, ...
    fc, ...
    -180:180, ...
    0, ...
    'PropagationSpeed', c, ...
    'Weights', weights, ...
    'Type', 'powerdb', ...
    'CoordinateSystem', 'polar');

% Title
title({ ...
    'MVDR Beam Pattern - Baseline Defense', ...
    sprintf('Null Depth = %.2f dB at %d°', ...
    nullDepth, spoofer_angle(1))}, ...
    'FontSize', 14, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);

% Axes formatting
ax1 = gca;

ax1.FontSize = 12;
ax1.FontWeight = 'bold';

ax1.XColor = [0.05 0.05 0.05];
ax1.YColor = [0.05 0.05 0.05];

ax1.Color = [0.96 0.96 0.96];

grid on;

% Colormap
colormap(ax1, parula);


%% =========================================================
%  FIGURE 2: GAIN COMPARISON BAR CHART
% ==========================================================

figure( ...
    'Color', 'w', ...
    'Position', [950 100 700 550]);

% Values
vals = [ ...
    gain_satellite_dB, ...
    gain_spoofer_dB];


% Create bar chart
b = bar( ...
    vals, ...
    'FaceColor', 'flat', ...
    'BarWidth', 0.55);

% Satellite = Green
b.CData(1,:) = [0.20 0.65 0.30];

% Spoofer = Red
b.CData(2,:) = [0.85 0.20 0.20];


%% Axes formatting

ax2 = gca;

ax2.Color = 'w';

ax2.XColor = [0.05 0.05 0.05];
ax2.YColor = [0.05 0.05 0.05];

ax2.FontSize = 12;
ax2.FontWeight = 'bold';

ax2.LineWidth = 1.2;


%% X-axis labels

set(ax2, ...
    'XTick', 1:2, ...
    'XTickLabel', { ...
    'Satellite (30°)', ...
    'Spoofer (80°)'});


%% X-axis label

xlabel( ...
    'Signal Source', ...
    'FontSize', 13, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);


%% Y-axis label

ylabel( ...
    'Gain (dB)', ...
    'FontSize', 13, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);


%% Title

title( ...
    sprintf( ...
    'Baseline Result - Null Depth = %.2f dB', ...
    nullDepth), ...
    'FontSize', 14, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);


%% Grid

grid on;

ax2.GridColor = [0.5 0.5 0.5];

ax2.GridAlpha = 0.30;

ax2.Layer = 'top';


%% Zero reference line

yline( ...
    0, ...
    '--', ...
    'Color', [0.2 0.2 0.2], ...
    'LineWidth', 1.2);


%% =========================================================
%  ADD VALUE LABELS ABOVE EACH BAR
% ==========================================================

for i = 1:2

    if vals(i) >= 0

        yPosition = vals(i) + 2;

        verticalAlignment = 'bottom';

    else

        yPosition = vals(i) - 2;

        verticalAlignment = 'top';

    end

    text( ...
        i, ...
        yPosition, ...
        sprintf('%.2f dB', vals(i)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', verticalAlignment, ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'Color', [0.05 0.05 0.05]);

end


%% =========================================================
%  ADJUST Y-AXIS LIMIT
% ==========================================================

yMin = min(vals) - 10;
yMax = max(vals) + 10;

ylim([yMin yMax]);


%% =========================================================
%  FINAL MESSAGE
% ==========================================================

fprintf('Figures generated successfully.\n');
fprintf('Figure 1 : MVDR Beam Pattern\n');
fprintf('Figure 2 : Satellite vs Spoofer Gain\n');
fprintf('Null Depth: %.2f dB\n', nullDepth);