function [result_array]=sort_filter_duplicate(result_wire)
zero=zeros(length(result_wire(:,1)),1);
[~,I]=sort(result_wire(1,:));
wire1=result_wire(:,I);
wire2=result_wire(:,I);
wire2(:,1)=[];
wire2=horzcat(wire2,zero);
delete=(wire1(1,:)==wire2(1,:));
delete2=(wire1(2,:)==wire2(2,:));
delete3=(delete & delete2);
wire1(:,delete)=[];
result_array=wire1;