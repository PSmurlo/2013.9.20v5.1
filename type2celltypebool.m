function [outtype]=type2celltypebool(type)

if(strcmp(type,'Mono-Si'))
    outtype=1;
elseif(strcmp(type,'Poly-Si'))
    outtype=0;
else
    outtype=3;
    disp('Invalid Cell Type');
end
