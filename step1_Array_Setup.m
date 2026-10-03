%% CRPA Array Geometry - Presentation Style

fig = figure( ...
    'Color', [0.05 0.05 0.07], ...
    'Position', [100 100 900 650]);

viewArray(array, ...
    'ShowIndex', 'All', ...
    'ShowNormals', true, ...
    'Title', '4-Element CRPA Array Geometry');

ax = gca;

% Dark background
ax.Color = [0.05 0.05 0.07];

% White axis text
ax.XColor = 'w';
ax.YColor = 'w';
ax.ZColor = 'w';

% Larger readable text
ax.FontSize = 13;
ax.FontWeight = 'bold';

% Grid
grid on;
ax.GridColor = [0.4 0.4 0.4];
ax.GridAlpha = 0.35;

% Improve figure layout
set(fig, 'Renderer', 'opengl');