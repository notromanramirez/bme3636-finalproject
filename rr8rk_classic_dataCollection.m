% Roman Ramirez, rr8rk@virginia.edu
% BME 3636, Final Research Project
% rr8rk_classic_dataCollection.m

% This is MATLAB code that I used to generate .mat results over many
% different receptivity thresholds, number of neurons, and trials. The
% second part of this code was used to generate data from 1 neuron to 120
% neurons.

THRESHOLDS = [0.05 0.1 0.2];
NEURONS = [8 16 32];
TRIALS = 1:6;

for i=1:length(THRESHOLDS)
    for j=1:length(NEURONS)
        for k=1:length(TRIALS)

           runSynaptogenesisModel(THRESHOLDS(i), NEURONS(j), TRIALS(k));

        end
    end
end

%% DATA COLLECTION FOR FINAL PROJECT

% runSynaptogenesisModel(0.2, 120, 1);
runSynaptogenesisModel(0.3, 120, 1);