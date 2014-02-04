function [VD, VD_Percent] = spotVoltDrop(totW,resistance,ImpSpot,Vmaxpower,rows)
%VOLTAGE DROP This function computes the voltage drop as well as the percent voltage drop percent based on the input parameters relating to the wire
%as well as the current and voltage the wire is being used for.
%   spotVoltDrop(length,resistance,ImpSpot,Vmaxpower,rows)
%   the input parameter of length describes the *one way* length of the
%   conductor. The resistance is the resistance in *ohms/km* for the
%   conductor size being used. Imp and Vmp are the nominal voltage and
%   current for average operating conditions.
%
%   totH refers to the distance between SPOTs. totH is the inter-row
%   shading, if the design is to be changed so that the prefab runs are run
%   horizontally rather than verticially, this is to be changed to totW.
%
%   rows refers to the the number of rows of SPOTs to be added to the
%   prefab conductor.
%
%   spotsPerRow refers to the number of SPOTs added to the prefab at each
%   row.
%
%   See also voltDrop.
%
%   Authors: Jonathan Topham, Neal Margraf, Scott Hummel
%   $Revision: 3.0 $  $Date: 2013/08/25 19:45:00 $
%
%   Alencon Photovoltaic related function.
global prefab
ImpSpot=ImpSpot*prefab.spotPer;
i=(1:rows);
VD=(2*totW*(resistance/1000)*ImpSpot*i);
VD_Percent=(VD/Vmaxpower)*100;
VD=sum(VD);
VD_Percent=sum(VD_Percent);

    
%     % Loop to calculate VD as current builds up along branch run
%     for i=spotsPerRow:spotsPerRow:rows*spotsPerRow
%         
%         % Calculates to volt drop for given current
%         voltage_drop=(2*totH*resistance*ImpSpot*i)/1000;
%         
%         
%         % Updates the total VD and VD% of system
%         VD = VD + voltage_drop;
%         VDPercent = VDPercent + VD_percent;
%     end
