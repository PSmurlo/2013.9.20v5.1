%--------------------------------------------------------------------------
% Photovoltaic Module Six Parameter Solver Model
% Scott Hummel, Jonathan Topham
% Last Revision: 7/30/13
%--------------------------------------------------------------------------

function pv6parmodule(WF, data)
%PV6PARMODULE uses SSC Photovoltaic 6 parameter model to determine the
%hourly current, voltage, and temperature of the module
%   [data]=pv6parmodule(data,WF) data struct is input and output and WF
%   struct is input which is read from the weather file
%   specified in the GUI through the WFreader function
%
%   See also GUIV4, WFreader

% Set Array elements
global modPV CECheat

poa_beam = ssccall('data_get_array', data, 'hourly_beam');
poa_skydiff = ssccall('data_get_array', data, 'hourly_glob_horiz_rad');
poa_gnddiff = ssccall('data_get_array', data, 'hourly_diff');
hourly_sol_zen=ssccall('data_get_array',data,'hourly_sol_zen');
hourly_sol_alt=ssccall('data_get_array',data,'hourly_sol_alt');
hourly_sol_azi=ssccall('data_get_array',data,'hourly_sol_azi');
ssccall('data_set_array', data, 'poa_beam', poa_beam*500);
ssccall('data_set_array', data, 'poa_skydiff', poa_skydiff*500);
ssccall('data_set_array', data, 'poa_gnddiff', poa_gnddiff*500);
ssccall('data_set_array', data, 'tdry', WF.tdry);
ssccall('data_set_array', data, 'wspd', WF.wspd);
ssccall('data_set_array', data, 'wdir', WF.wdir);
ssccall('data_set_array', data, 'sun_zen', hourly_sol_zen);
ssccall('data_set_array', data, 'incidence', hourly_sol_alt);
ssccall('data_set_array', data, 'surf_tilt', hourly_sol_azi);

ssccall('data_set_number',data,'elev', WF.site_elevation);

% Set CEC module parameters
ssccall('data_set_number', data, 'area', modPV.mod_area);
ssccall('data_set_number', data, 'Vmp', modPV.Vmp);
ssccall('data_set_number', data, 'Imp', modPV.Imp);
ssccall('data_set_number', data, 'Voc', modPV.Voc);
ssccall('data_set_number', data, 'Isc', modPV.Isc);
ssccall('data_set_number', data, 'alpha_isc', modPV.alpha_sc);
ssccall('data_set_number', data, 'beta_voc', modPV.beta_oc);
ssccall('data_set_number', data, 'gamma_pmp', modPV.gamma_r);
ssccall('data_set_number', data, 'tnoct', modPV.noct);
ssccall('data_set_number', data, 'a', modPV.nonideal);
ssccall('data_set_number', data, 'Il', modPV.light_I);
ssccall('data_set_number', data, 'Io', modPV.sat_I);
ssccall('data_set_number', data, 'Rs', modPV.r_s);
ssccall('data_set_number', data, 'Rsh', modPV.r_sh);
ssccall('data_set_number', data, 'Adj', modPV.t_adjust);
ssccall('data_set_number', data, 'standoff', CECheat.standoff);
ssccall('data_set_number', data, 'height', CECheat.cec_height);
% celltype=type2celltypebool(modPV.type);       % Module type index (6par)

% Create and run the module
module = ssccall('module_create', 'pv6parmod');
ok = ssccall('module_exec', module, data);

if ok,
    % Get cell temperature, dc current, and dc voltage
    modPV.t_cell=ssccall('data_get_array', data, 'tcell');
    modPV.dc_voltage=ssccall('data_get_array', data, 'dc_voltage');
    modPV.dc_current=ssccall('data_get_array', data, 'dc_current');   
else
    % if it failed, print all the errors
    disp('pv6parmodule errors:');
    ii=0;
    while 1,
        err = SSC.ssccall('module_log', module, ii);
        if strcmp(err,''),
            break;
        end
        disp( err );
        ii=ii+1;
    end
end

