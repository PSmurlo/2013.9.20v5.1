function [kWh] = spotkWhLoss(totH,resistance,ImpSPOT,rows,spotsPerRow)
%SPOTKWHLOSS This function computes the kWh Loss over the sytem lifecycle based on the input parameters relating to the wire
%as well as the current and voltage the wire is being used for. Uses
%   [kWh] = spotkWhLoss(totH,resistance,rows,spotsPerRow)
%   totH referrs to the total distance between SPOTs. Defaultly the
%   prefabficated conductor is run verticially, this must be changed to
%   totW if this conductor runs horizontally
%
%   rows refers to the the number of rows of SPOTs to be added to the
%   prefab conductor.
%
%   spotsPerRow refers to the number of SPOTs added to the prefab at each
%   row.
%
%   See also 'voltDrop', 'pv6parmod', 'spotVoltDrop'
%
%   Authors: Jonathan Topham, Neal Margraf, Scott Hummel
%   $Revision: 3.0 $  $Date: 2013/08/25 19:45:00 $
%
%   Alencon Photovoltaic related function.
if nargin==4
    if rows<100
        spotsPerRow=2;
    else % if you have many rows, you only have a posible width of 1
        spotsPerRow=1;
    end
    i=(1:rows)*spotsPerRow;
    current=ImpSPOT*i;
    resistance=2*totH*resistance;
    kWh=(resistance)*((current).^2);
    kWh=sum(kWh);
    kWh=sum(kWh);
elseif nargin ==5
    
    i=(1:rows)*spotsPerRow;
    kWh=((2*totH*resistance))*(ImpSPOT*i).^2;
    kWh=sum(kWh);
    kWh=sum(kWh);
end

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
