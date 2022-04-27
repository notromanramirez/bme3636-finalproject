% Roman Ramirez, rr8rk@virginia.edu
% BME 3636, Final Research Project
% rr8rk_DataAnalysis.m

% This is MATLAB code that I used to do some initial graphical modeling of
% Cooper Scher's adaptive synaptogenesis program.

load('rr8rk_results.mat');
addpath('helper\')

%% PLOTTING WEIGHT VECTOR

wFigure = figure;
imagesc(weightVector);
colorbar;
title('Weight Vector');
ylabel('Neuron');
xlabel('Input Lines');
saveas(wFigure, ['figures/', getVarName(wFigure)], 'png');

%% PLOTTING: ACTIVATION?

z = weightVector * Exemplars > alpha;
zFigure = figure;
imagesc(z);
colorbar;
title('Neuron Activation?');
ylabel('Neuron');
xlabel('');
saveas(zFigure, ['figures/', getVarName(zFigure)], 'png');

%% PLOTTING NEURON AVERAGE FIRING RATE OVER TIME

neuronFiringRateTrackerFigure = figure;
imagesc(neuronAverageFiringRateTracker(:,1:100));
colorbar;
title('Firing Rate over Time');
xlabel('Timestep');
ylabel('Neuron');
saveas(neuronFiringRateTrackerFigure, ...
    ['figures/', getVarName(neuronFiringRateTrackerFigure)], 'png');


%% PLOTTING: NEURON CONNECTIONS

neuronConnectionsFigure = figure;
imagesc(neuronConnections);
colorbar;
title('Neuron Connections');
xlabel('Exemplar');
ylabel('Neuron');


%% PLOTTING: INPUT-SET VECTOR

xFigure = figure;
imagesc(Prototypes);
colorbar;
title('Prototypes');
xlabel('Category');
ylabel('Exemplar?');
saveas(xFigure, ...
    ['figures/', getVarName(xFigure)], 'png');

%% PLOTTING: PROTOTYPES AND EXEMPLARS

prototypesExemplarsFigure = figure;
subplot(1,2,1);
imagesc(Prototypes);
title('Prototypes');
xlabel('Category');
ylabel('?');
subplot(1,2,2);
imagesc(Exemplars);
title('Exemplars');
xlabel('?');
ylabel('?');

saveas(prototypesExemplarsFigure, ...
    ['figures/', getVarName(prototypesExemplarsFigure)], 'png');