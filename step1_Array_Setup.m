%% CRPA Array Geometry - Dark Text, Axis Labels & Annotations

fig = figure( ...
    'Color', 'w', ...
    'Position', [100 100 900 650]);

% Plot CRPA array
viewArray(array, ...
    'ShowIndex', 'All', ...
    'ShowNormals', true, ...
    'Title', '4-Element CRPA Array Geometry');

drawnow;

%% 1. Find ALL axes in the figure
allAxes = findall(fig, 'Type', 'axes');

for i = 1:length(allAxes)

    ax = allAxes(i);

    % White background
    ax.Color = 'w';

    % Axis lines -> BLACK
    ax.XColor = 'k';
    ax.YColor = 'k';
    ax.ZColor = 'k';

    % Tick labels -> BLACK
    ax.FontSize = 13;
    ax.FontWeight = 'bold';

    % Make sure axes are visible
    ax.Box = 'on';

    % Grid
    grid(ax, 'on');
    ax.GridColor = [0.3 0.3 0.3];
    ax.GridAlpha = 0.35;

    %% Axis labels
    xlabel(ax, 'X', ...
        'Color', 'k', ...
        'FontSize', 14, ...
        'FontWeight', 'bold');

    ylabel(ax, 'Y', ...
        'Color', 'k', ...
        'FontSize', 14, ...
        'FontWeight', 'bold');

    zlabel(ax, 'Z', ...
        'Color', 'k', ...
        'FontSize', 14, ...
        'FontWeight', 'bold');

end

%% 2. Make EVERY text object black
allText = findall(fig, 'Type', 'text');

for i = 1:length(allText)

    set(allText(i), ...
        'Color', 'k', ...
        'FontWeight', 'bold', ...
        'FontSize', 12);

end

%% 3. Force title to BLACK
for i = 1:length(allAxes)

    ax = allAxes(i);

    titleObj = ax.Title;

    if isgraphics(titleObj)
        set(titleObj, ...
            'Color', 'k', ...
            'FontSize', 16, ...
            'FontWeight', 'bold');
    end

end

%% 4. Make X/Y/Z axis rulers dark
for i = 1:length(allAxes)

    ax = allAxes(i);

    % Explicitly set ruler colors
    ax.XAxis.Color = 'k';
    ax.YAxis.Color = 'k';
    ax.ZAxis.Color = 'k';

    % Make tick labels bold
    ax.XAxis.FontSize = 13;
    ax.YAxis.FontSize = 13;
    ax.ZAxis.FontSize = 13;

end

%% 5. Make annotation objects black
allObjects = findall(fig);

for i = 1:length(allObjects)

    try
        if isprop(allObjects(i), 'Color')
            allObjects(i).Color = 'k';
        end
    catch
    end

end

%% 6. Restore white figure background
fig.Color = 'w';

%% 7. Use OpenGL renderer
set(fig, 'Renderer', 'opengl');

drawnow;
