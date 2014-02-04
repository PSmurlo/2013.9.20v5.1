close
dele=1;
finishdata=zeros(16,10783);
for k=1:10782
    for i=[1 18]
        data=textdata{i,k};
        if i==1
            for j=1:6
                data(dele)=[];
            end
            finishdatacell{1,k}=data;
        end
        if i==18
            for j=1:21
                data(dele)=[];
            end
            finishdatacell{2,k}=data;
        end
    end
end