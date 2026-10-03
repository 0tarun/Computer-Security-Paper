%% Step 2: Genuine Satellite Signals - Array Response Pattern
clear; clc; close all;

fc = 1575.42e6;
c = physconst('LightSpeed');
lambda = c/fc;
array = phased.ULA('NumElements', 4, 'ElementSpacing', lambda/2);

satellite_angles = [30 60 -20 80; 40 50 30 60];

fprintf('===========================================\n');
fprintf(' STEP 2: Genuine Satellite Directions\n');
fprintf('===========================================\n');
for i = 1:4
    fprintf('Satellite %d: Azimuth = %3d°, Elevation = %2d°\n', ...
        i, satellite_angles(1,i), satellite_angles(2,i));
end
fprintf('===========================================\n\n');

figure('Color', 'w', 'Position', [100 100 700 600]);
pattern(array, fc, -180:180, 0, 'PropagationSpeed', c, ...
    'Type', 'powerdb', 'CoordinateSystem', 'polar');
title('Array Response Pattern (No Beamforming Yet)', ...
    'FontSize', 13, 'FontWeight', 'bold');
colormap(gca, 'parula');