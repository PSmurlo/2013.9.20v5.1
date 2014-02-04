function [Rdc] = resistLookup(Tc,type,index)
%RESISTANCE LOOKUP Looks up and adjusts the resistance of the conductor based on the NEC.
%   [Rdc] = resistLookup(Tc,type,index)
%   Tc, type, and index are all scalar values
%   The description of the inputs are as follows:
%   
%   Tc is the temperature rating of the conductor insulation. Typicially
%   90, 75, or 60 is used per the NEC. This adjusts the possible resistance
%   
%   type is the conductor type, accepts 'Al', 'Cu', 
%                                        0,  or 1  respectively.
% 
%   index is the minimum index from 'table310Size' or any other index
%   desired. When the index is given a scalar value is output.
%
%   [Rdc] = resistLookup(Tc,type)
%   when index is not given, Rdc is given as a 1x30 vector, resistance for
%   all wire sizes.
%
%   See also VDresults, table310Select, getIndex, completeDerate, tempDerate.
%
%   Authors: Jonathan Topham, Neal Margraf, Scott Hummel
%   $Revision: 3.0 $  $Date: 2013/08/25 19:45:00 $
%
%   NEC related function.
global resCu resAl
acu = 0.00323; %alpha of Cu
aal = 0.0033;  %alpha of Al
%% Vector
if nargin < 3
    %Check what material we're working with:
    if(or(strcmp('Al',type),type==0))
        a = aal; %alpha
        res=resAl;
    elseif(or(strcmp('Cu',type),type==1))
        a = acu;
        res=resCu;
    else
        disp('invalid input');
    end
    %end material check
%% Scalar    
else 
    %Check what material we're working with:
    if(or(strcmp('Al',type),type==0))
        a = aal; %alpha
        res=Aluminum(index);
    elseif(or(strcmp('Cu',type),type==1))
        a = acu;
        res=Copper(index);
    else
        disp('invalid input');
    end
    %end material check
end
%% Adjustment and Result
a_res = res*(1 + a*(75-75)); %adjusted 
%%
% *ohms per km*
Rdc = a_res;