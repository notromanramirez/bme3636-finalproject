% Roman Ramirez, rr8rk@virginia.edu
% BME 3636, Final Research Project
% dataCollection.m

% This MATLAB code was used to generate .mat results for Cooper Scher's
% neuron competition based on varying input training sets and simulation
% neuron counts.

%% ON COOPER'S EXEMPLAR DATASET
addpath('cooper_scher\');
BASE_DIRECTORY = 'rr8rk_results/'

for i_neurons = 1:120
    
   OutputCreation(BASE_DIRECTORY, i_neurons, nan);

end

%% ON THE ASCII DATASET, NEURON COMPETITION

addpath('cooper_scher\');
loading = load('helper\lowercase.mat');
for i_neurons = 1:120
    OutputCreation('rr8rk_ascii_results', i_neurons, loading.ascii);
end

%% ON THE ASCII DATASET, ABSENT NEURON COMPETITION

addpath('cooper_scher\');
loading = load('helper/lowercase.mat');
for i_neurons = 1:120
    OutputCreationANC('rr8rk_ascii_results_anc', i_neurons, loading.ascii);
end
