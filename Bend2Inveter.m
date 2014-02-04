function [cb2inv,longestcb2inv1way] = Bend2Inveter(hW,totW,CBW,numtrunks,cb2bend) 
bend2inv=abs((-hW/2+(CBW/2)):CBW:(hW/2-(CBW/2)))*totW;
if CBW==hW
    bend2inv=0;
end
cb2inv=((ones(numtrunks,1)*cb2bend)+bend2inv'*ones(1,length(cb2bend)));
longestcb2inv1way=max(max(cb2inv));
