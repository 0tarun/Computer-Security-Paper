%% Step 6b: Detection Model - Threshold + SVM Classifier
clear; clc; close all;

% ---------- Load dataset from Step 6a ----------
load('detection_dataset.mat');   % loads features_baseline, features_attack

numTrials = size(features_baseline, 1);

% ---------- Prepare combined dataset ----------
% Labels: 0 = Normal (baseline), 1 = Attack (coordinated)
X = [features_baseline; features_attack];           % 200 x 3
y = [zeros(numTrials,1); ones(numTrials,1)];         % 200 x 1

featureNames = {'Phase Correlation', 'Eigenvalue Spread', 'Doppler Residual'};

%% ========== METHOD 1: Simple Threshold Classifier ==========
% Using Eigenvalue Spread (Feature 2) as the single discriminating feature
threshold_ES = (mean(features_baseline(:,2)) + mean(features_attack(:,2))) / 2;

fprintf('===========================================\n');
fprintf(' METHOD 1: Threshold Classifier (Eigenvalue Spread)\n');
fprintf('===========================================\n');
fprintf('Threshold value: %.2f\n', threshold_ES);

predictions_threshold = double(X(:,2) > threshold_ES);  % 1 = flagged as attack

% Confusion matrix components
TP = sum(predictions_threshold == 1 & y == 1);
TN = sum(predictions_threshold == 0 & y == 0);
FP = sum(predictions_threshold == 1 & y == 0);
FN = sum(predictions_threshold == 0 & y == 1);

accuracy_threshold = (TP + TN) / length(y) * 100;
detectionRate_threshold = TP / (TP + FN) * 100;
falseAlarmRate_threshold = FP / (FP + TN) * 100;

fprintf('Accuracy          : %.2f%%\n', accuracy_threshold);
fprintf('Detection Rate     : %.2f%%\n', detectionRate_threshold);
fprintf('False Alarm Rate   : %.2f%%\n', falseAlarmRate_threshold);
fprintf('===========================================\n\n');

%% ========== METHOD 2: SVM Classifier (all 3 features) ==========
fprintf('===========================================\n');
fprintf(' METHOD 2: SVM Classifier (3 features)\n');
fprintf('===========================================\n');

% Split into train (70%) / test (30%)
rng(1);  % reproducibility
cv = cvpartition(y, 'HoldOut', 0.3);
Xtrain = X(training(cv), :);
ytrain = y(training(cv));
Xtest  = X(test(cv), :);
ytest  = y(test(cv));

% Standardize features (important since scales differ hugely)
svmModel = fitcsvm(Xtrain, ytrain, 'KernelFunction', 'linear', ...
    'Standardize', true);

predictions_svm = predict(svmModel, Xtest);

TP2 = sum(predictions_svm == 1 & ytest == 1);
TN2 = sum(predictions_svm == 0 & ytest == 0);
FP2 = sum(predictions_svm == 1 & ytest == 0);
FN2 = sum(predictions_svm == 0 & ytest == 1);

accuracy_svm = (TP2 + TN2) / length(ytest) * 100;
detectionRate_svm = TP2 / (TP2 + FN2) * 100;
falseAlarmRate_svm = FP2 / (FP2 + TN2) * 100;

fprintf('Test set size      : %d samples\n', length(ytest));
fprintf('Accuracy           : %.2f%%\n', accuracy_svm);
fprintf('Detection Rate     : %.2f%%\n', detectionRate_svm);
fprintf('False Alarm Rate   : %.2f%%\n', falseAlarmRate_svm);
fprintf('===========================================\n\n');

%% ========== Visualization 1: Confusion Matrices ==========
figure('Color', 'w', 'Position', [100 100 900 400]);

subplot(1,2,1);
cm1 = confusionchart(y, predictions_threshold, ...
    'Title', sprintf('Threshold Classifier (Acc: %.1f%%)', accuracy_threshold));
cm1.RowSummary = 'row-normalized';

subplot(1,2,2);
cm2 = confusionchart(ytest, predictions_svm, ...
    'Title', sprintf('SVM Classifier (Acc: %.1f%%)', accuracy_svm));
cm2.RowSummary = 'row-normalized';

%% ========== Visualization 2: Decision Boundary (SVM, 2 features) ==========
% Retrain SVM on just 2 features (PC and ES) for visualization
svmModel2D = fitcsvm(X(:,[1 2]), y, 'KernelFunction', 'linear', 'Standardize', true);

figure('Color', 'w', 'Position', [1050 100 650 550]);
gscatter(X(:,1), X(:,2), y, [0.2 0.7 0.3; 0.8 0.2 0.2], 'o', 8);

hold on;
% Plot decision boundary
xlims = xlim; ylims = ylim;
[xGrid, yGrid] = meshgrid(linspace(xlims(1), xlims(2), 100), ...
                            linspace(ylims(1), ylims(2), 100));
gridPoints = [xGrid(:), yGrid(:)];
[~, score] = predict(svmModel2D, gridPoints);
contour(xGrid, yGrid, reshape(score(:,2), size(xGrid)), [0 0], ...
    'k-', 'LineWidth', 2, 'DisplayName', 'Decision Boundary');

xlabel('Phase Correlation', 'FontWeight', 'bold');
ylabel('Eigenvalue Spread', 'FontWeight', 'bold');
title('SVM Decision Boundary: Baseline vs Attack', 'FontWeight', 'bold', 'FontSize', 13);
legend({'Baseline', 'Attack', 'Decision Boundary'}, 'Location', 'best');
grid on;

%% ========== Comparison Bar Chart ==========
figure('Color', 'w', 'Position', [100 550 600 400]);
methods = {'Threshold', 'SVM'};
accVals = [accuracy_threshold, accuracy_svm];
drVals  = [detectionRate_threshold, detectionRate_svm];
farVals = [falseAlarmRate_threshold, falseAlarmRate_svm];

b = bar([accVals; drVals; farVals]');
set(gca, 'XTickLabel', methods, 'FontSize', 11);
ylabel('Percentage (%)', 'FontWeight', 'bold');
legend({'Accuracy', 'Detection Rate', 'False Alarm Rate'}, 'Location', 'best');
title('Detector Performance Comparison', 'FontWeight', 'bold', 'FontSize', 13);
grid on;
ylim([0 105]);