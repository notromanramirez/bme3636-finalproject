% Roman Ramirez, rr8rk@virginia.edu
% BME 3636, Final Research Project
% dataAnalysis.m

% this is MATLAB code that I used to analyze Cooper Scher's neuron
% competition network across different simulation neuron counts.

clear;

FONT = 'Times New Roman';
NUM_NEURONS = 1:120;
BASE_COOPER_DIRECTORY = 'rr8rk_results/';
BASE_ASCII_DIRECTORY = 'rr8rk_ascii_results/';
SAVEPATH = 'figures/';

addpath('rr8rk_results/');
addpath('rr8rk_ascii_results/');
addpath('rr8rk_ascii_results_anc');
addpath('helper/');

data_cooper = struct;
data_ascii = struct;

ascii = load('helper/lowercase.mat').ascii;

for i=NUM_NEURONS
    loading_cooper = load([BASE_COOPER_DIRECTORY num2str(i) '/data.mat']);
    data_cooper.("n" + num2str(loading_cooper.neuronCount)) = loading_cooper;

    loading_ascii = load([BASE_ASCII_DIRECTORY num2str(i) '/data.mat']);
    data_ascii.("n" + num2str(loading_ascii.neuronCount)) = loading_ascii;

end


%% ENTROPY

Hx_neurons_cooper = zeros(1, length(NUM_NEURONS));
Hz_neurons_cooper = zeros(1, length(NUM_NEURONS));

Hx_neurons_ascii = zeros(1, length(NUM_NEURONS));
Hz_neurons_ascii = zeros(1, length(NUM_NEURONS));

for i=NUM_NEURONS

    dotIndex = "n" + num2str(i);
    data_cooper.(dotIndex).Hx = H(data_cooper.(dotIndex).Exemplars);
    data_cooper.(dotIndex).z = data_cooper.(dotIndex).weightVectorTracker(:,:,end) * data_cooper.(dotIndex).Exemplars > data_cooper.(dotIndex).alpha;
    data_cooper.(dotIndex).Hz = H(data_cooper.(dotIndex).z);

    Hx_neurons_cooper(i) = data_cooper.(dotIndex).Hx;
    Hz_neurons_cooper(i) = data_cooper.(dotIndex).Hz;

    data_ascii.(dotIndex).Hx = H(data_ascii.(dotIndex).Exemplars);
    data_ascii.(dotIndex).z = data_ascii.(dotIndex).weightVectorTracker(:,:,end) * data_ascii.(dotIndex).Exemplars > data_ascii.(dotIndex).alpha;
    data_ascii.(dotIndex).Hz = H(data_ascii.(dotIndex).z);

    Hx_neurons_ascii(i) = data_ascii.(dotIndex).Hx;
    Hz_neurons_ascii(i) = data_ascii.(dotIndex).Hz;

end

entropyFigure = figure;
hold on
plot(NUM_NEURONS, Hx_neurons_ascii);
plot(NUM_NEURONS, Hz_neurons_ascii);
legend(["Hx", "Hz"], 'location', 'southeast');
title('Present Neuron Competition, Entropy vs. Simulation Neuron Count');
xlabel('Simulation Neuron Count');
ylabel('Entropy (bits)');
set(gca, 'FontName', FONT);
grid on
hold off

saveas(entropyFigure, [SAVEPATH getVarName(entropyFigure)], 'png');

%% Z FIGURE VERSION 2

letters = 'abcdefghijklmnopqrstuvwxyz';

cooperAsciiZFigure2 = figure;
X = data_ascii.n120.Exemplars(1:120, 1:26);
W = data_ascii.n120.weightVector(:,1:26);
Z = X * W';
Z_act = Z > 1.0;

for i=1:size(X, 2)

    subplot(4, 7, i);
    imagesc(reshape(Z(:,i), [12 10]))
    % title(num2str(letters(i)));
    colormap('hot');

end

sgtitle('Y, Present Competitive Neuron Model', 'FontSize', 10, 'FontName', FONT, 'FontWeight', 'bold');

saveas(cooperAsciiZFigure2, [SAVEPATH getVarName(cooperAsciiZFigure2)], 'png');


disp("Entropy of Z from Competitive Neuron Model: " + num2str(H(Z_act)) + " bits");

%% DISPLAYING THE ACTIVATION MATRIX FOR EACH OF THE LETTERS

letters = 'abcdefghijklmnopqrstuvwxyz';

cooperAsciiZFigure = figure;
for i=1:size(ascii, 2)

    subplot(4, 7, i);
    data_ascii.(dotIndex).z = data_ascii.(dotIndex).weightVectorTracker(:,:,end) * data_ascii.(dotIndex).Exemplars;
    imagesc(reshape(data_ascii.n120.z(:,i), [12, 10]));
    % title(num2str(letters(i)));
    colormap('hot');
    

end

set(gca, 'FontName', FONT);
saveas(cooperAsciiZFigure, [SAVEPATH getVarName(cooperAsciiZFigure)], 'png');


%% AVERAGE FIRING RATE VS. NUMBER OF NEURONS

averageFiringRateTracker = zeros(length(NUM_NEURONS), 101);
for i=NUM_NEURONS
   averageFiringRateTracker(i,:) = mean(data_cooper.("n" + num2str(i)).neuronAverageFiringRateTracker);
end

afrtFigure = figure;
imagesc(averageFiringRateTracker(:,1:100));
title('Present Neuron Competition, Average Firing Rate vs. Neuron Count');
xlabel('Timestep');
ylabel('Simulation Neuron Count');
colorbar;
colormap('hot');
set(gca, 'FontName', FONT);
saveas(afrtFigure, [SAVEPATH getVarName(afrtFigure)], 'png');

%% NEURON EXCITATION VS. NUMBER OF NEURONS

neuronExcitation     = zeros(length(NUM_NEURONS), length(NUM_NEURONS));
averageExcitation    = zeros(length(NUM_NEURONS), length(NUM_NEURONS));

for i=NUM_NEURONS
    temp = data_cooper.("n" + num2str(i)).neuronExcitation';
    neuronExcitation(i,1:length(temp)) = temp;
    averageExcitation(i,1:length(temp)) = temp ./ i;
end

averageLogExcitation = log2(averageExcitation);

aeTitles   = ["Neuron Excitation", "Average Neuron Excitation", "Average Log Neuron Excitation"];

clearvars temp

neuronExcitationFigure = figure;
imagesc(neuronExcitation);
title('Neuron Excitation vs. Simulation Neuron Count');
xlabel('Excitation of Neuron_i');
ylabel('Simulation Neuron Count');
set(gca, 'FontName', FONT);
colorbar;
colormap('hot');

saveas(neuronExcitationFigure, [SAVEPATH getVarName(neuronExcitationFigure)], 'png');

neuronAverageExcitationFigure = figure;
imagesc(averageExcitation);
title('Average Neuron Excitation vs. Simulation Neuron Count');
xlabel('Excitation of Neuron_i');
ylabel('Simulation Neuron Count');
set(gca, 'FontName', FONT);
colorbar;
colormap('hot');

saveas(neuronAverageExcitationFigure, [SAVEPATH getVarName(neuronAverageExcitationFigure)], 'png');

neuronAverageLogExcitationFigure = figure;
imagesc(averageLogExcitation);
title('Average Log Neuron Excitation vs. Simulation Neuron Count');
xlabel('Excitation of Neuron_i');
ylabel('Simulation Neuron Count');
set(gca, 'FontName', FONT);
colorbar;
colormap('hot');

saveas(neuronAverageLogExcitationFigure, [SAVEPATH getVarName(neuronAverageLogExcitationFigure)], 'png');

%% ENERGY COST

energy_Hz_ascii = zeros(1, length(NUM_NEURONS));

for i=NUM_NEURONS
    dotIndex = "n" + num2str(i);
    energy_Hz_ascii(i) = data_ascii.(dotIndex).Hz ./ NUM_NEURONS(i);
    data_ascii.(dotIndex).energy_Hz_ascii = data_ascii.(dotIndex).Hz ./ NUM_NEURONS(i);
end

energyFigure = figure;
hold on
plot(NUM_NEURONS, energy_Hz_ascii);
title('Absent Neuron Competition, Energy Cost vs. Simulation Neuron Count');
xlabel('Simulation Neuron Count');
ylabel('Entropy per Cost (bits/neurons)');
set(gca, 'FontName', FONT);
grid on
hold off

saveas(energyFigure, [SAVEPATH getVarName(energyFigure)], 'png');
