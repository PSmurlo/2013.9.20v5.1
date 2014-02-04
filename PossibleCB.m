function [CBworks]=PossibleCB(tablesPerQuad)
%Combiner Box Works eliminates combiner box sizes which do not
%work for the given table sizes.
%   tablesPerQuad is a vector of the number of tables found in one quad.
%   CBworks is a struct which holds a couple parameters *UPDATE*
%   *MUST REMOVE FOR LOOPS*
x=1;
for i = tablesPerQuad % vector of tables per quad for given DC:AC Ratio range
    possibleDim = [];
    for q = 1:i % for numbers smaller than the number of tables per quad
        if mod(i,q) == 0 % if even multiple
            possibleDim = horzcat(possibleDim,i/q); % list possible dimensions
        end
    end
    possibleDim = [possibleDim;fliplr(possibleDim)];%#ok<*AGROW>%#ok<*SAGROW>
    maxDim = size(possibleDim,2);
    CB.Strings = 8:8:64; % available combiner box sizes
    for j = 1:maxDim % cycle through possible dimensions
        qH = possibleDim(1,j);
        qW = possibleDim(2,j);
        CB=evenCB(CB.Strings,qH,qW); % selects the even combiner box results
        if isempty(CB.num) == 0
            CBworks(x)=CB;
            x=x+1;
        end
    end
end