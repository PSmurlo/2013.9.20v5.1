function [finalData,trunkTables,CBtable] = ConventionalOptimization(handles)
%CONVENTIONALOPTIMIZATIONV4 Optimizes a conventional central Inverter system
%   [finalData] = ConventionalOptimizationv4() determines the finalData through
%   global variables which are changed in the GUI.
%
%   See also ALENCONOPTIMIZATIONV4

global modPV inv eleDim % both in Alencon as well
global tableW type
global priceString convPriceTrunk
global m2cbRes cb2invRes
global xLim yLim

addpath('NEC');
finalData=[];
trunkTables=[];
CBtable=[];

% % required DC size
% DCsize_half=inv.pdco*inv.DC_AC.target*2;
% tablesPerHalf=DCsize_half/tableW;
% eleDim.tablesPerHalf.Range=ceil(tablesPerHalf*(1-inv.DC_AC.variance)):floor(tablesPerHalf*(1+inv.DC_AC.variance));
tables=str2double(get(handles.listTables,'String'))/((inv.num_inverters/inv.perPad)*2);

if(type(1,2)==0)% Conventional trunk
    maxAWG=20; % Al
else
    maxAWG=20; % Cu
end
CBtable1=get(handles.CBtable,'Data');
% Find all information about combiner box layouts
CB=PossibleCB2(tables,maxAWG,CBtable1);
for i= 1:length(CB)
    % 1: Tables per Combiner box
    % 2: maximum over current protection
    % 3: cost
    % 4: Tables per Half
    % 5: Tables for Half Width
    % 6: Tables for half Height
    % 7: Combiner Box width in Tables
    % 8: combiner box height in tables
    % 9: number of trunks
    % 10: Minimum Wire Size Index for Combiner Box conductor (1-30) 18AWG to
    %   1500kcmil
    % 11: Number of Combiner Boxes Utilized (smaller than row 12 if not all filled)
    % 12: Number of Combiner Boxes in array
    % 13: Strings per Combiner Box
    % 14: kW STC of the entire array
    info.tablePerCB=CB(1,i);
    info.CBmaxCurrent=CB(2,i);
    CostCBraw=CB(3,i);
    info.tablePerHalf=CB(4,i);
    info.hW=CB(5,i);
    info.hH=CB(6,i);
    info.CBW=CB(7,i); % is non-integer
    info.CBH=CB(8,i); % is non-integer
    info.numtrunks=CB(9,i);
    info.CBminIndex=CB(10,i);
    info.numCButilized=CB(11,i);
    info.numCB=CB(12,i);
    info.stringsPerCB=CB(13,i);
    info.kWSTCarray=CB(14,i);
    
    %% Lengths
    % Constant for all wire sizes
    
    %string run lengths
    [raw.wire.m2cb,longestm2cb1way] = stringRuns(info.hW,info.hH,eleDim.totW,eleDim.totH,info.CBW,info.CBH,eleDim.modality,info.numtrunks);
    
    % Combiner Box to bend
    [~,raw.wire.cb2bend,info.Hleft] = aluminumRuns(info.hH,eleDim.totH,info.CBH,str2double(get(handles.Array2Inverter,'String'))); % total wire length north-south (meters)
    
    % Bend to Inverter
    [raw.wire.cb2inv,longestcb2inv1way] = Bend2Inveter(info.hW,eleDim.totW,info.CBW,info.numtrunks,raw.wire.cb2bend);
    
    % Cable tray
    %raw.CT.m2cb=((info.hW-2)*eleDim.totW*info.hH + ((info.CBH-1) * eleDim.totH * info.numCB));
    %
    %raw.CT.cb2inv = CB2invCT(raw.wire.cb2inv1,info.CBH,info.numtrunks,trunkInfo);
    
    %% DC Power
    totalW=tableW*info.hW*info.hH*2*(inv.num_inverters/inv.perPad);
    
    for m = info.CBminIndex:maxAWG %Size up this conductor up to the maximum allowable size
        %         if(info.qH/(info.numCB*2/inv.num_inverters) >= mod(info.qH,(info.numCB*2/inv.num_inverters)))
        
        info.index=m; % throw index into struct for portability
        
        % number of combiner boxes is both information about array and a raw part
        raw.numCB=info.numCB;
        
        %% Losses
        % VD for
        [~,vd.stringmax] = voltDrop(longestm2cb1way*2,    m2cbRes(5),             modPV.Imp,                  modPV.Vmpmax); % VD of 10 gauge strings
        [~,vd.cb2invmax] = voltDrop(longestcb2inv1way,  cb2invRes(info.index),  modPV.Imp*info.stringsPerCB,modPV.Vmpmax); % VD of chosen cb to inverter conductors
        vd.max = vd.stringmax + vd.cb2invmax; %Total MAX VD
        
        [trunkInfo] = downSizeRuns(raw.wire.cb2inv,...
            vd.cb2invmax,...
            info.stringsPerCB,...
            info.CBminIndex,...
            maxAWG,...
            ampacityCheck(1,2,'15b17',modPV.Isc*1.25*1.25*info.Hleft*2*(info.hW/(info.numtrunks*2))*4),...
            cb2invRes,...
            convPriceTrunk);
        
        info.trunkInfo=trunkInfo(:,1);
        
        if get(handles.kWh_DPW,'Value')
            [kWhLoss] = kWhLossFuncConventional(info.tablePerHalf,trunkInfo,info.stringsPerCB,raw.wire.m2cb,raw.numCB);
        else
            kWhLoss.lifecycle.total=0;
            kWhLoss.lifecycle.m2cb=0;
            kWhLoss.lifecycle.cb2inv=0;
        end
        %% Costs
        % Conductor costs
 
        cost.wire.m2cb = (raw.wire.m2cb*(inv.num_inverters/inv.perPad))*(priceString(5)/1000); % $/m times m = dollars
        cost.wire.cb2inv1 = sum(trunkInfo(:,8));
        
        % Inverter Cost
        cost.inverter=str2double(get(handles.costInverter,'String'))*str2double(get(handles.ACMW,'String'))*1000000;
        
        % Cost of Combiner Box
        cost.CB.raw = raw.numCB*CostCBraw;
        
        % Conductor raw total
        cost.wire.raw= cost.wire.m2cb +cost.wire.cb2inv1;
        
        cost.total=cost.wire.raw+cost.CB.raw+cost.inverter;
        
        if get(handles.VD_DPW,'Value')==1
            yAxis=vd.max;
            xAxis=cost.total/totalW;
        else
            yAxis=kWhLoss.lifecycle.total;
            xAxis=cost.total/totalW;
        end
        
        if (yAxis < yLim(2)) & (xAxis < xLim(2)) & (yAxis > yLim(1)) & (xAxis > xLim(1)) % Save result if below max voltage drop and max cost
            [~,tableData] = finalDataExtract(handles,cost,raw,vd,kWhLoss,info);
            trunkTables=vertcat(trunkTables,{trunkInfo});
            CBtable=vertcat(CBtable,{CB(i)});
            finalData=vertcat(finalData,tableData);
        else
            trunkInfo=[];
            tableData=[];
            continue
        end
        clear cost vd
    end
    
end