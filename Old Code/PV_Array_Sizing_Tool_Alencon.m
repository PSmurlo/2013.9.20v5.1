%% Alencon PV array sizing calculator
clc;
close all;
clear all;
tic

% Wire Size Index
size_index=cellstr(['18  ';'16  ';'14  ';'12  ';'10  ';'8   ';'6   ';'4   ';'3   ';'2   ';'1   ';'1/0 ';'2/0 ';'3/0 ';'4/0 ';'250 ';'300 ';'350 ';'400 ';'500 ';'600 ';'700 ';'750 ';'800 ';'900 ';'1000';'1250';'1500';'1750';'2000']);
num_sizes= length(size_index);

% Temperature
Ta=   37;          %AHRAE 2% Dry Bulb Temp
Tmin= -14;         %ASHRAE Mean Low Temp
% Tdelta=(none)      %Roof correction temp
%                       %Roof corrected temp

% Alencon Characteristics
GrIP_size=10000;    %Total Array size in kW
SPOT_size=25;       %kW rating of SPOT
spotSize=4;         %string per SPOT

% Module Nameplate Data  %**have access to CEC module database, in future
% will be able to import ALL module data**
Name='Renesola 300W 72 cell poly c-Si';
Voc= 44.8;
Vmp= 36.6;
Isc=8.69;
Imp=8.20;
Tvoc= -.30;         %percent/C
Tisc= -.04;
Tvmp= -.4;
mod_l=1.996;           %Module Length (*Longer side*) (m)
mod_w=.994;            %Module Width (m)
percent_per_C=1;
Vocmax_module=1000;
% Nameplate Calculations

if(percent_per_C==0)
    MpS= floor(Vocmax_module/(Voc-(Tvoc*(25-Tmin))));
    Vmpmax=MpS*(Vmp-Tvmp*(25-Ta)); %used for VD calc of string wiring
else
    MpS= floor(Vocmax_module/(Voc*(1+((-Tvoc)*(25-Tmin)/100))));
    Vmpmax=MpS*(Vmp-Tvmp*(25-Ta)); %used for VD calc of string wiring
end

% Size Determinants
lat=39;             %Latitude
tilt=25;            %Tilt angle of array

%Toggles/Inputs
modality=1;             %Landscape:1 Portrait:0
string_per_row=1;       %one or two
enable_secondary_CB=0;  %0:disable 1:enable
VD_desired=2;           %percent voltage drop desired
VD_offset=.1;          %percent voltage drop difference allowed than desired
min_DC_to_AC=1.2; %X:1   %maximum DC:AC Ratio
max_DC_to_AC=1.5; %X:1   %percent oversize of number of SPOTs
CSV_output=0;           %enables CSV output
CSV_filename='VoltDropPortrait';

% Headers:
% row_header=cellstr(['    '.'DesiredVD',VD_desired,'+/-',VD_offset,DC])
column_header=cellstr(['numSpots     ';'L            ';'W            ';'modality     ';'CB_size      ';'num_CB       ';'length_mod   ';'length_prefab';'length_trunk ';'runs_mod     ';'runs_prefab  ';'runs_trunk   ';'size_mod     ';'size_prefab  ';'size_trunk   ';'vd_mod       ';'vd_prefab    ';'vd_trunk     ';'cost_mod     ';'cost_prefab  ';'cost_trunk   ';'Weight_kfoot ';'CT_width     ';'total_VD     ';'total_cost   ']);
%%
index=1;

%total number of SPOTs
for numSpots= floor(400*(min_DC_to_AC)):ceil(400*(max_DC_to_AC));
    %number of SPOT elements in length
    for L=4:numSpots;
        %%
        %number of SPOT elements in width
        W=numSpots/L;
        %%
        if(mod(W,1)==0 && isodd(L)==0 && isodd(W)==0)
            %% 'mod2SPOT'
            
            table_identity='15b17';
            type='Cu';
            Tc=75;
            cond_per_raceway=2;
            Imax = Isc*1.25;
            OCPD = Imax*1.25;
            
            % Selects array modality and configuration of SPOT element
            if(modality==0)
                rows=2;
                cols=MpS*2;
                [tot_l,tot_w]=rackDim(lat,rows,cols,tilt,mod_l,mod_w,modality);
                wire_l_mod=tot_l/2;
            else
                rows=4;
                cols=MpS;
                [tot_l,tot_w]=rackDim(lat,rows,cols,tilt,mod_l,mod_w,modality);
                wire_l_mod=tot_l;
                
            end
            %Number of runs_mod
            runs_mod=numSpots*4;
            
            %tables and derates
            
            [min_index,Rdc]=ampacity_check(Ta,Tc,type,table_identity,OCPD,cond_per_raceway);
            
            %*Ampacity and Volt drop*
            [~,~,~,price] = wire_2kv(type);
            [~,VD_percent]= voltdrop(wire_l_mod,Rdc,Imp,Vmpmax);
            result_mod=AmpacityVD_results(min_index,VD_percent,price,cond_per_raceway,runs_mod,wire_l_mod);            clear ('chart','type','Tc','cond_per_run','Vmax','Imax','OCPD','table','tTa','temp_derate','numcond_derate','deratedAmpacity','price','Rdc','VD_percent','min_index');
            %% 'spot2prefab'
            %omitted from most of code due to having little effect on
            %overall wiring, or system layout. not specified in output
            
            %*Ampacity*
            table_identity='15b17';
            type='Cu';
            Tc=75;
            cond_per_raceway=2;
            Vmax=2500;
            Imax=(25000/Vmax)*1.25;
            % OCPD = Imax*1.25;%not needed, isolated from PV circuit
            [min_index,~]=ampacity_check(Ta,Tc,type,table_identity,Imax,cond_per_raceway);

            result_spot2prefab=min_index; %lowest ampacity, volt drop not a concern
            %*Voltage Drop*
            %~0 due to extremely short length
            clear('min_index','Rdc','chart','type','Tc','cond_per_run','Vmax','Imax','OCPD','table','tTa','temp_derate','numcond_derate','deratedAmpacity','price','Rdc','VD_percent','min_index');
            %% 'prefab2trunk'
            
            %*Ampacity*
            table_identity='15b17';
            type='Cu';
            Tc=75;
            cond_per_raceway=2;
            Vmax=2500;
            Imax=(25000/Vmax)*1.25;
            Iprefab=Imax*L/2;
            
            %*Voltage Drop*
            wire_l_prefab=tot_l*((L/2)-1);
            runs_prefab=W*2;
            
            %*Ampacity reduction*
            [min_index,Rdc]=ampacity_check(Ta,Tc,type,table_identity,Iprefab,cond_per_raceway);
            %*Ampacity and Volt drop*
            [~,~,~,price] = wire_2kv(type);
           
            [~,VD_percent]= voltdrop(wire_l_prefab,Rdc,(Iprefab/1.25),Vmax);
           
            if(min_index<30)
             result_prefab=AmpacityVD_results(min_index,VD_percent,price,cond_per_raceway,runs_prefab,wire_l_prefab);
            end
            
            clear ('min_index','Rdc','chart','type','Tc','cond_per_run','Vmax','Imax','OCPD','table','tTa','temp_derate','numcond_derate','deratedAmpacity','price','Rdc','VD_percent','min_index');
            
            %% 'trunk'
            
            %*Ampacity*
            table_identity='15b17';
            type='Cu';
            Tc=90; %maybe-- further research needed
            Vmax=2500;
            
            if(enable_secondary_CB)
                CB_size_option=[1,2,4,6,8,10]; %possible CB sizes (preferred even numbers)
            else
                CB_size_option=[1,2]; %no CB or 2 to 1 plug (no fusing required)
            end
            for CB_size=CB_size_option
                %starts at zero at beginning of loop
                trunk_l=0;
                
                num_CB=ceil(W/CB_size);
                CB_spacing=tot_w*((W/2)/CB_size);%width of SPOT element by however many number of combiner box fit in the spacing
                
                for i=1:num_CB
                    trunk_l(i)=CB_spacing/2+(i-1)*CB_spacing; %first is half of a spacing (so that the CB is in the center of the spacing) adding all of the lengths up
                end
                wire_l_trunk=mean(trunk_l); %average length of conductor (since VD is proportional to length, this is adequate to find average voltage drop)
                cond_per_raceway=2*num_CB; %number of conductors per run, i.e. number of runs in cable tray (2 for positive and negative rails)
                runs_trunk=2; %number of total trunk runs (if array is split top/bottom), this is two.
                Itrunk=Iprefab*CB_size; %current through one trunk conductor, taken from the prefab current
                [table,tTa] = table310_select(table_identity);
                temp_derate = temp_derate_formula(Ta,tTa,Tc);
                numcond_derate=numcond_derate_chart(1);
                deratedAmpacity=Itrunk/(temp_derate*numcond_derate);
                %*Ampacity and Volt drop*
                [~,OD,weight,price] = wire_2kv(type);
                Rdc = resist(Tc,type);
                [~,VD_percent]= voltdrop(wire_l_trunk,Rdc,Itrunk/1.25,Vmax);
                [min_index] = table310_size(table,type,Tc,deratedAmpacity);
                
                if min_index<30 && (exist('result_prefab','var'))%((result_mod(1,2)+result_prefab(1,2)+result_trunk(1,2)+VD_offset < VD_desired) || (result_mod(1,2)+result_prefab(1,2)+result_trunk(1,2)-VD_offset < VD_desired))
                    result_trunk=AmpacityVD_results(min_index,VD_percent,price,cond_per_raceway,runs_trunk,wire_l_trunk,OD,weight);
                    combinations_size= allcomb(result_mod(1,:),result_prefab(1,:),result_trunk(1,:))';
                    combinations_VD=allcomb(result_mod(2,:),result_prefab(2,:),result_trunk(2,:))';
                    combinations_cost=allcomb(result_mod(3,:),result_prefab(3,:),result_trunk(3,:))';
                    Leng=length(combinations_size);
                    combinations_length=[wire_l_mod*ones(1,Leng);wire_l_prefab*ones(1,Leng);wire_l_trunk*ones(1,Leng)];
                    combinations_runs=[runs_mod*ones(1,Leng);runs_prefab*ones(1,Leng);cond_per_raceway*ones(1,Leng)];
                    result_trunk(4,:)=cond_per_raceway*result_trunk(4,:);
                    result_trunk(5,:)=cond_per_raceway*2*result_trunk(5,:);
                    weight_per_kfoot=repmat(cond_per_raceway*2*result_trunk(4,:),1,length(result_prefab(1,:))*length(result_mod(2,:)));
                    CT_width=repmat(cond_per_raceway*result_trunk(5,:),1,length(result_prefab(1,:))*(length(result_mod(2,:))));
                    disp(CT_width);
                    result=vertcat(numSpots*ones(1,Leng),L*ones(1,Leng),W*ones(1,Leng),modality*ones(1,Leng),CB_size*ones(1,Leng),num_CB*ones(1,Leng),combinations_length,combinations_runs,combinations_size,combinations_VD,combinations_cost,weight_per_kfoot,CT_width);
                    %result_mod(1,2)+result_prefab(1,2)+result_trunk(1,2),result_mod(1,3)+result_prefab(1,3)+result_trunk(1,3)
                else
                    break
                end
                if (exist('result_perm','var')==0)
                    result_perm= result;
                else
                    result_perm=horzcat(result_perm,result);
                end
                clear('result_trunk');
                clear ('trunk_l','cond_per_run','table','tTa','temp_derate','numcond_derate','deratedAmpacity','price','Rdc','VD_percent','min_index','CT_width','weight_per_kfoot');
            end
            clear('result_mod','result_prefab','result_trunk','result_spot2prefab');
        end
    end
end
result_perm=sort_eliminate(result_perm);
delete1=(VD_desired+VD_offset<=result_perm(16,:)+result_perm(17,:)+result_perm(18,:));
result_perm(:,delete1)=[];
delete2=(VD_desired-VD_offset>=result_perm(16,:)+result_perm(17,:)+result_perm(18,:));
result_perm(:,delete2)=[];

total_VD=result_perm(16,:)+result_perm(17,:)+result_perm(18,:);
total_cost=result_perm(19,:)+result_perm(20,:)+result_perm(21,:);
result_perm=vertcat(result_perm,total_VD,total_cost);

[~,I]=sort(result_perm(23,:));%sorts for lowest price
result_perm=result_perm(:,I);


% converts ints to strings and stores in cell array
result_perm_cell=cell(size(result_perm));
for i=[13 14 15]
    vector=result_perm(i,:);
    for j=1:numel(result_perm(i,:))
        awg=getString(vector(j));
        result_perm_cell{i,j}=awg;
    end
end

for j=1:numel(result_perm(4,:))
    if(result_perm(4,j)==0)
        result_perm_cell{4,j}='Portrait';
    else
        result_perm_cell{4,j}='Landscape';
    end
end

for i=[1 2 3 5 6 7 8 9 10 11 12 16 17 18 19 20 21 22 23 24 25]
    for j=1:numel(result_perm(i,:))
        result_perm_cell{i,j}=result_perm(i,j);
    end
end

% Last Line formatting -- adds header
result_perm_cell=horzcat(column_header,result_perm_cell);
% future: add header row to top as metadata (module information, site
% information, etc)

% Write to Excel:
%cell2csv(fileName, cellArray, separator, excelYear, decimal)
if(CSV_output==1)
    str=date;
    cell2csv(strcat(CSV_filename,date,'.csv'),result_perm_cell);
end
%total time it took for simulation to take place
total_time=toc;
disp('Time for Simulation:  ');
disp(toc);