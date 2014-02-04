function [t,maxStringRun1d] =  stringRuns(hW,hH,totW,totH,CBW,CBH,modality,numtrunks)
%String Runs determines the total length per quad and the maximum length of
%wire
%   Inputs are the quad height, quad width, total height of an element,
%   total width of an element, the total number of combiner boxes, and the
global internal

if modality == 0; % portrait
    externalW = sum(0:1/2:(CBW-1/2))*totW *2;
    %second length is from modules to end of quad
    
else % landscape
    externalW = sum(0:1:(CBW-1))*4*totW;
    %second length is from modules to end of quad
end

h = sum((0:CBH).*totH); %distance from cable tray to combiner box
externalH =h*CBW*4; %number of conductors per table

if mod(hH,CBH)==1
    CBH_leftover=mod(hH,CBH);
    CB_tall=floor(hH/CBH);
    
    string = internal/2 + externalW+externalH;
    
    h2 = sum((0:CBH_leftover).*totH); %distance from cable tray to combiner box
    externalH2 =h2*CBW*4; %number of conductors per table
    
    t =((string*(hW/CBW)*CB_tall)*2)+...
        ((externalW+externalH2)*(hW/CBW)*2);
    
else
    
    string = internal/2 + externalW+externalH;
    
    t=string*(hW/CBW)*(hH/CBH)*2;
    
end
%Per half
maxStringRun1d = (CBW/2* totW)...% East West
    + (CBH*totH); % North South