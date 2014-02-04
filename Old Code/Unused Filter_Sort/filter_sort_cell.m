function [result_array]=filter_sort_cell(result)
index=0;
to_delete=0;
result=sortcell(result',5)';
vd=result(4,:);
for i=1:length(vd)-1
    if(vd{i+1}>=vd{1})
        index=index+1;
        to_delete(index)=i+1;   
    end
end
if(length(to_delete)>1)
    result(:,to_delete)=[];
end
clear('to_delete','index','i')
to_delete=0;
index=0;
result=sortcell(result',4)';
cost=result(5,:);
for i=1:length(cost)-1
    if(cost{i+1} >= cost{1})
        index=index+1;
        to_delete(index)=i+1;
    end
end
if(length(to_delete)>1)
    result(:,to_delete)=[];
end

result_array=result;