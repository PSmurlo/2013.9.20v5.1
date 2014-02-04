function [result_wire]=AmpacityVD_results(min_index,VD_percent,price,num_cond,runs,wire_l,OD,weight)
if nargin<7
    result_wire=vertcat(VD_percent,price,num_cond*ones(1,30),runs*ones(1,30),wire_l*ones(1,30));
    delete1=1:min_index;
    result_wire(:,delete1)=[];
    sizes=min_index+1:30;
    result_wire=vertcat(sizes,result_wire);
    delete2=(result_wire(3,:)==0);
    result_wire(:,delete2)=[];
    if(exist('result_wire','var'))
        result_wire(3,:)=result_wire(3,:).*(result_wire(5,1)*result_wire(6,1));
    end
elseif nargin==8
    result_wire=vertcat(VD_percent,price,num_cond*ones(1,30),runs*ones(1,30),wire_l*ones(1,30),OD,weight);
    delete1=1:min_index;
    result_wire(:,delete1)=[];
    sizes=min_index+1:30;
    result_wire=vertcat(sizes,result_wire);
    delete2=(result_wire(3,:)==0);
    result_wire(:,delete2)=[];
    if(exist('result_wire','var')&& (numel(result_wire)>0))
        result_wire(3,:)=result_wire(3,:).*(result_wire(5,1)*result_wire(6,1));
    end
end

% if nargin>7 
%     for i=1:(num_sizes-min_index+1)
%         size(i)=min_index-1+i;
%         price_temp(i)=(price(min_index-1+i))*(num_cond*runs*wire_l);
%         VD_percent_temp(i)=(VD_percent(min_index-1+i));
%         OD_temp(i)=OD(min_index-1+i);
%         weight_temp(i)=weight(min_index-1+i);
%     end
%     
%     result_wire= vertcat(size,VD_percent_temp,price_temp,weight_temp,OD_temp);
%     trash=(result_wire(3,:)==0);
%     result_wire(:,trash)=[];
%     
% end
% if nargin == 7
%     for i=1:(num_sizes-min_index+1)
%         size(i)=min_index-1+i;
%         price_temp(i)=(price(min_index-1+i))*(num_cond*runs*wire_l);
%         VD_percent_temp(i)=(VD_percent(min_index-1+i));
%         
%     end
%     %*Voltage Drop*
%     
%     
%     result_wire= vertcat(size,VD_percent_temp,price_temp);
%     trash=(result_wire(3,:)==0);
%     result_wire(:,trash)=[];
% end
% % trash=0;
% % for k=1:length(size)
% %     if(result_wire(3,k) == 0)
% %         trash=horzcat(trash,k);
% %     end
% %
% % end
% % trash(1)=[];
% result_wire(:,trash)=[];