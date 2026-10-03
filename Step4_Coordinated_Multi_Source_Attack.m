%% Step 4: Coordinated Multi-Source (Coherent) Spoofing Attack
clear;
clc;
close all;

%% =========================================================
%  STEP 4: SYSTEM PARAMETERS
% ==========================================================

fc = 1575.42e6;                         % GPS L1 frequency
c = physconst('LightSpeed');            % Speed of light
lambda = c / fc;                        % Wavelength

% 4-element ULA
array = phased.ULA( ...
    'NumElements', 4, ...
    'ElementSpacing', lambda/2);

% Satellite direction
satellite_angle = [30; 0];

% Multiple coordinated spoofers
spoofer_angles = [25 30 35;
                  0  0  0];

% Spoofing signal strength coefficients
beta = [3, 5, 3];

% Number of samples
numSamples = 1000;


%% =========================================================
%  GENERATE SIGNALS
% ==========================================================

% Desired satellite signal
satelliteSignal = ...
    randn(numSamples,1) + ...
    1i*randn(numSamples,1);

% Common coherent spoofing signal
baseSpoofSignal = ...
    randn(numSamples,1) + ...
    1i*randn(numSamples,1);


%% =========================================================
%  SIGNAL COLLECTION
% ==========================================================

collector = phased.Collector( ...
    'Sensor', array, ...
    'PropagationSpeed', c, ...
    'OperatingFrequency', fc);

% Satellite signal at array
satAtArray = collector( ...
    satelliteSignal, ...
    satellite_angle);


%% =========================================================
%  COORDINATED SPOOFING SIGNALS
% ==========================================================

spoofAtArray = zeros(numSamples, 4);

for k = 1:3

    spoofAtArray = spoofAtArray + ...
        collector( ...
        beta(k) * baseSpoofSignal, ...
        spoofer_angles(:,k));

end


%% =========================================================
%  ADD NOISE
% ==========================================================

noise = 0.1 * ( ...
    randn(numSamples,4) + ...
    1i*randn(numSamples,4));

% Total received signal
receivedSignal = ...
    satAtArray + ...
    spoofAtArray + ...
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
%  STEERING VECTOR
% ==========================================================

steeringvec = phased.SteeringVector( ...
    'SensorArray', array, ...
    'PropagationSpeed', c);

% Satellite steering vector
sv_satellite = steeringvec( ...
    fc, satellite_angle);


%% =========================================================
%  SATELLITE GAIN
% ==========================================================

gain_satellite_dB = ...
    10 * log10(abs(weights' * sv_satellite)^2);


%% =========================================================
%  DISPLAY MAIN RESULTS
% ==========================================================

fprintf('\n');
fprintf('===========================================\n');
fprintf(' STEP 4: Coordinated Multi-Source Attack\n');
fprintf('===========================================\n');

fprintf('Satellite direction : %d deg\n', ...
    satellite_angle(1));

fprintf('Gain at satellite    : %7.2f dB\n', ...
    gain_satellite_dB);

fprintf('-------------------------------------------\n');


%% =========================================================
%  CALCULATE SPOOFER GAINS AND NULL DEPTHS
% ==========================================================

nullDepths = zeros(1,3);
spoofGains = zeros(1,3);

for k = 1:3

    % Steering vector for each spoofer
    sv_spoof = steeringvec( ...
        fc, spoofer_angles(:,k));

    % Gain
    gain_dB = ...
        10 * log10(abs(weights' * sv_spoof)^2);

    spoofGains(k) = gain_dB;

    % Null depth
    nullDepths(k) = ...
        gain_satellite_dB - gain_dB;

    fprintf( ...
        'Spoofer %d (%2d deg): Gain = %6.2f dB | Null depth = %6.2f dB\n', ...
        k, ...
        spoofer_angles(1,k), ...
        gain_dB, ...
        nullDepths(k));

end

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


%% Title

title( ...
    { ...
    'MVDR Beam Pattern - Coordinated Attack', ...
    'Null Formation Fails' ...
    }, ...
    'FontSize', 14, ...
    'FontWeight', 'bold', ...
    'Color', [0.10 0.10 0.10]);


%% Axes formatting

ax1 = gca;

ax1.FontSize = 12;
ax1.FontWeight = 'bold';

ax1.XColor = [0.05 0.05 0.05];
ax1.YColor = [0.05 0.05 0.05];

ax1.Color = [0.96 0.96 0.96];

grid on;


%% Colormap

colormap(ax1, autumn);


%% =========================================================
%  FIGURE 2: NULL DEPTH COMPARISON
% ==========================================================

figure( ...
    'Color', 'w', ...
    'Position', [900 100 750 550]);


%% Baseline + coordinated attack results

% Baseline value from Step 3
baselineDepth = 49.17;

allDepths = [ ...
    baselineDepth, ...
    nullDepths];


%% Create bar chart

b = bar( ...
    allDepths, ...
    'FaceColor', 'flat', ...
    'BarWidth', 0.55);


%% Bar colors

% Baseline = Green
b.CData(1,:) = ...
    [0.20 0.65 0.30];

% Coordinated attack = Red
for i = 2:4

    b.CData(i,:) = ...
        [0.85 0.20 0.20];

end


%% =========================================================
%  AXES FORMATTING
% ==========================================================

ax2 = gca;

ax2.Color = 'w';

ax2.XColor = ...
    [0.05 0.05 0.05];

ax2.YColor = ...
    [0.05 0.05 0.05];

ax2.FontSize = 11;

ax2.FontWeight = 'bold';

ax2.LineWidth = 1.2;


%% =========================================================
%  X-AXIS LABELS
% ==========================================================

set(ax2, ...
    'XTick', 1:4, ...
    'XTickLabel', { ...
    'Baseline (80°)', ...
    'Spoofer 1 (25°)', ...
    'Spoofer 2 (30°)', ...
    'Spoofer 3 (35°)'});


%% =========================================================
%  AXIS LABELS
% ==========================================================

xlabel( ...
    'Scenario', ...
    'FontSize', 13, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);

ylabel( ...
    'Null Depth (dB)', ...
    'FontSize', 13, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);


%% =========================================================
%  TITLE
% ==========================================================

title( ...
    'Null Depth: Baseline vs Coordinated Attack', ...
    'FontSize', 14, ...
    'FontWeight', 'bold', ...
    'Color', [0.05 0.05 0.05]);


%% =========================================================
%  GRID
% ==========================================================

grid on;

ax2.GridColor = ...
    [0.5 0.5 0.5];

ax2.GridAlpha = 0.30;

ax2.Layer = 'top';


%% =========================================================
%  ZERO REFERENCE LINE
% ==========================================================

yline( ...
    0, ...
    '--', ...
    'Color', [0.2 0.2 0.2], ...
    'LineWidth', 1.2);


%% =========================================================
%  ADD VALUE LABELS ABOVE BARS
% ==========================================================

for i = 1:4

    if allDepths(i) >= 0

        yPosition = ...
            allDepths(i) + 2;

        verticalAlignment = ...
            'bottom';

    else

        yPosition = ...
            allDepths(i) - 2;

        verticalAlignment = ...
            'top';

    end

    text( ...
        i, ...
        yPosition, ...
        sprintf('%.2f dB', allDepths(i)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', verticalAlignment, ...
        'FontSize', 11, ...
        'FontWeight', 'bold', ...
        'Color', [0.05 0.05 0.05]);

end


%% =========================================================
%  Y-AXIS RANGE
% ==========================================================

yMin = min(allDepths) - 10;
yMax = max(allDepths) + 10;

ylim([yMin yMax]);


%% =========================================================
%  FINAL OUTPUT
% ==========================================================

fprintf('Figures generated successfully.\n');
fprintf('Figure 1 : MVDR Beam Pattern\n');
fprintf('Figure 2 : Null Depth Comparison\n');
fprintf('Baseline Null Depth : %.2f dB\n', baselineDepth);
fprintf('Spoofer 1 Null Depth: %.2f dB\n', nullDepths(1));
fprintf('Spoofer 2 Null Depth: %.2f dB\n', nullDepths(2));
fprintf('Spoofer 3 Null Depth: %.2f dB\n', nullDepths(3));