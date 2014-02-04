function [CB]=evenCB1(possibleDim)
%EVENCB Removes combiner boxes which are not even combinations with respect
%to qW
%   [CB]=evenCB(CBstrings,qH,qW)
global possibleCBsizes
%breaks the input parameter up into vectors
tables=possibleDim(3,:);
qH=possibleDim(1,:);
qW=possibleDim(2,:);
tablesPerCB=possibleCBsizes/8; % divides the size of the CB up by its symmetrical number of combiner boxes
CBqH=(tablesPerCB')*(1./qW); % gives the qH for each combiner box (CBqH) if used for that orientation
integers=zeros(size(CBqH)); % creates matrix integers the same size as CBqh
integers(mod(CBqH,1)==0)=1; % populates matrix with 1 where CBqH is an integer
[tablesPerCBworks,qWindex]=find(integers); % finds the x and y indecies for the integers,
%x represents the tables per combiner boxes which works, while qW index is what qWs indecies work.
%This is then used to find what the actual values of qH,qW, and the total number of tables can be.
qWworks=qW(qWindex);
qHworks=qH(qWindex);
tablesWorks=tables(qWindex);
CBqHworks=tablesPerCBworks./qWworks'; %this calculates the CBqh which is the number of elements per ONE combiner box.
%qH is not always a multiple of CBqH, but this is taken care of in the rest
%of the code.
CB=vertcat(tablesPerCBworks',CBqHworks',qWworks,qHworks,tablesWorks); % puts all of these values together.