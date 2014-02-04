function [tempDerate]=tempDerateFormula(tTa,Ta,Tc) 
%TEMPERATURE DERATE FORMULA uses formula found in the NEC section
%310.15(B)(2) in order to find the temperature derate for a conductor based
%on the input parameters.
%   [derate]=tempDerateFormula(tTa,Ta,Tc) 
%   Ta, Tc, tableIdentity, and condPerRaceway are all scalar values.
%   The description of the inputs are as follows:
%   
%   tTa is the ambient temperature found in the associated table which the
%   ampacity will be looked up in. This changes depending on which table is
%   used, so it is important to note the table which is used before using
%   this function or the parent function.
%
%   Ta is the 2% maximum ambient temperature of the site. This can be found
%   at www.solarabcs.com or using ASHRAE handbook.
%   
%   Tc is the temperature rating of the conductor insulation.
%   90C, 75C, or 60C are used per the NEC.
%
%   This function calculates the difference between the ampacities in the
%   table and what they actually should be based on the actual ambient
%   temperature rather than what is found in the table.
% 
%   See also VDresults, table310Select, getIndex, completeDerate, tempDerate.
%
%   Authors: Jonathan Topham, Neal Margraf, Scott Hummel
%   $Revision: 3.0 $  $Date: 2013/08/25 19:45:00 $
%
%   NEC related function.%
tempDerate=sqrt((Tc-Ta)/(Tc-tTa));