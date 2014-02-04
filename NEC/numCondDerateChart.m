function [percentDerate]=numCondDerateChart(condPerRaceway)
%NUMBER OF CONDUCTOR IN RACEWAY DERATE BY CHART Produces the derate value
%for the number of conductors in a raceway per the NEC.
%   [percent]=numCondDerateChart(numCond)
%   
%   condPerRaceway refers to the number of conductors per raceway. This
%   derating is not required. It can be omitted from parent function. 
%   
%   percentDerate is the percentage to which the conductors must be derated
%   if condPerRaceway exceeds the given thresholds.
%
%   See also VDresults, table310Select, getIndex, completeDerate, tempDerate.
%
%   Authors: Jonathan Topham, Neal Margraf, Scott Hummel
%   $Revision: 3.0 $  $Date: 2013/08/25 19:45:00 $
%
%   NEC related function.

    if(condPerRaceway<3)
        percentDerate=1;
    elseif(condPerRaceway<=6)
        percentDerate=.80;
    elseif(condPerRaceway<=9)
        percentDerate=.70;
    elseif(condPerRaceway<=20)
        percentDerate=.50;
    elseif(condPerRaceway<=30)
        percentDerate=.45;
    elseif(condPerRaceway<=40)
        percentDerate=.40;
    elseif(condPerRaceway>40)  
        percentDerate=.35;
    end

    
        