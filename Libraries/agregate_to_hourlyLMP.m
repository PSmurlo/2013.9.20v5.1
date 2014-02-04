pnodeID= 11855104;
filename=cellstr(['201201-rt';'201202-rt';'201203-rt';'201204-rt';'201205-rt';'201206-rt';'201207-rt';'201208-rt';'201209-rt';'201210-rt';'201211-rt';'201212-rt']);
for i=1:12
    data=csvread(filename{i});
    delete=(data(2,:)~=pnodeID);
    data(:,delete)=[];
end