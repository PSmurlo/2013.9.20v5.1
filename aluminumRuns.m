function [maxl,l,qHleft] = aluminumRuns(qH,totH,CBqH,array2Inverter)
%ALUMINUM RUNS Takes the number of combiner boxes and quadrant height in
%both number of elements and meters and calculates the distance to each
%combiner box from the inverter.
%   [maxl,l,qHleft] = aluminumRuns(numCB,qH,totH,array2inverter)
%   *Currently only works in a straight line.*
%   The input parameter numCB refers to the number of combiner boxes on one
%   half of the array, qH is the number of array elements high the distance
%   between the inverter and top of the array is. totH is the height of
%   that array element. array2Inverter is the distance between the last
%   combiner box and the inverter.
%
%   It must be ensured that numCB and qH are able to be split into combiner
%   boxes evenly
%
%   All lengths in the output of this function are in 1-way lengths. *The function
%   'voltDrop.m' requires 1-way lengths*
%   qHleft represents the last combiner box's height in elements of the
%   array.

l = 0; % initializes the length to zero
n = 1; % creates the first index

qHleft=mod(qH,CBqH);

for i = 0:CBqH:(qH-CBqH)
    l(n) = ((i+qHleft)*...  % qH at each combiner box, ignores initial combiner box
        totH + ...          % multiply by totH to make height in elements into height in meters
        array2Inverter);    % add the constant to each run representing the distance from the last CB to the inverter input
    n = n + 1; % increment
    
end
if(qHleft>1)
    l=horzcat(array2Inverter,l); % add last length for leftover CB
end
maxl=max(l); % maximum length



