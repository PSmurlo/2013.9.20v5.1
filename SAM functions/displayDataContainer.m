function [data_display]=displayDataContainer(data)
data_display{1}=ssccall('data_first',data); % Displays all data in container
k=1;
while(1)
    k=k+1;
    data_display{k}=ssccall('data_next',data);
    if isempty(data_display{k})==1
        break
    end
end
data_display=data_display';