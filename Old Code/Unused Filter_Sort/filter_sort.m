function [result_array]=filter_sort(result_wire)
to_delete=0;
[~,I]=sort(result_wire(3,:));
result_wire=result_wire(:,I);
vd=result_wire(2,:);
for i=1:length(vd)-1
    if(vd(i+1)>=vd(1) || vd(i+1)==vd(i))
        to_delete=horzcat(to_delete,i+1);
    end
end
to_delete(1)=[];
if(length(to_delete)>1)
    result_wire(:,to_delete)=[];
end
clear('to_delete','i')
to_delete=0;
[~,I]=sort(result_wire(2,:));
result_wire=result_wire(:,I);
cost=result_wire(3,:);
for i=1:length(cost)-1
    if(cost(i+1)>=cost(1))
        to_delete=horzcat(to_delete,i+1);
    end
end
to_delete(1)=[];
if(length(to_delete)>1)
    result_wire(:,to_delete)=[];
end
result_array=result_wire;