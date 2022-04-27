function [inhibition,categories,indices,allocation] = allocation(neuronCount,Prototypes,Exemplars,weightVector,numCategories,firingRateLimit)

allocation = zeros(length(Prototypes(1,:)),1);
indices = zeros(neuronCount,length(Exemplars(1,:)));


for i = 1 : length(Exemplars(1,:))
    neuronExcitation(:,1) = weightVector(:,:) * Exemplars(:,i);
    sortedExcitation = sort(neuronExcitation(:,1));
    inhibitionThreshold = sortedExcitation(end-round(neuronCount * firingRateLimit));
    competitiveNeurons = neuronExcitation(:,1) > inhibitionThreshold;
    inhibition(i) = inhibitionThreshold;
    
    for l = 1 : neuronCount
        if (competitiveNeurons(l))
            indices(l,i) = 1;
        end
    end
end

count = 0;
for i = 1 : length(numCategories)
     allocation(i) = sum(sum( indices(:,count + 1 : count + numCategories(i))') > 1 );
     categories(i,:) = sum( indices(:,count + 1 : count + numCategories(i))') > 1 ;
     count = count + numCategories(i);
end
