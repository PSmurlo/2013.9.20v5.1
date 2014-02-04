
%--------------------------------------------------------------------------
% Voltage Drop Of Branch
% Scott Hummel
% Last Revision: 7/29/13
%--------------------------------------------------------------------------

close all;
clear all;

R=0.062;                    % Restiance factor in Ohms/1000 feet of 4/0
L=19.5;                     % One way length of circuits feeder (feet)
V_source=2500;              % Source voltage (V)
I_SPOT=8;                   % Current from a SPOT (I)

VD_total=0;                 % Initalize total volt drop to zero
VD_total_percentage=0;      % Initalize total VD percent to zero

% Loop to calculate VD as current builds up along branch run
for i=2:2:36
    
    % Calculates to volt drop for given current 
    voltage_drop=(2*L*R*I_SPOT*i)/1000;
    VD_percent=(voltage_drop/V_source)*100;
    
    % Updates the total VD and VD% of system 
    VD_total=VD_total+voltage_drop;
    VD_total_percentage=VD_total_percentage+VD_percent;
    
end

% Calculate voltage drop of the longest trunk run at 260 m (853 feet)
[VD_trunk,VD_percent_trunk]= voltdrop(853,R,288,2500);

% Calculates the max length conductor can be to meet a 2% VD requirement
% [max_length]=VD_percent_needed(2,2500,288,R);

% Display Results
X=['The total VD is ',num2str(VD_total),' V'];
disp(X);

X=['The VD percentage is ',num2str(VD_total_percentage), '%'];
disp(X);


