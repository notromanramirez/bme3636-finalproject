% Roman Ramirez, rr8rk@virginia.edu
% BME 3636, Final Research Project
% rr8rk_classic_dataAnalysis.m

% This is MATLAB code that I used to analyze the ASCII input set under the
% BME 3636 provided adaptive synaptogenesis program.

clear
THRESHOLDS = [0.05 0.1 0.2];
NEURONS = [8 16 32];
TRIALS = 1:6;
BASE_DIR = [pwd, '/rr8rk_classics_results'];

addpath('helper/');

%% ACTIVATION MATRIX FOR EACH LETTER

letters = ['abcdefghijklmnopqrstuvwxyz'];
W = load([BASE_DIR '/0.3_120_1/finalWeights.mat']).W;
X = load('helper/lowercase.mat').ascii;
Z = W * X;
Z_act = Z > 1.0;

asciiXFigure = figure;
for i=1:size(X, 2)
    subplot(4, 7, i);
    imagesc(reshape(X(:,i), [12 10]));
    title(num2str(letters(i)));
    colormap("hot");
    
end

sgtitle('ASCII Input Set', 'FontSize', 10, 'FontName', 'Arial', 'FontWeight', 'bold');

asciiZFigure = figure;
for i=1:size(X, 2)

    subplot(4, 7, i);
    imagesc(reshape(Z(:,i), [12 10]));
    title(num2str(letters(i)));
    colormap("hot");
    
end

sgtitle('X * W from Classic Model', 'FontSize', 10, 'FontName', 'Arial', 'FontWeight', 'bold');

asciiZactFigure = figure;
for i=1:size(X, 2)

    subplot(4, 7, i);
    imagesc(reshape(Z_act(:,i), [12 10]));
    title(num2str(letters(i)));
    colormap("hot");
    
end

disp("Entropy of X: "+ num2str(H(X))     + " bits");
disp("Entropy of Z from Classic Model: "+ num2str(H(Z_act)) + " bits");

sgtitle('Z from Classic Model', 'FontSize', 10, 'FontName', 'Arial', 'FontWeight', 'bold');

saveas(asciiXFigure, 'figures/asciiXFigure', 'png');
saveas(asciiZFigure, 'figures/asciiZFigure', 'png');
saveas(asciiZactFigure, 'figures/asciiZactFigure', 'png');

%% FINDING MEAN NEURON FIRINGS

meanFiringsTable = table( ...
    'Size', [length(THRESHOLDS) * length(NEURONS), 4], ...
    'VariableTypes', ["double", "double", "double", "double"], ...
    'VariableNames', ["Threshold", "Neurons", "Average Firing", "STD Firing"]);

n = 1;
for i=1:length(THRESHOLDS)
    for j=1:length(NEURONS)

        neuronFirings = zeros(1, length(TRIALS));

        for k=1:length(TRIALS)
            % disp(getPath(i, j, k))
            load([BASE_DIR, '/', getPath(i, j, k), '/', 'meanFirings.mat']); % to meanFirings
            neuronFirings(k) = mean(meanFirings(:,end));
        end
        % disp(neuronFirings)
        meanFiringsTable(n,:) = {THRESHOLDS(i), NEURONS(j), mean(neuronFirings), std(neuronFirings)};
        n = n + 1;
    end
end

writetable(meanFiringsTable, [BASE_DIR, '/tables/', 'meanFiringsTable.csv'])
disp(meanFiringsTable);

clearvars i j k n meanFirings neuronFirings

%% HISTOGRAM OF AVERAGE NEURON FIRINGS

clf
hold on
xFormatting = string("\theta = " + meanFiringsTable{:,1})' + ", N = " + string(meanFiringsTable{:,2})';
x = categorical(xFormatting);
x = reordercats(x, xFormatting);
y = meanFiringsTable{:,3}';
stds = meanFiringsTable{:,4}';
figHistogram = bar(x, y);
er = errorbar(x, y, -stds, stds);
er.Color = [0, 0, 0];
er.LineStyle = 'none';

title("Histogram of Average Neuron Firings")
xlabel("Parameters");
ylabel("Average Neuron Firing");

hold off

saveas(figHistogram, [BASE_DIR, '/images/', 'histogram'], 'png');

clearvars x y er stds

%% FINDING AVERAGE INTERNAL EXCITATIONS

data = struct;

for i=1:length(THRESHOLDS)
    for j=1:length(NEURONS)
        for k=1:length(TRIALS)

            load([BASE_DIR, '/', getPath(i, j, k), '/', 'excitation.mat']); % to excitation
            load([BASE_DIR, '/', getPath(i, j, k), '/', 'finalWeights.mat']); % to W

            path = ['m', getPath(i,j,k)];
            path = path(path~='.');
            
            data.(path) = struct;
            data.(path).excitation = excitation(:,end);
            data.(path).W = W;
        end
    end
end

%% MAKING HISTOGRAMS FOR AVERAGE INTERNAL EXCITATION

clf
n = 1;

thresholdAreaRatios = zeros(length(THRESHOLDS), length(NEURONS));

for i=1:length(THRESHOLDS)
    for j=1:length(NEURONS)

        allExcitations = [];

        for k=1:length(TRIALS)

            path = ['m', getPath(i,j,k)];
            path = path(path~='.');

            allExcitations = [allExcitations; data.(path).excitation];

        end
        subplot(length(THRESHOLDS), length(NEURONS), n);
        histogram(allExcitations);
        title("\theta = " + string(THRESHOLDS(i)) + ", N = " + string(NEURONS(j)));
        xlabel("Average Excitation");
        ylabel("Frequency");
        grid on

        thresholdAreaRatios(n) = sum(allExcitations(allExcitations < 1.0)) ./ length(allExcitations);

        n = n + 1;
    end
end

thresholdAreaRatios = thresholdAreaRatios';
disp(thresholdAreaRatios);

%% DEBUGGING DISPLAYING ALL HEATMAPS

load('lowercase.mat')
clf
n = 1;

for i=1:length(THRESHOLDS)
    for j=1:length(NEURONS)

        allMappings = [];

        for k=1:length(TRIALS)
            
            path = ['m', getPath(i,j,k)];
            path = path(path~='.');

            data.(path).Z = data.(path).W' * ascii > 1.0; % This is the firing threshold (=1.0), not the receptivity threshold
            data.(path).letterPerNeuron = sum(data.(path).Z, 2);
            
            allMappings = [allMappings; data.(path).letterPerNeuron];
        end
        subplot(length(THRESHOLDS), length(NEURONS), n);
        histogram(allMappings);
        title("\theta = " + string(THRESHOLDS(i)) + ", N = " + string(NEURONS(j)));
        xlabel("N-to-One Mappings");
        ylabel("Frequency");
        grid on

        n = n + 1;
    end
end

clearvars n 