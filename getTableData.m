function [ tableData ] = getTableData(sortedData,systemType,i)
%GETTABLEDATA gets the table data and processes certain data into strings
%as required
%   [ tableData ] = getTableData(sortedData,systemType)
%   sortedData is the data which has already been sorted to fit the output
%   systemType is a string, either 'Alencon' or 'Conventional' to dictate
%   which to use

global sizesAWG

if      (strcmp(systemType,'Alencon'))
    tableData = num2cell(sortedData(i,:));
    wireNames = sizesAWG{tableData{:,25}}';
%     direction = prefabDirection(tableData(:,20));
     tableData(:,25) = [];
%     tableData = num2cell(tableData);
    tableData = horzcat(tableData,wireNames);
    
elseif (strcmp(systemType,'Conventional'))    
    tableData = num2cell(sortedData(i,:));
    wireNames = sizesAWG{tableData{:,25}}';
%     direction = '              -----';
%     noSpots= '              -----';
     tableData(:,25) = [];
%     tableData = num2cell(tableData);
    tableData = horzcat(tableData,wireNames);
    
else
    disp('Enter Correct SystemType');
end


