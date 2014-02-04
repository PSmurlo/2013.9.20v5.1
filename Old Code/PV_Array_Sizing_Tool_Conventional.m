%% Conventional PV array sizing calculator
clc;
close all;
clear all;
profile on
tic

% Wire Size Index
size_index=cellstr(['18  ';'16  ';'14  ';'12  ';'10  ';'8   ';'6   ';'4   ';'3   ';'2   ';'1   ';'1/0 ';'2/0 ';'3/0 ';'4/0 ';'250 ';'300 ';'350 ';'400 ';'500 ';'600 ';'700 ';'750 ';'800 ';'900 ';'1000';'1250';'1500';'1750';'2000']);
num_sizes= length(size_index);

%Toggles/Inputs
modality=1;             %Landscape:1 Portrait:0
VD_desired=2;           %percent voltage drop desired
VD_offset=.05;          %percent voltage drop difference allowed than desired
min_DC_to_AC=1.5; %X:1   %maximum DC:AC Ratio
max_DC_to_AC=1.7; %X:1   %percent oversize of number of SPOTs
CSV_output=1;           %enables CSV output
skid_toggle=1;          %enables skid
CSV_filename='VoltDropWithCBPortrait';

% Temperature
Ta=     37;          %AHRAE 2% Dry Bulb Temp
Tmin=   -14;         %ASHRAE Mean Low Temp
% Tdelta=(none)      %Roof correction temp
%                       %Roof corrected temp

% Size Determinants
lat=39;             %Latitude
tilt=25;            %Tilt angle of array

% Inverter Characteristics
if(skid_toggle==0)
    Inverter_size=500;    %Total Inverter size in kW
else
    Inverter_size=2000;    %Total skid size in kW
end %decides whether skid mounted vs individual inverters

% Module Nameplate Data  %**have access to CEC module database, in future
% will be able to import ALL module data**
Name='Renesola 300W 72 cell poly c-Si';
STC_kW=.300;
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
    %not sure if works(!!)
    MpS= floor(Vocmax_module/(Voc-(Tvoc*(25-Tmin))));
    Vmpmax=MpS*(Vmp-Tvmp*(25-Ta)); %used for VD calc of string wiring
else
    MpS= floor(Vocmax_module/(Voc*(1+((-Tvoc)*(25-Tmin)/100))));
    Vmpmax=MpS*(Vmp-Tvmp*(25-Ta)); %used for VD calc of string wiring
end %calculates Vmaxpower and Modules per string

% Modality Selection
if(modality==0)
    rows=2;
    cols=MpS;
    [tot_l,tot_w]=rackDim(lat,rows,cols,tilt,mod_l,mod_w,modality);
else
    rows=4;
    cols=MpS;
    [tot_l,tot_w]=rackDim(lat,rows,cols,tilt,mod_l,mod_w,modality);
end  %portrait or landscape

% Inverter Sizing
min_tables=Inverter_size/(rows*MpS*STC_kW); %1:1 DC:AC


% Combiner Box Information

CB_info=[   720,540,720;    %maximum current
    576,346,576;    %maximum continuous current
    3,3,3;          %minimum size input
    7,7,7;          %maximum size input
    10,10,10;       %minimum size output
    21,21,21;       %maximum size output
    24,36,48;];     %maximum number of strings

Imax = Isc*1.25;
OCPD = Imax*1.25;

if(OCPD>15)
    CB_info(:,3)=[];
elseif(OCPD>20)
    CB_info(:,2)=[];
    CB_info(:,3)=[];
elseif(OCPD>30)
    CB_info(:,1)=[];
    CB_info(:,2)=[];
    CB_info(:,3)=[];
    disp('All CBs Dont work');
end % makes sure combiner box passes over current protection requirements
num_tables= floor(min_tables*(min_DC_to_AC)):ceil(min_tables*(max_DC_to_AC));
tables_per_CB=floor(CB_info(7,:)/rows);
num_cb=num_tables'*(1./tables_per_CB);
num_cb=vertcat(CB_info(7,:),num_cb);
num_tables=num_tables';
num_tables=vertcat(0,num_tables);
num_cb=horzcat(num_tables,num_cb);
index1=0;
for i=2:length(num_cb)
    for j=2:length(num_cb(1,:))
        if(mod(num_cb(i,j),1)==0)
            index1=index1+1;
            CB_stuff(1,index1)=num_cb(i,1);%number of tables
            CB_stuff(2,index1)=num_cb(1,j);%max strings per CB
            CB_stuff(3,index1)=num_cb(i,j);%number of CBs
            CB_stuff(4,index1)=num_cb(i,1)./num_cb(i,j); %tables per CB
            CB_stuff(5,index1)=num_cb(i,1)/min_tables; %DC:AC ratio
            CB_stuff(6,index1)=num_cb(i,j)/4; %CBs per quad
            CB_stuff(7,index1)=num_cb(i,1)/4; %tables per quad
        end
    end
end
delete=(mod(CB_stuff(3,:),4)~=0);
CB_stuff(:,delete)=[];
CB_stuff_cell=num2cell(CB_stuff);
header=cellstr(['number of tables  ';'max strings per CB';'number of CBs     ';'tables per CB     ';'DC:AC ratio       ';'CBs per quad      ';'Tables per quad   ']);
CB_stuff_cell=horzcat(header,CB_stuff_cell);
disp(CB_stuff_cell);
for condition=1:length(CB_stuff(7,:));
    L=1:CB_stuff(7,condition);
    W=(CB_stuff(7,condition))./L;
    possible_dim=vertcat(L,W);
    delete2=(mod(possible_dim(2,:),1)>0);
    possible_dim(:,delete2)=[];
    
    if (exist('all_dim','var')==0)
        all_dim= possible_dim;
    else
        all_dim=horzcat(all_dim,possible_dim);
    end   
end
all_dim=sort_filter_duplicate(all_dim);
%%
index=1;

%%InputInfo
table_identity{1}='15b17';
type{1}='Cu';
Tc(1)=75;
Vmax(1)=1000;

table_identity{2}='15b17';
type{2}='Cu';
Tc(2)=75;
Vmax(2)=1000;

%% String Wiring

% Number of runs_mod
runs_mod=tables_per_CB*rows*2; %up to size of combiner box*2 (2wires per string)

%determine number of conductors per raceway
[runs_length]=st
cond_per_raceway=1; %n/a because free air conductors not in raceway
% Derate and ampacity check
[min_index,Rdc]=ampacity_check(Tc(1),type{1},table_identity{1},OCPD,cond_per_raceway);

%*Ampacity and Volt drop*
[~,~,~,price] = wire_2kv(type,2);
[total_price,~,~]=per_foot2total(price,runs_length,runs_mod,num_CB);
[~,VD_percent]= voltdrop(wire_l_mod,Rdc,Imp,Vmpmax);

result_mod=AmpacityVD_results(min_index,VD_percent,price,cond_per_raceway,runs_mod,wire_l_mod);
clear ('chart','type','Tc','cond_per_run','Vmax','Imax','OCPD','table','tTa','temp_derate','numcond_derate','deratedAmpacity','price','Rdc','VD_percent','min_index');

%% Combiner Box Wiring

%*Ampacity*


%*Voltage Drop*
wire_l_prefab=tot_l*((L/2)-1);
runs_prefab=W*2;

%*tables and derates*
[table,tTa] = table310_select(table_identity);
temp_derate = temp_derate_formula(Ta,tTa,Tc);
numcond_derate=numcond_derate_chart(cond_per_run);
deratedAmpacity=Iprefab/(temp_derate*numcond_derate);
%*Ampacity and Volt drop*
[~,~,~,price] = wire_2kv(type,2);
Rdc = resist(Tc,type);
[~,VD_percent]= voltdrop(wire_l_prefab,Rdc,(Iprefab/1.25),Vmax);
[min_index] = table310_size(table,type,Tc,deratedAmpacity);
if(min_index<30)
    result_prefab=AmpacityVD_results(num_sizes,min_index,VD_percent,price,cond_per_run,runs_prefab,wire_l_prefab);
end
clear ('chart','type','Tc','cond_per_run','Vmax','Imax','OCPD','table','tTa','temp_derate','numcond_derate','deratedAmpacity','price','Rdc','VD_percent','min_index');

%% 'trunk'

%*Ampacity*
table_identity='15b17';
type='Al';
Tc=75;
Vmax=2500;

if(enable_secondary_CB)
    CB_size_option=[1,2,4,6,8,10]; %possible CB sizes (preferred even numbers)
else
    CB_size_option=[1,2]; %no CB or 2 to 1 plug (no fusing required)
end
for CB_size=CB_size_option
    wire_l_trunk=0; %starts at zero at beginning of loop
    trunk_l=0;
    
    num_CB=ceil(W/CB_size);
    CB_spacing=tot_w*((W/2)/CB_size);%width of SPOT element by however many number of combiner box fit in the spacing
    
    for i=1:num_CB
        trunk_l(i)=CB_spacing/2+(i-1)*CB_spacing; %first is half of a spacing (so that the CB is in the center of the spacing) adding all of the lengths up
    end
    wire_l_trunk=mean(trunk_l); %average length of conductor (since VD is proportional to length, this is adequate to find average voltage drop)
    cond_per_run=2*num_CB; %number of conductors per run, i.e. number of runs in cable tray (2 for positive and negative rails)
    runs_trunk=2; %number of total trunk runs (if array is split top/bottom), this is two.
    Itrunk=Iprefab*CB_size; %current through one trunk conductor, taken from the prefab current
    [table,tTa] = table310_select(table_identity);
    temp_derate = temp_derate_formula(Ta,tTa,Tc);
    numcond_derate=numcond_derate_chart(cond_per_run);
    deratedAmpacity=Itrunk/(temp_derate*numcond_derate);
    %*Ampacity and Volt drop*
    [~,OD,~,price] = wire_2kv(type,2);
    Rdc = resist(Tc,type);
    [~,VD_percent]= voltdrop(wire_l_trunk,Rdc,Itrunk/1.25,Vmax);
    [min_index] = table310_size(table,type,Tc,deratedAmpacity);
    
    if(min_index<30)%((result_mod(1,2)+result_prefab(1,2)+result_trunk(1,2)+VD_offset < VD_desired) || (result_mod(1,2)+result_prefab(1,2)+result_trunk(1,2)-VD_offset < VD_desired))
        result_trunk=AmpacityVD_results(num_sizes,min_index,VD_percent,price,cond_per_run,runs_trunk,wire_l_trunk);
        combinations_size= allcomb(result_mod(1,:),result_prefab(1,:),result_trunk(1,:))';
        combinations_VD=allcomb(result_mod(2,:),result_prefab(2,:),result_trunk(2,:))';
        combinations_cost=allcomb(result_mod(3,:),result_prefab(3,:),result_trunk(3,:))';
        Leng=length(combinations_size);
        combinations_length=[wire_l_mod*ones(1,Leng);wire_l_prefab*ones(1,Leng);wire_l_trunk*ones(1,Leng)];
        combinations_runs=[runs_mod*ones(1,Leng);runs_prefab*ones(1,Leng);cond_per_run*ones(1,Leng)];
        result=vertcat(num_tables*ones(1,Leng),L*ones(1,Leng),W*ones(1,Leng),modality*ones(1,Leng),CB_size*ones(1,Leng),num_CB*ones(1,Leng),combinations_length,combinations_runs,combinations_size,combinations_VD,combinations_cost);
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
    clear ('trunk_l','cond_per_run','table','tTa','temp_derate','numcond_derate','deratedAmpacity','price','Rdc','VD_percent','min_index');
end
clear('result_mod','result_prefab','result_trunk','result_spot2prefab');

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

for i=[1 2 3 5 6 7 8 9 10 11 12 16 17 18 19 20 21 22 23]
    for j=1:numel(result_perm(i,:))
        result_perm_cell{i,j}=result_perm(i,j);
    end
end

% Last Line formatting -- adds header
% Headers:
% row_header=cellstr(['    '.'DesiredVD',VD_desired,'+/-',VD_offset,DC])
column_header=cellstr(['numSpots     ';'L            ';'W            ';'modality     ';'CB_size      ';'num_CB       ';'length_mod   ';'length_prefab';'length_trunk ';'runs_mod     ';'runs_prefab  ';'runs_trunk   ';'size_mod     ';'size_prefab  ';'size_trunk   ';'vd_mod       ';'vd_prefab    ';'vd_trunk     ';'cost_mod     ';'cost_prefab  ';'cost_trunk   ';'total_VD     ';'total_cost   ']);
result_perm_cell=horzcat(column_header,result_perm_cell);

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