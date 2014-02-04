function [finalData] = ConventionalOptimizationv2(inputs)
displaySAMresults=0;
displayConductorResults=0;
displayPlot_totH_Tilt=0;
% Call the correct folder

% Load the SAM simulation core modules
% SSC.ssccall('load');

% Create a data container to store all the variables
% data = ssccall('data_create');

% Load CEC module database
if (exist('finishdata','var')==0 || exist('finishdatacell','var')==0)
    load('Libraries\CEClibrary.mat');
    load('Libraries\CEClib_strings.mat');
end

% Search for Module Name
pv_module='Renesola Jiangsu JC300M-24-Ab'; % must be exact from library
mod_addr=(find(strcmp(pv_module,finishdatacell))/2+.5); %/2+.5 because counts both values

% % Search for Inverter Name (NOT Included yet)
% pv_inverter='SMA America: SC500CP-US 270V [CEC 2012]'; % must be exact from library
% inv_addr=(find(strcmp(pv_inverter,finishdatacell))/2+.5);

%%
% Simulation Selection Parameters
inverter_model = 0;             % Inverter model specifier,
% 0=spe, 1=sandia

module_model = 1;               % Photovoltaic module_model model specifier
% 0=spe, 1=cec, 2=6par_user, 3=snl

temp_corr_model = 0;            % Cell temperature model,
% 0=noct, 1=mc
track_mode=0;                   % Tracking mode: 0=fixed, 1=1axis, 2=2axis, 3=azi

irrad_model = 0;                % 0=beam & diffuse, 1=total & beam
sky_model = 2;                  % 0=isotropic, 1=hkdr, 2=perez
mismatch_model = 1;             % 0=disable, 1=enable
self_shading_enable = 0;        % 0=disable, 1=enable


% Environmental Parameters
% TMY3_File_Location= 'C:\Users\cleanenergy\Documents\My Dropbox\F12_Clinic_ECE10_Inverter\Weather Data\724075TY.csv';
% Set TMY3 file location
% ssccall('data_set_string', data, 'file_name', TMY3_File_Location);
%% WF Reader
% WF=WFreader(data);
%%

wf_albedo = 1;                  % Uses albedo from weather file if provided(yes)
modPV.Tmin= -14;                % ASHRAE Mean Low Temp
modPV.Ta = 37;                  % ASHRAE High Ambient Temperature

% Derates
soil(1:12)=0.95;                % Monthly Soiling Derate
dc_derate=0.98;                 % DC Power Derate
ac_derate=0.99;                 % Interconnection AC Derate

% Wiring
element.string_orientation=0;           % 0=vertical, 1=horizontal

%% *** only Modality if statement ***
% Orientation
element.modality=0;                     % 0=portrait, 1=landscape

if element.modality ==0 % PORTRAIT
    eleDim.nmody=2;
    eleDim.nstrx=2;
else                    % LANDSCAPE
    eleDim.nmody=4;
    eleDim.nstrx=1;
end
%%
element.azimuth=180;                    % Azimuth, 0=N, 90=E, 180=S, 270=W
element.gap_spacing= .1;                % Spacing between modules

% Heat transfer CEC variables
heat_transfer = 1;              % 0=module, 1=array;
mounting_orientation =1;        % 0= do not impede flow, 1=vertical, 2=horizontal supports
cec_height=0;                   % Array mounting height (0=one, 1=two)
mounting_config=0;              % (0=rack, 1=flush, 2=intergrated, 3=gap)
standoff=6;                     % 6 means rack mounted

% SANDIA Inverter Parameters
% SMA America: SC500CP-US 270V [CEC 2012]
inv.ac_voltage=270;
inv.paco=514000;                    % Max AC power rating (W)
inv.pdco=525258.202644486;          % DC input power at which AC-power rating is achieved (W)
inv.vdco=533.477916666667;          % DC input voltage for the rated ac-power rating (V)
inv.pso=1658.88177526711;           % DC power required to enable the inversion process (Wdc)
inv.c0=-2.60289802779116*10^(-8);   % Curvature between ac-power and dc-power at ref (1/W)
inv.c1=1.79159664133963*10^(-5);    % Coefficient of Pdco variation with DC input voltage (1/V)
inv.c2=2.61712986452631*10^(-3);    % Coefficient of Pso variation with DC input voltage (1/V)
inv.c3=1.44910647847469*10^(-5);    % Coefficient of Co variation with DC input voltage (1/V)
inv.pnt=307.9;                      % AC power consumed by inverter at night (Wac)

% Inverter constraints
inv.vdcmax=1000;                    % Maximum DC input operating voltage (V)
inv.idcmax=1250;                    % Max AC current (A)
inv.mppt_low=449;                   % Minimum input voltage (MPPT)
inv.mppt_hi=850;                    % Maximum input voltage (MPPT)
inv.DC_AC.target= 1.33;
inv.num_inverters=16;               % Number of inverters
inv.DC_AC.variance=.05;

% Module Manual Entry
modPV.module_length=1.956;                      % Module length (m)
modPV.ncellx=6;                                 % Number of cells on top

% CEC Module Parameters
modPV.noct=       finishdata(1,mod_addr);       % Nominal operating cell temperature (C)
modPV.mod_area=   finishdata(2,mod_addr);       % Module Area (m^2)
modPV.cells=      finishdata(3,mod_addr);       % Number of cells in series
modPV.Isc=        finishdata(4,mod_addr);       % Short circuit current (A)
modPV.Voc=        finishdata(5,mod_addr);       % Open circuit voltage (V)
modPV.Imp=        finishdata(6,mod_addr);       % Maximum power point current (A)
modPV.Vmp=        finishdata(7,mod_addr);       % Max power voltage (V)
modPV.alpha_sc=   finishdata(8,mod_addr);       % Isc temperature coefficient (A/C)
modPV.beta_oc=   -finishdata(9,mod_addr);       % Voc temperature coefficient (V/C)
modPV.nonideal=   finishdata(10,mod_addr);      % Nonideality factor a
modPV.light_I=    finishdata(11,mod_addr);      % Light current (A)
modPV.sat_I=      finishdata(12,mod_addr);      % Saturation Current (A)
modPV.r_s=        finishdata(13,mod_addr);      % Series resistance (ohms)
modPV.r_sh=       finishdata(14,mod_addr);      % Shunt resistance (ohms)
modPV.t_adjust=   finishdata(15,mod_addr);      % Temperature coefficient adjustment (%)
modPV.gamma_r=    finishdata(16,mod_addr);      % Pmax temperature coefficient (%/C)
modPV.module_width=modPV.mod_area/modPV.module_length;      % Module width (m)
modPV.ncelly=modPV.cells/modPV.ncellx;                      % Number of cells longways
modPV.ndiode=modPV.ncellx/2;                          % Number of bypass diodes
modPV.type=       finishdatacell{2,mod_addr};   % Module Type
modPV.module_string=finishdatacell{1,mod_addr}; % Module Name
% celltype=type2celltypebool(type);       % Module type index (6par)

% Calculating modules per string and max power voltage
modPV.mps= floor(inv.vdcmax/(modPV.Voc-(modPV.beta_oc*(25-modPV.Tmin))));
modPV.vmpmax = modPV.mps * (modPV.Vmp - ((modPV.gamma_r/modPV.Imp) * (25 - modPV.Ta))); %used for VD calc of string wiring

% Rack Dimensions
eleDim=rackDim(element,modPV);
eleDim.totH = 10;
eleDim.tilt = 30;

% Determine AC system size
ac_system_size=inv.paco*inv.num_inverters;
% Calculating the DC size of array
dc_system_size=inv.DC_AC.target*ac_system_size;
strings_parallel=floor(dc_system_size/(modPV.Vmp*modPV.Imp*modPV.mps));
dc_system_size=strings_parallel*(modPV.Vmp*modPV.Imp*modPV.mps);
% Determining number of tables

% table Watts
tableDCW=eleDim.modperTable*modPV.Imp*modPV.Vmp;
% required DC size
DCsize_quad=inv.pdco*inv.DC_AC.target;
tablesPerQuad=DCsize_quad/tableDCW;
eleDim.tablesPerQuad.Range=ceil(tablesPerQuad*(1-inv.DC_AC.variance)):floor(tablesPerQuad*(1+inv.DC_AC.variance));

[CB]=PossibleCB(eleDim);

%% Declarations
addpath('Ampacity_Derates');

Ta = modPV.Ta;    %Temperature Ambient
Tc = 75;    %Temp conductor

%% max/mins
type=0; %0=AL, 1=cu
if(type==0)
    maxAWG=20;
else
    maxAWG=15;
end

%% Initializations
maxVD = 4;
maxCost = 4000000;
Isc = modPV.Isc;
Imax = Isc * 1.25;
OCPDs = Imax * 1.25;
n = 1;
finalData = [];

%% Main
for k = 1:numel(CB)
    for l = 1:numel(CB(k).Tables)
        %     m=cbStringsOutput(k == CB(k).num);
        %     CBqHi=CB(k).qH( k == CB(k).num);
        strings= CB(k).Strings(l);
        OCPDcb = OCPDs.*strings;
        [minIndex] = ampacity_check(Ta,Tc,type,'15b17',OCPDcb,2); %finds smallest wire size for configuration
        tables= CB(k).Tables(l);    % Number of tables in array
        CBqH= CB(k).CBqH(l);        % Height in tables of array for each combiner box
        numCB= CB(k).num(l);        % number of combiner boxes
        qH=CB(k).qH;
        qW=CB(k).qW;
        if minIndex >= maxAWG
            continue % If minimum wire size based on ampacity exceeds the largest possible available conductor
        end
        for m = minIndex:maxAWG %Size up this conductor up to the maximum allowable size
            if(qH/numCB >= mod(qH,numCB))
                [vd(n),leng(n),cost(n),misc(n)] = convFindcostv2([ceil(numCB),m,minIndex,strings],qH,qW,modPV,eleDim,CBqH,inv,inputs); %main calculation function
                if (vd(n).max < maxVD) && (cost(n).cnt < maxCost)
                    extraData = horzcat(cost(n).total,...       % Cost of total system ($)
                        vd(n).max,...                           % Maximum voltage drop (%VD)
                        cost(n).total/misc(n).modulesW,...      % Dollars per Watt ($/W)
                        cost(n).wire.total,...                  % Cost of Conductors
                        cost(n).CT.total,...                    % Cost of tray
                        cost(n).labor.total,...                 % Cost of Labor
                        leng(n).wire.m2cb,...                   % Length of #10
                        2*sum(leng(n).wire.cb2inv),...          % Length of Trunk
                        qW,...                                   % Size of Trunk
                        qH,...                                  % Array height in tables
                        cost(n).CB.item,...
                        cost(n).inverter,...
                        m);                                 	% Array width in tables
                        
                    
                    %zeros(length(vd(n).max),1),...      % kwhLoss(n).total,...              % Power Loss on conductors (kWh)...
                    %                         qH*2,...                                % Array height in number of tables
                    %                         qW*2,...                                % Array width in number of tables
                    %                         (qH*qW)*4,...                           % Array area in number of tables
                    %                         strings/4,...                           % CB Size in number of tables
                    %                         ceil(numCB),...                         % Number of combiner boxes installed
                    %                         numCB,...                               % Number of combiner boxes utilized
                    %                         m,...                                 % Largest Wire Size of trunk conductor
                    %                         leng(n).wire.cb2inv1,...                % Total Length of conductor from combiner box to inverter
                    %                         leng(n).wire.m2cb);                     % Total Length of conductor from module to combiner box
                    finalData = vertcat(finalData,extraData);
                    
                    n = n + 1;
                else
                    vd(n) = [];
                    cost(n) = [];
                    misc(n) = [];
                    leng(n) =[];
                end
            end
        end
    end
end

% conductor cost was calculated for 2 Mw system, but need to compare 10
% pointlabels = {'Total System Cost','Voltage Drop','$/W','kWh Loss','Quad Height','Quad Width','Tables per Quad','CB Size in Tables','CBs Installed','CBs Utilized','Trunk Wire Index','Length of Trunk runs','String runs total'};
% finalData = horzcat(cost',vd',dpw',kwhLoss',finalData);
finalData = sortrows(finalData,1);
% finalCell = vertcat(pointlabels,num2cell(finalData));


% bestVals = [(finalData(1,1)^2) + (finalData(1,2)^2),1]; % distance to zero of first index

% loop checks all the possibilities for the closest one to (0,0)
% for i = 2:(size(x,2))
%     nextVals = [(finalData(i,1)^2) + (finalData(i,2)^2),i];
%     if nextVals(1) < bestVals(1)
%         bestVals = nextVals;
%     end
% end

% if(plotEnable==1)
%
%     %     % kWh vs %VD
%     %     fh0 = figure;
%     %     title('DC power loss vs Voltage drop');
%     %     scatter(kwh,y,'x');
%     %     grid
%     %     xlabel('kWh loss over 25 years');
%     %     ylabel('Max Volt Drop');
%     %     ylim([0,maxVD]);
%     %
%     %     dcm0 = datacursormode(fh0);
%     %     datacursormode on
%     %     set(dcm0, 'updatefcn', @PVDatatipCursorKWH);
%
%     % $/w vs %VD
%     figure;
%     suptitle('Conventional DC Side');
%     scatter(finalData(:,3),finalData(:,2),'x');
%     grid
%     xlabel('$/W of all X-Y components');
%     ylabel('Max Volt Drop');
%     ylim([0,maxVD]);
%     %     dcm = datacursormode(fh);
%     %     datacursormode on
%     %     set(dcm, 'updatefcn', @PVDatatipCursor);
% end
%
%
%
% % q = bestVals(2);
% % X = [finalData(q,3),finalData(q,4),finalData(q,5)];
% % [totalConductorCost,VDmax,~,~,totalWire,numTables,CB.num,cbStrings, ...
% %     tableW,tableH,qW,qH,totalCost] = ...
% %     newPvConvFunction(X);
% %
% % figure;
% % pvFarmDraw(0,0,tableW,tableH,qH,qW,1.996,0.994,4,19);
%
