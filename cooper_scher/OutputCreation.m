% Roman Ramirez, rr8rk@virginia.edu
% BME 3636, Final Research Project
% OutputCreation.m (Cooper Scher's Code)

% This is a slight modified version of Cooper Scher's code, where I moved
% all his code files into one file, and turned the MATLAB script into a
% function with input base_dir (as a root directory), num_neurons
% (simulation neuron count used to load data), and input_matrix (which was
% used to change his exemplars to the BME 3636 ASCII training set).

function OutputCreation(base_dir, num_neurons, input_matrix)
    %%% Setup
    
    % Prototype Creation
    seed = rng("shuffle");
    numSuperCategories = 3;
    numPrototypes = 9;
    prototypesPerCategory = numPrototypes/numSuperCategories;
    numInputLines = 390;
    LinesPerCategory = [45, 5, 30, 10, 15, 15];
    Prototypes = zeros(numInputLines,numPrototypes);
    
    % Create Prototypes
    startingPoint = 0;
    for i = 1 : numPrototypes
        Lines = LinesPerCategory((ceil(i/prototypesPerCategory) - 1)*2 + 1);
        Prototypes(startingPoint + 1:startingPoint + Lines, i) = 1;
        startingPoint = startingPoint + Lines;
        if (mod(i,numPrototypes/numSuperCategories) == 0)
            Lines = LinesPerCategory((ceil(i/prototypesPerCategory) - 1)*2 + 2);
            for j = i - prototypesPerCategory + 1 : i
                for k = 1 : prototypesPerCategory + 1
                    if (mod(j,3) + 1 ~= k)
                         Prototypes(startingPoint + 1 + Lines * (k-1):startingPoint + k * Lines,j) = 1;
                    end
                end
            end
         startingPoint = startingPoint + (nchoosek(prototypesPerCategory,2) + 1) * Lines;
        end
    end
    
    
    
    % Create Exemplar as Copies of Prototypes
    numExemplars = 225;
    categoryProbabilities = [1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9,1/9]; %B1
    %categoryProbabilities = [29/225,29/225,28/225,1/9,1/9,1/9,22/225,21/225,21/225]; %B2
    %categoryProbabilities = [41/225,39/225,34/225,27/225,1/9,20/225,14/225,13/225,12/225]; %B3
    numCategories = numExemplars .* categoryProbabilities;
    Exemplars = zeros(numInputLines,numExemplars);
    
    for i = 0 : length(categoryProbabilities) - 1
        for j = sum(numCategories(1:i)) + 1 : sum(numCategories(1:i + 1))
            Exemplars(:,j) = Prototypes(:,i+1);
        end
    end

    if ~isnan(input_matrix)
        Exemplars = input_matrix;
    end
    
    
    % Perturb Exemplars with Noise
    occlusion = 40/60; % off-noise
    onIndices = zeros(60,9); 
    
    for i = 1 : numPrototypes
        count = 1;
        for j = 1 : numInputLines
            if (Prototypes(j,i) == 1)
                onIndices(count,i) = j;
                count = count + 1;
            end
        end
    end
    
    
    for i = 1 : length(numCategories)
        for j = 1 : numCategories(i)
            offIndices = randperm(60,occlusion*60);
            for k = 1 : occlusion*60
                Exemplars(onIndices(offIndices(k),i),sum(numCategories(1:i-1)) + j) = 0;
            end
        end
    end
    
    expectationRandomVar = mean(Exemplars');  % Creation of E[X] using empirical mean
    
    % Simulate Image of Exemplars
    image(200*Exemplars);
    
    %%% Parameters
    
    % Network Parameters
    neuronCount = num_neurons; % number of postsynaptic neurons
    firingRateLimit = 0.05;  % upper bound firing rate at which synaptogenesis stops
    firingRateLimitLower = 0.045; % lower firing rate at which synaptogenesis restarts after stopping
    inhibitionLimit = 0.05; % percent of neurons allowed through by the competitive inhibition (ranked by excitation)
    epsilon = 0.0003; % rate constant for moving averager that affects weight values
    alpha = 0.99^(1/100); % rate constant for moving average that determines the firing rate
    gamma = 0.00001; % probability to randomly generate synapse between an available presynaptic and postsynaptic neuron
    initialConnections = 1; % initial number of random synapses between presynaptic and postsynaptic neurons
    initialSynapticWeight = 0.3; % initial weight value of synapses
    sheddingThreshold = 0.2; % weight value at which synapses get shed
    scalingExpectedRandomVariable = 1; % scaling for the E[X] regularization term
    
    % Training Parameters
    epochsPresented = 100; % number of times the entire set of inputs are shown to the network
    stabilityCriterion = 2000; % number of epochs with no shedding required for a neuron to be stable
    stabilityPercentage = 0.9; % percent of neurons stable for defined convergence
    samplingRate = 10; % frequency (in terms of number of epochs) for which data will be sampled 
    
    
    % Neuron Vectors
    neuronFires = false(neuronCount,1); % Binary vector of neurons firing: Z(t)
    neuronAverageFiringRate = zeros(neuronCount,1); % Vector of neuron average firing rate: Zbar(t)
    neuronExcitation = zeros(neuronCount,1); % Vector of neuron excitation: Y(t)
    weightVector = zeros(neuronCount,numInputLines,1);  % Vector of synaptic weights: w(t)
    neuronConnections = false(neuronCount,numInputLines,1); % Binary vector of synaptic connections: c(t)
    
    % Neuron Tracking Vectors
    sheddingChange = zeros(epochsPresented*numExemplars,1);
    sheddingTracker = zeros(neuronCount,1);
    sheddingOverTime = false(neuronCount,epochsPresented*numExemplars);
    synaptogenesisChange = zeros(epochsPresented*numExemplars,1);
    neuronAverageFiringRateTracker = zeros(neuronCount,epochsPresented + 1);
    weightVectorTracker = zeros(neuronCount,numInputLines,epochsPresented/samplingRate + 1);  
    neuronConnectionsTracker = false(neuronCount,numInputLines,epochsPresented/samplingRate + 1);
    
    % Miscallaneous Variables for Instantiation of Program
    bernoulliRandomVariables = false(neuronCount,numInputLines); % Used to generate new synapses probabilistically
    rateLimitCheck = false(neuronCount,1);
    synaptogenesisIndices = 1;
    scaling = 1;
    expectationRandomVar = scalingExpectedRandomVariable * expectationRandomVar;
    
    % Initial Connections Setup
    for i = 1 : neuronCount
        randSynapse = randperm(numInputLines,initialConnections);
        for j = 1 : length(randSynapse)
            weightVector(i,randSynapse(j)) = initialSynapticWeight + 0.001*rand(1);
            neuronConnections(i,randSynapse(j)) = 1;
        end
    end
    weightVectorTracker(:,:,1) = weightVector(:,:);
    
    
    %%% Network Simulation
    
    tic
    for i = 1 : epochsPresented
        disp(i)
        % Stability Condition Check 
        %(Convergence as defined by stabilitycriterion number of epochs with no shedding)
        if (i > stabilityCriterion)
            if (sum(sheddingTracker > stabilityCriterion*numExemplars) >= stabilityPercentage * neuronCount)
                break;
            end
        end
        
        % Timing Output for checking Model Efficiency
        if (mod(i,1000) == 0)
            disp(i);
            toc;
        end
            
            Indices = randperm(numExemplars,numExemplars); % permute exemplars that are shown to the model per epoch
            
            
            for k = 1 : numExemplars % Cycle through each exemplar following a random permutation of their order
                    
                % Determine Excitation and Firing Using Competitive Network
                neuronExcitation = weightVector(:,:) * Exemplars(:,Indices(k));
                sortedExcitation = sort(neuronExcitation);
                inhibitionThreshold = sortedExcitation(end-round(neuronCount * inhibitionLimit * scaling)); % Determine minimum y value above competitive threshold
                competitiveNeurons = neuronExcitation > inhibitionThreshold; 
                neuronFires = competitiveNeurons;
                
                % Associative Modification
                weightVector(:,:) = weightVector(:,:) + ((Exemplars(:,Indices(k))' - expectationRandomVar - weightVector(:,:)) .* (neuronExcitation./sum(weightVector(:,:),2)) * epsilon .* neuronConnections(:,:)) .* competitiveNeurons;  % Wij(t+1) = Wij(t) + (Xi - E[Xi] - wij(t)) * Yj/sum(wj) * Cij * Winnerj
                
                % Firing Rate Update
                neuronAverageFiringRate = neuronAverageFiringRate * alpha + (1-alpha) * neuronFires;
                
                % Synaptogenesis
                bernoulliRandomVariables(synaptogenesisIndices) = 0;
                synaptogenesisIndices = randperm(neuronCount*numInputLines,poissrnd(numInputLines*neuronCount*gamma));
                % Poisson intensity is the number of input lines multiplied by
                % gamma, the probability of generating a new synapse for a
                % given neuron and input pair.
                bernoulliRandomVariables(synaptogenesisIndices) = 1;
                LowerLimitCheck =  (neuronAverageFiringRate(:) .* abs(rateLimitCheck-1)) > (firingRateLimitLower * scaling);
                % Checks if the neuron has previously been above the firing
                % rate limit and is currently above the lower limit, which will
                % prevent it from firing
                rateLimitCheck = neuronAverageFiringRate(:) < (firingRateLimit * scaling) - LowerLimitCheck;
                % Checks if the neuron is above the firing rate limit 
                synaptogenesis = bernoulliRandomVariables .* rateLimitCheck .* abs((neuronConnections(:,:) - 1)); 
                % Using the randomly generated new synapses to check if the
                % postsynaptic neurons are eligible for synaptogenesis with the
                % incoming axon, eliminating ineligible postsynaptic neurons.
                neuronConnections(:,:) = neuronConnections(:,:) + synaptogenesis; 
                weightVector(:,:) = weightVector(:,:) + initialSynapticWeight * synaptogenesis; 
                
                % Shedding Rule
                shedding = (weightVector(:,:) < sheddingThreshold) .* neuronConnections(:,:); 
                % Checks for synapses that have weight values below the
                % shedding threshold to be discarded
                neuronConnections(:,:) = neuronConnections(:,:) - shedding; 
                weightVector(:,:) =  weightVector(:,:) .* neuronConnections(:,:); 
    
                % Tracking Vectors (cycle timescale)
                sheddingChange(k + 1 + (i-1) * numExemplars) = sum(sum(shedding));
                synaptogenesisChange(k + 1 + (i-1) * numExemplars) = sum(sum(synaptogenesis));
                sheddingTracker = sheddingTracker .* (sum(shedding,2) == 0) + (sum(shedding,2) == 0);
                sheddingOverTime(:,k + 1 + (i-1) * numExemplars) = (sum(shedding,2) > 0);
            end
        
        
        % Tracking Vectors (epoch timescale)
          neuronAverageFiringRateTracker(:,i) = neuronAverageFiringRate;
          if (mod(i,samplingRate) == 0)
            weightVectorTracker(:,:,i/samplingRate + 1) = weightVector(:,:);
            neuronConnectionsTracker(:,:,i/samplingRate + 1) = neuronConnections(:,:);
          end
    end
    
    % Create Output Statistics
    clear inhibition; 
    clear categories;
    clear indices;
    clear Allocation;
    [inhibition,categories,indices,Allocation] = allocation(neuronCount,Prototypes,Exemplars,weightVector,numCategories,inhibitionLimit);
    % covMatrixNeurons = createCovMatrix(Exemplars,numInputLines,neuronCount,neuronConnections);
    
    mkdir(base_dir);
    Subpath = [base_dir '/' num2str(neuronCount) '/'];
    mkdir(Subpath);
    
    save([Subpath 'data.mat'])

end











