function [result_wire]=sort_eliminate(result_wire)
% to_delete=0;
[~,I]=sort(result_wire(3,:)); %sorts by price
result_wire=result_wire(:,I);
vd=result_wire(2,:);
delete=(vd>=vd(1)); %eliminates anything with higher VD than most expensive
result_wire(:,delete)=[];

%sort cost
clear('delete','i')
[~,I]=sort(result_wire(2,:));%sorts by cost
result_wire=result_wire(:,I);
cost=result_wire(3,:);
delete=(cost>=cost(1)); %eliminates anything with higher cost than highest VD
result_wire(:,delete)=[];

% for i=1:length(vd)-1
%     if(vd(i+1)>=vd(1) || vd(i+1)==vd(i))
%         to_delete=horzcat(to_delete,i+1);
%     end
% end
% to_delete(1)=[];
% if(length(to_delete)>1)
%     result_wire(:,to_delete)=[];
% end

% to_delete=0;

% for i=1:length(cost)-1
%     if(cost(i+1)>=cost(1))
%         to_delete=horzcat(to_delete,i+1);
%     end
% end
% to_delete(1)=[];
% if(length(to_delete)>1)
%     result_wire(:,to_delete)=[];
% end