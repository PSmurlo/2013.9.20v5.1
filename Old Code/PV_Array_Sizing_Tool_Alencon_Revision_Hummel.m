
%--------------------------------------------------------------------------
% Alencon PV Array Sizing Calculator
% Spring/Summer 2013
% Last Revision: 7/16/13
% Jon Topham, Scott Hummel, Neal Margraf
%--------------------------------------------------------------------------

addpath('C:\Users\Scott Hummel\Documents\MATLAB_CSD\Mathworks Code');
clc;
close all;
clear all;
tic

% Wire Size Index
%--------------------------------------------------------------------------
size_index=cellstr(['18  ';'16  ';'14  ';'12  ';'10  ';'8   ';'6   ';'4   ';...
    '3   ';'2   ';'1   ';'1/0 ';'2/0 ';'3/0 ';'4/0 ';...
    '250 ';'300 ';'350 ';'400 ';'500 ';'600 ';'700 ';...
    '750 ';'800 ';'900 ';'1000';'1250';'1500';'1750';'2000']);
num_sizes= length(size_index);


% Temperature Factors
%--------------------------------------------------------------------------
Ta=   37;               % AHRAE 2% Dry Bulb Temp
Tmin= -14;              % ASHRAE Mean Low Temp
% Tdelta=(none)         % Roof correction temp
%                       % Roof corrected temp

% Alencon Characteristics
%--------------------------------------------------------------------------
GrIP_size=10000;        % Total Array size in kW
SPOT_kW=20;           % kW rating of SPOT
spotSize=4;             % string per SPOT
DC_AC1= GrIP_size/SPOT_kW; %1:1 DC:AC ratio
TotalSystemCost=25000000;

% Module Nameplate Data
%--------------------------------------------------------------------------
% NOTE: Have access to CEC module database.
% In future, will be able to import ALL module data.**

Name='Renesola 300W 72 cell poly c-Si';
Voc= 44.8;              % Open circuit voltage (V)
Vmp= 36.6;              % Max Power voltage (V)
Isc=8.69;               % Short Circuit Current (A)
Imp=8.20;               % Maximum Power Current (A)
Tvoc= -.30;             % Percent/C
Tisc= -.04;             % Temperature coefficient for Isc (%/C)
Tvmp= -.4;              % Temperature coefficient of Pmax (%/C)
mod_l=1.996;            % Module Length (*Longer side*) (m)
mod_w=.994;             % Module Width (m)
percent_per_C=1;        % Percent per C (1) / Volts per C (0)
Vocmax_module=1000;     % Voltage Open Circuit Max of Module (V)

% Nameplate Calculations
%--------------------------------------------------------------------------
%
% Calculates the number of modules per string, MpS
if(percent_per_C==0)
    MpS= floor(Vocmax_module/(Voc-(Tvoc*(25-Tmin)))); %Volts/C
else
    MpS= floor(Vocmax_module/(Voc*(1+((-Tvoc)*(25-Tmin)/100)))); %Percent/C
end
Vmpmax=MpS*(Vmp-Tvmp*(25-Ta)); % Maximum Nominal Voltage for Vmp. Used for VD calc

% Angle Determinants
%--------------------------------------------------------------------------
lat=39;             % Latitude of the location
tilt=25;            % Tilt angle of array (Degrees)

% Toggles/Inputs
%--------------------------------------------------------------------------
modality=1;                 % Landscape:1 Portrait:0
string_per_row=1;           % one or two strings per row
enable_secondary_CB=0;      % 0:disable 1:enable
VD_desired=1.5;             % percent voltage drop desired
VD_offset=1;              % percent voltage drop difference allowed than desired
min_DC_to_AC=1.0;%:1        % maximum DC:AC Ratio
max_DC_to_AC=1.5;%:1        % percent oversize of number of SPOTs
CSV_output=0;               % enables CSV output
CSV_filename='VoltDropPortrait';

% Set up column header for final table
%--------------------------------------------------------------------------
% Headers:
% row_header=cellstr([''.'DesiredVD',VD_desired,'+/-',VD_offset,DC])
column_header=cellstr(['numSpots     ';'L            ';'W            ';'modality     ';'CB_size      ';'num_CB       ';'length_mod   ';'length_prefab';'length_trunk ';'runs_mod     ';'runs_prefab  ';'runs_trunk   ';'size_mod     ';'size_prefab  ';'size_trunk   ';'vd_mod       ';'vd_prefab    ';'vd_trunk     ';'cost_mod     ';'cost_prefab  ';'cost_trunk   ';'Weight_kfoot ';'CT_width     ';'total_VD     ';'total_cost   ']);
%siteConditions=cellstr([]); %ADD


index=1;

% Wire conditions
%--------------------------------------------------------------------------
% Module to SPOT
table_identity{1}='15b17';
type{1}='Cu';
Tc(1)=75;
cond_per_run(1)=2;
Vmax(1)=Vmpmax;

% SPOT to Prefab
%--

% Prefab
table_identity{2}='15b17';
type{2}='Cu';
Tc(2)=75; %maybe 90
cond_per_run(2)=2;
Vmax(2)=2500;


% Trunk to GrIP
table_identity{3}='15b17';
type{3}='Cu'; %Maybe 'Al'
Tc(3)=75; %maybe 90
cond_per_run(3)=2;
Vmax(3)=2500;


% Range of number of SPOTs
%--------------------------------------------------------------------------
for numSpots= floor((DC_AC1)*(min_DC_to_AC)):ceil((DC_AC1)*(max_DC_to_AC));
    
    % Number of SPOT elements in length
    for L=4:numSpots;
        
        % Number of SPOT elements in width
        W=numSpots/L;
        
        % If the number of spots has even integer for length and width
        if(mod(W,2)==0 && mod(L,2)==0)
            
            %% 'Module to SPOT wiring Calculations'
            Imax = Isc*1.25;        % Maximum possible current
            OCPD = Imax*1.25;       % Over-Current protection
            
            % Selects array modality and configuration of SPOT element
            if(modality==0) %Portrait
                rows=2;
                cols=MpS*2;
                [tot_l,tot_w]=rackDim(lat,rows,cols,tilt,mod_l,mod_w,modality);
                wire_l_mod=tot_l/2;
            else %Landscape
                rows=4;     
                cols=MpS;
                [tot_l,tot_w]=rackDim(lat,rows,cols,tilt,mod_l,mod_w,modality);
                wire_l_mod=tot_l;
            end
            
            % Number of runs per module
            runs_mod=numSpots*4;
            
            % Tables and Derates
            [min_index,Rdc]=ampacity_check(Ta,Tc(1),type{1},table_identity{1},OCPD,cond_per_run(1));
            
            % *Ampacity and Volt drop*
            [~,~,~,price] = wire_2kv(type{1});
            [~,VD_percent]= voltdrop(wire_l_mod,Rdc,Imp,Vmax(1));
            result_mod=AmpacityVD_results(min_index,VD_percent,price,cond_per_run(1),runs_mod,wire_l_mod);
            
            % Clear variables from workspace to free up memory
            clear ('price','Rdc','VD_percent','min_index');
            
            %             %% 'Spot to Prefab Calculations
            %             %
            %             % Omitted from most of code due to having little effect on
            %             % overall wiring, or system layout. not specified in output
            %
            %             % *Ampacity*
            %             %--------------------------------------------------------------
            %             Vmax=2500;
            %             Imax=(25000/Vmax)*1.25;
            %
            %             % OCPD = Imax*1.25;             % Not needed, isolated from PV circuit
            %
            %             % Tables and Derates
            %             [min_index,~]=ampacity_check(Ta,Tc,type,table_identity,Imax,cond_per_raceway);
            %
            %             result_spot2prefab=min_index;   % Lowest ampacity, volt drop not a concern
            %
            %             % *Voltage Drop*
            %             %--------------------------------------------------------------
            %             % ~0 due to extremely short length
            %
            %             % Clear variables from the workspace
            %             clear('min_index','Rdc','chart','type','Tc','cond_per_run','Vmax','Imax','OCPD','table','tTa','temp_derate','numcond_derate','deratedAmpacity','price','Rdc','VD_percent','min_index');
            %
            %% 'Prefab Calculations'
            
            % *Ampacity*
            %--------------------------------------------------------------
            Imax=(SPOT_kW/Vmax(2))*1.25;
            IprefabMax=Imax*L/2; %L/2 is number of spots on one half of the length
            
            % *Length and #Runs*
            %--------------------------------------------------------------
            wire_l_prefab=tot_l*((L/2)-1);
            
             if wire_l_prefab > 304.8
                 clear('result_mod');
                 break
             end
            
            runs_prefab=W*2;
            
            % *Ampacity Check*
            %--------------------------------------------------------------
            [min_index,Rdc]=ampacity_check(Ta,Tc(2),type{2},table_identity{2},IprefabMax,cond_per_run(2));
            
            % *Conductor Cost*
            %--------------------------------------------------------------
            [~,~,~,price] = wire_2kv(type(2));
            
            % Calcualtes the voltrop percentage
            %--------------------------------------------------------------
            % NOT CORRECT MUST BE FIXED
            [~,VD_percent]= voltdrop(wire_l_prefab,Rdc,(IprefabMax/1.25),Vmax(2));
            
            if(min_index<30)
                result_prefab=AmpacityVD_results(min_index,VD_percent,price,cond_per_run(2),runs_prefab,wire_l_prefab);
            end
            
            % Clear variables from the workspace
            clear ('min_index','Rdc','Imax','price','VD_percent');
            
            %% 'Trunk Calculations'
            
            % *Ampacity*
            %--------------------------------------------------------------
            
            % Combiner box
            if(enable_secondary_CB==1)
                CB_size_option=[1,2,4,6,8,10]; % Possible CB sizes (preferred even numbers)
            else
                CB_size_option=[1,2]; % no CB or 2 to 1 plug (no fusing required)
            end
            
            for CB_size=CB_size_option
                % Starts at zero at beginning of loop
                trunk_l=0;
                
                num_CB=ceil(W/CB_size);
                % Width of SPOT element by however many number of combiner box fit in the spacing
                CB_spacing=tot_w*((W/2)/CB_size);
                
                for i=1:num_CB
                    trunk_l(i)=CB_spacing/2+(i-1)*CB_spacing; % First is half of a spacing (so that the CB is in the center of the spacing) adding all of the lengths up
                end
                
                wire_l_trunk=mean(trunk_l); % Average length of conductor (since VD is proportional to length, this is adequate to find average voltage drop)
                cond_per_raceway=cond_per_run(3)*num_CB;  % Number of conductors per raceway
                runs_trunk=2;               % Number of total trunk runs (if array is split top/bottom), this is two.
                Itrunk=IprefabMax*CB_size;  % Current through one trunk conductor, taken from the prefab current
                
                [min_index,Rdc]=ampacity_check(Ta,Tc(3),type{3},table_identity{3},IprefabMax,cond_per_run(3));
                
                % *Wire Information*
                [~,OD,weight,price] = wire_2kv(type{3});
                
                % Calculates the voltdrop percentage
                [~,VD_percent] = voltdrop(wire_l_trunk,Rdc,Itrunk/1.25,Vmax(3));
                
                if min_index<30 && (exist('result_prefab','var'))%((result_mod(1,2)+result_prefab(1,2)+result_trunk(1,2)+VD_offset < VD_desired) || (result_mod(1,2)+result_prefab(1,2)+result_trunk(1,2)-VD_offset < VD_desired))
                    result_trunk=AmpacityVD_results(min_index,VD_percent,price,cond_per_raceway,runs_trunk,wire_l_trunk,OD,weight);
                    
                    % All combinations of all sets of wires, all parameters
                    combinations_size= allcomb(result_mod(1,:),result_prefab(1,:),result_trunk(1,:))';  %Size
                    combinations_VD=allcomb(result_mod(2,:),result_prefab(2,:),result_trunk(2,:))';     %V
                    combinations_cost=allcomb(result_mod(3,:),result_prefab(3,:),result_trunk(3,:))';   %Cost
                    num=length(combinations_size); %Length of combinations
                    
                    % Match combinations of Size, VD, and Cost with
                    % associated length and number of runs
                    combinations_length=[wire_l_mod*ones(1,num);wire_l_prefab*ones(1,num);wire_l_trunk*ones(1,num)]; %Length
                    combinations_runs=[runs_mod*ones(1,num);runs_prefab*ones(1,num);cond_per_raceway*ones(1,num)];   %Runs
                    
                    % Weight of conductor Correction
                    result_trunk(4,:)=cond_per_raceway*result_trunk(4,:);
                    
                    % OD of conductor Correction
                    result_trunk(5,:)=cond_per_raceway*result_trunk(5,:); %times 2 for correct spacing, divide by 2 for layering.
                    
                    %Weight of conductor per 1000 foot at maximum in Trunk(Closest
                    %to GrIP)
                    weight_per_kfoot=repmat(cond_per_raceway*2*result_trunk(4,:),1,length(result_prefab(1,:))*length(result_mod(2,:)));
                    
                    % Width of tray to ensure appropriate spacing of
                    % conductors in Trunk
                    CT_width=repmat(cond_per_raceway*result_trunk(5,:),1,length(result_prefab(1,:))*(length(result_mod(2,:))));
                    
                    %Verticially Concatinate all data into matrix
                    result=vertcat(numSpots*ones(1,num),L*ones(1,num),W*ones(1,num),modality*ones(1,num),CB_size*ones(1,num)...
                        ,num_CB*ones(1,num),combinations_length,combinations_runs,combinations_size,combinations_VD,combinations_cost,...
                        weight_per_kfoot,CT_width);
                    % result_mod(1,2)+result_prefab(1,2)+result_trunk(1,2),result_mod(1,3)+result_prefab(1,3)+result_trunk(1,3)
                else
                    break
                end
                
                if (exist('result_perm','var')==0) %if not yet initialized, Initialize
                    result_perm= result;
                else
                    result_perm=horzcat(result_perm,result); %horizontally concatenate new data
                end
                
                resultant_VD=result_perm(16,:)+result_perm(17,:)+result_perm(18,:);
                % Delete data if lower than desired Volt drop + offset
                delete1=(VD_desired+VD_offset<=resultant_VD);
                % Delete data is higher than desired Volt drop - offset
                delete2=(VD_desired-VD_offset>=resultant_VD);
                result_perm(:,delete1|delete2)=[];
                
                % Clear variables from the workspace
                clear('result_trunk');
                clear('resultant_VD','delete1','delete2','price','Rdc','VD_percent','min_index','CT_width','weight_per_kfoot'); %not sure if these need to be cleared
            end

            % Clear resultant conductors from the workspace
            clear('result_mod','result_prefab','result_trunk','result_spot2prefab');
        end
    end
end

% Creating the Results Table
%--------------------------------------------------------------------------
% Eliminate redundant data
%result_perm=sort_eliminate(result_perm);

total_VD=result_perm(16,:)+result_perm(17,:)+result_perm(18,:);
total_cost=result_perm(19,:)+result_perm(20,:)+result_perm(21,:);
result_perm=vertcat(result_perm,total_VD,total_cost);

[~,I]=sort(result_perm(23,:));      %sorts for lowest price
result_perm=result_perm(:,I);

% Converts ints to strings and stores in cell array
result_perm_cell=cell(size(result_perm));
for i=[13 14 15]
    vector=result_perm(i,:);
    for j=1:numel(result_perm(i,:))
        awg=getString(vector(j));
        result_perm_cell{i,j}=awg;
    end
end

% Converts Bool Values into Strings
for j=1:numel(result_perm(4,:))
    if(result_perm(4,j)==0)
        result_perm_cell{4,j}='Portrait';
    else
        result_perm_cell{4,j}='Landscape';
    end
end

% Carries accross Integers from Matrix
for i=[1 2 3 5 6 7 8 9 10 11 12 16 17 18 19 20 21 22 23 24 25]
    for j=1:numel(result_perm(i,:))
        result_perm_cell{i,j}=result_perm(i,j);
    end
end

% Last Line formatting -- adds header
result_perm_cell=horzcat(column_header,result_perm_cell);

% Add site conditions to Top of Data
%--------------------------------------------------------------------------
%result_perm_cell=vertcat(siteConditions,result_perm_cell); %ADD

% Write to Excel
%--------------------------------------------------------------------------
if(CSV_output==1)
    % FORMAT: cell2csv(fileName, cellArray, separator, excelYear, decimal)
    cell2csv(strcat(CSV_filename,date,'.csv'),result_perm_cell);
end

% Simulation Time
%--------------------------------------------------------------------------
total_time=toc;                     % Time of simulation
disp('Time for Simulation:  ');     % Print 'Time for Simulation'
disp(toc);                          % Print the time