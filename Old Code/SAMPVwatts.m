% SSC SDK - MATLAB example
%
% example script to run PVWatts

clearvars -except moduleInfo moduleInfo_strings

ssccall('load');

% create a data container to store all the variables
data = ssccall('data_create');

% import module data
% module=modulelisting(1,:); %modulelisting is all modules

Vocmax_module=1000; %1000vdcmax
Tmin=-15;%C
if (moduleInfo.finishdata(1,1)==0 && moduleInfo_strings.finishdatacell{1,1}==0)
    moduleInfo= load('C:\Users\eceadmin\Dropbox\F12_Clinic_ECE10_Inverter\CODE\MATLAB\CEClibrary');
    moduleInfo_strings= load('C:\Users\eceadmin\Dropbox\F12_Clinic_ECE10_Inverter\CODE\MATLAB\CEClib_strings');
end
mod_addr=10;

t_noct=     moduleInfo.finishdata(1,mod_addr);
a_c=        moduleInfo.finishdata(2,mod_addr);
n_s=        moduleInfo.finishdata(3,mod_addr);
i_sc_ref=   moduleInfo.finishdata(4,mod_addr);
v_oc_ref=   moduleInfo.finishdata(5,mod_addr);
i_mp_ref=   moduleInfo.finishdata(6,mod_addr);
v_mp_ref=   moduleInfo.finishdata(7,mod_addr);
alpha_sc=   moduleInfo.finishdata(8,mod_addr);
beta_oc=    moduleInfo.finishdata(9,mod_addr);
a_ref=      moduleInfo.finishdata(10,mod_addr);
i_l_ref=    moduleInfo.finishdata(11,mod_addr);
i_o_ref=    moduleInfo.finishdata(12,mod_addr);
r_s=        moduleInfo.finishdata(13,mod_addr);
r_sh_ref=   moduleInfo.finishdata(14,mod_addr);
adjust=     moduleInfo.finishdata(15,mod_addr);
gamma_r=    moduleInfo.finishdata(16,mod_addr);
type=       moduleInfo_strings.finishdatacell{2,mod_addr};
module=     moduleInfo_strings.finishdatacell{1,mod_addr};

celltype=type2celltype(type);
MpS= floor(Vocmax_module/(v_oc_ref+(beta_oc*(25-Tmin))));

% setup the system parameters
ssccall('data_set_string', data, 'celltype', 'monoSi');
ssccall('data_set_number', data, 'Vmp', v_mp_ref);
ssccall('data_set_number', data, 'Imp', i_mp_ref);
ssccall('data_set_number', data, 'Voc', v_oc_ref);
ssccall('data_set_number', data, 'Isc', i_sc_ref);
ssccall('data_set_number', data, 'alpha_isc', alpha_sc);
ssccall('data_set_number', data, 'beta_voc', beta_oc);
ssccall('data_set_number', data, 'gamma_pmp', gamma_r);
ssccall('data_set_number', data, 'Nser', MpS);

% create the 6parsolve module
module = ssccall('module_create', '6parsolve');

% run the module
ok = ssccall('module_exec', module, data);
if ok,
    % if successful, retrieve the hourly AC generation data and print
    % annual kWh on the screen
    
    a = ssccall('data_get_number', data, 'a');
    Il = ssccall('data_get_number', data, 'Il');
    Io = ssccall('data_get_number', data, 'Io');
    Rs = ssccall('data_get_number', data, 'Rs');
    Rsh = ssccall('data_get_number', data, 'Rsh');
    Adj = ssccall('data_get_number', data, 'Adj');
    
else
    % if it failed, print all the errors
    disp('pvwattsv1 errors:');
    ii=0;
    while 1,
        err = ssccall('module_log', module, ii);
        if strcmp(err,''),
            break;
        end
        disp( err );
        ii=ii+1;
    end
end

% free the PVWatts module that we created
ssccall('module_free', module);

% release the data container and all of its variables
ssccall('data_free', data);

% unload the library
ssccall('unload');