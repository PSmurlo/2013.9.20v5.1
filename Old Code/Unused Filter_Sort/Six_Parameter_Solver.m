
%--------------------------------------------------------------------------
% Six Par Solve Model
% Scott Hummel
% Last Revision: 7/30/13
%--------------------------------------------------------------------------

close all;
clear all;

% Load the SAM simulation core modules
SSC.ssccall('load');

% Create a data container to store all the variables
data = ssccall('data_create');

% Parameters
cell_type= 'polySi';    % MonoSi, multiSi/polySi, cis, cigs, cdte, amorphous 
Vmp=36.6;               % Maximum power point voltage (V)
Imp=8.20;               % Maximum power point current (A)
Voc=44.8;               % Open circuit voltage (V)
Isc=8.69;               % Short circuit current (A)
alpha_isc=0.0034;       % Temperature coefficient of Isc (A/C)
beta_voc=-0.134;        % Temperature coefficient of Voc (V/C)
gamma_pmp=-0.40;        % Temperature coefficient of power at MP (%/C)
Nser=72;                % Number of cell in series

% MonoSi, multiSi/polySi, cis, cigs, cdte, amorphous
ssccall('data_set_string', data, 'celltype', cell_type);  
ssccall('data_set_number', data, 'Vmp', Vmp); 
ssccall('data_set_number', data, 'Imp', Imp); 
ssccall('data_set_number', data, 'Voc', Voc);  
ssccall('data_set_number', data, 'Isc', Isc);  
ssccall('data_set_number', data, 'alpha_isc', alpha_isc); 
ssccall('data_set_number', data, 'beta_voc', beta_voc);  
ssccall('data_set_number', data, 'gamma_pmp', gamma_pmp); 
ssccall('data_set_number', data, 'Nser', Nser);

% Run the module
%--------------------------------------------------------------------------
% Create the pvsamv1 module
module = ssccall('module_create', '6parsolve');
% Run the module
ssccall('module_exec', module, data);

% Solve for the parameters
nonideality_factor = ssccall('data_get_number', data, 'a');

% Light Current (A)
light_current = ssccall('data_get_number', data, 'Il');

% Saturation Current (A)
sat_current= ssccall('data_get_number', data, 'Io');

% Series Resistance
Rs= ssccall('data_get_number', data, 'Rs');

% Shunt Resistance
Rsh= ssccall('data_get_number', data, 'Rsh');

% OC SC temp coefficient adjustment
Adj = ssccall('data_get_number', data, 'Adj');




