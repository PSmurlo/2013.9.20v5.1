function [table] =completeDerate(Ta,Tc,tableIdentity,condPerRaceway)
%COMPLETE DERATE looks up the deratedOCPD and the table which it needs to
%be looked up in
%   [deratedOCPD, table] =completeDerate(Ta,Tc,tableIdentity,OCPD,condPerRaceway)
%   Ta, Tc, tableIdentity, and condPerRaceway are all scalar values.
%   The description of the inputs are as follows:
%   
%   Ta is the 2% maximum ambient temperature of the site. This can be found
%   at www.solarabcs.com or using ASHRAE handbook.
%   
%   Tc is the temperature rating of the conductor insulation. Typicially
%   90, 75, or 60 is used per the NEC.
%   
%   tableIdentity is the name of the table in the  NEC which is being
%   referenced for ampacity information. There is room for more to be
%   added, but as of now only one is used.
%
%   OCPD is what the Over Current Protection Device must be rated for.
%   Along with the over current protection device, the conductor must be
%   rated for this as well.
%
%   condPerRaceway refers to the number of conductors per raceway. This
%   derating is not required, see below. See 'help numCondDerateChart' for
%   more information'
%   
%   The description of the outputs are as follows:
%   
%   This function outputs both the derated OCPD (deratedOCPD) and the table (table) for the
%   corresponding tableIdentity.
%
%   [deratedOCPD, table] =completeDerate(Ta,Tc,tableIdentity,OCPD)
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
if nargin ==3 %   [deratedOCPD, table] =completeDerate(Ta,Tc,tableIdentity,OCPD)
    [table,tTa] = table310Select(tableIdentity);
    tempDerate = tempDerateFormula(Ta,tTa,Tc);
    table=table*tempDerate;
% elseif nargin>4 %   [deratedOCPD, table] =completeDerate(Ta,Tc,tableIdentity,OCPD,condPerRaceway)
%     [table,tTa] = table310Select(tableIdentity);
%     tempDerate = tempDerateFormula(Ta,tTa,Tc);
%     numCondDerate=numCondDerateChart(condPerRaceway);
%     deratedOCPD=OCPD./(tempDerate*numCondDerate);
else
    disp('not enough input arguments');
end

    
    