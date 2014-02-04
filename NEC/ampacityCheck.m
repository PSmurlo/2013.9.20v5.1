function [minIndex]=ampacityCheck(Alencon,run,tableIdentity,OCPD,condPerRaceway)
%AMPACITY CHECK Checks the Ampacity of a given conductor.
%   [minIndex]=ampacityCheck(Alencon,run,tableIdentity,OCPD,condPerRaceway)
%   Ta, Tc, type, tableIdentity, and condPerRaceway are all scalar values.
%   The description of the inputs are as follows:
%
%   Alencon is whether this run is alencon or conventional 2 for Alencon 1
%   for conventional
%
%   run is which run is being looked at (1,2,3,4)
%
%   Ta is the 2% maximum ambient temperature of the site. This can be found
%   at www.solarabcs.com or using ASHRAE handbook. Passed through global
%   variable
%
%   Tc is the temperature rating of the conductor insulation. Typicially
%   90, 75, or 60 is used per the NEC. passed through globabl variable
%
%   type is the conductor type, accepts 'Al', 'Cu', passed through global
%   variable
%                                        0,  or 1  respectively.
%   tableIdentity is the name of the table in the  NEC which is being
%   referenced for ampacity information. There is room for more to be
%   added, but as of now only one is used.
%
%   OCPD is what the Over Current Protection Device must be rated for.
%   Along with the over current protection device, the conductor must be
%   rated for this as well.
%
%   condPerRaceway refers to the number of conductors per raceway. This
%   derating is not required, see below. See 'help numCondDerateChart' and
%   'help completeDerate' for more information'
%
%   The description of the outputs are as follows:
%
%   This function outputs both the minimum index of the wire, see
%   'table310Size', and either a scalar value for resistance or a vector of
%   resistance for all possible wire sizes, see 'resistLookup' for more
%   information.
%
%   [minIndex,Rdc] = ampacityCheck(Ta,Tc,type,tableIdentity,OCPD)
%
%   This simply omits the derating per number of conductors and assumes the
%   derating is 1.00
%
%   See also VDresults, table310Select, getIndex, completeDerate, tempDerate.
%
%   Authors: Jonathan Topham, Neal Margraf, Scott Hummel
%   $Revision: 3.0 $  $Date: 2013/08/25 19:45:00 $
%
%   NEC related function.
global Ta Tc type
if nargin == 4
    [table] =completeDerate(Ta,Tc(Alencon,run),tableIdentity);
    [minIndex] = table310Size(table,type(Alencon,run),Tc(Alencon,run),OCPD);
elseif nargin>4
    [deratedAmpacity,table] =completeDerate(Ta,Tc(Alencon,run),tableIdentity,OCPD,condPerRaceway);
    [minIndex] = table310Size(table,type(Alencon,run),Tc(Alencon,run),deratedAmpacity);
end