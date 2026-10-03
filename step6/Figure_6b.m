%% Step 6b (Simplified): Threshold Classifier Only - Final Visualization
clear; clc; close all;

%% ---------- Load Dataset ----------
load('detection_dataset.mat');

numTrials = size(features_baseline, 1);

X = [features_baseline; features_attack];
y = [zeros(numTrials,1); ones(numTrials,1)];

%% ---------- Threshold Classifier ----------
threshold_ES = (mean(features_baseline(:,2)) + ...
                mean(features_attack(:,2))) / 2;

predictions = double(X(:,2) > threshold_ES);

%% ---------- Performance Calculation ----------
TP = sum(predictions == 1 & y == 1);
TN = sum(predictions == 0 & y == 0);
FP = sum(predictions == 1 & y == 0);
FN = sum(predictions == 0 & y == 1);

accuracy = (TP + TN) / length(y) * 100;
detectionRate = TP / (TP + FN) * 100;
falseAlarmRate = FP / (FP + TN) * 100;

%% ---------- Display Results ----------
fprintf('===========================================\n');
fprintf(' STEP 6b: Threshold-Based Detection\n');
fprintf('===========================================\n');

fprintf('Threshold Feature   : Eigenvalue Spread\n');
fprintf('Threshold Value     : %.2f\n', threshold_ES);
fprintf('-------------------------------------------\n');
fprintf('Accuracy            : %.2f%%\n', accuracy);
fprintf('Detection Rate      : %.2f%%\n', detectionRate);
fprintf('False Alarm Rate    : %.2f%%\n', falseAlarmRate);
fprintf('-------------------------------------------\n');
fprintf('TP = %d\n', TP);
fprintf('TN = %d\n', TN);
fprintf('FP = %d\n', FP);
fprintf('FN = %d\n', FN);
fprintf('===========================================\n\n');


%% =========================================================
% Visualization 1: Confusion Matrix
% ==========================================================

figure('Color', 'w', ...
       'Position', [100 100 700 600]);

cm = confusionchart(y, predictions);

cm.Title = sprintf('Threshold Detector Confusion Matrix\nAccuracy: %.2f%%', ...
                   accuracy);

cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

% Force readable font
cm.FontSize = 14;


%% =========================================================
% Visualization 2: Detection Boundary
% ==========================================================

figure('Color', 'w', ...
       'Position', [850 100 850 650]);

% Baseline points
scatter(features_baseline(:,1), ...
        features_baseline(:,2), ...
        60, ...
        [0.20 0.65 0.30], ...
        'filled', ...
        'DisplayName', 'Baseline (Normal)');

hold on;

% Attack points
scatter(features_attack(:,1), ...
        features_attack(:,2), ...
        60, ...
        [0.85 0.20 0.20], ...
        'filled', ...
        'DisplayName', 'Coordinated Attack');

% Threshold
yline(threshold_ES, ...
      'k--', ...
      'LineWidth', 2.5, ...
      'DisplayName', ...
      sprintf('Threshold = %.2f', threshold_ES));

%% ---------- Labels ----------
xlabel('Phase Correlation', ...
       'FontSize', 14, ...
       'FontWeight', 'bold', ...
       'Color', [0.05 0.05 0.05]);

ylabel('Eigenvalue Spread', ...
       'FontSize', 14, ...
       'FontWeight', 'bold', ...
       'Color', [0.05 0.05 0.05]);

title('Threshold Detection Boundary', ...
      'FontSize', 16, ...
      'FontWeight', 'bold', ...
      'Color', [0.05 0.05 0.05]);

%% ---------- Axes Styling ----------
ax = gca;

ax.Color = 'w';
ax.XColor = [0.05 0.05 0.05];
ax.YColor = [0.05 0.05 0.05];

ax.FontSize = 12;
ax.FontWeight = 'bold';
ax.LineWidth = 1.3;

%% ---------- Grid ----------
grid on;

ax.GridColor = [0.50 0.50 0.50];
ax.GridAlpha = 0.30;
ax.Layer = 'top';

%% ---------- Legend ----------
lgd = legend('Location', 'best');

lgd.FontSize = 11;
lgd.TextColor = [0.05 0.05 0.05];
lgd.Color = 'w';
lgd.EdgeColor = [0.30 0.30 0.30];


%% =========================================================
% Visualization 3: Performance Bar Chart
% ==========================================================

figure('Color', 'w', ...
       'Position', [300 750 850 550]);

performanceValues = [accuracy, detectionRate, falseAlarmRate];

barHandle = bar(performanceValues, ...
                'FaceColor', 'flat', ...
                'BarWidth', 0.55);

% Colors
barHandle.CData(1,:) = [0.20 0.65 0.30];   % Accuracy
barHandle.CData(2,:) = [0.20 0.65 0.30];   % Detection
barHandle.CData(3,:) = [0.85 0.20 0.20];   % False Alarm

%% ---------- X-axis ----------
set(gca, ...
    'XTick', 1:3, ...
    'XTickLabel', ...
    {'Accuracy', 'Detection Rate', 'False Alarm Rate'});

%% ---------- Labels ----------
xlabel('Performance Metrics', ...
       'FontSize', 13, ...
       'FontWeight', 'bold', ...
       'Color', [0.05 0.05 0.05]);

ylabel('Percentage (%)', ...
       'FontSize', 13, ...
       'FontWeight', 'bold', ...
       'Color', [0.05 0.05 0.05]);

title('Threshold Detector Performance', ...
      'FontSize', 16, ...
      'FontWeight', 'bold', ...
      'Color', [0.05 0.05 0.05]);

%% ---------- Axes Styling ----------
ax = gca;

ax.Color = 'w';
ax.XColor = [0.05 0.05 0.05];
ax.YColor = [0.05 0.05 0.05];

ax.FontSize = 11;
ax.FontWeight = 'bold';
ax.LineWidth = 1.3;

%% ---------- Grid ----------
grid on;

ax.GridColor = [0.50 0.50 0.50];
ax.GridAlpha = 0.30;
ax.Layer = 'top';

ylim([0 105]);

%% ---------- Values Above Bars ----------
for i = 1:3

    text(i, ...
         performanceValues(i) + 3, ...
         sprintf('%.2f%%', performanceValues(i)), ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'bottom', ...
         'FontSize', 12, ...
         'FontWeight', 'bold', ...
         'Color', [0.05 0.05 0.05]);

end

%% ---------- Final Figure Appearance ----------
set(gcf, 'InvertHardcopy', 'off');