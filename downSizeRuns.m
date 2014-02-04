function [trunkInfo]=downSizeRuns(lvector,maxVD,cbStrings,minIndex,maxAWG,leftoverWireSize,cb2invRes,wirePrice)

lvector=sort(lvector(:)','ascend');
% lvector=lvector(:)';
global modPV inv

for i=length(lvector):-1:1
    trunkInfo(i,1)=lvector(i); % Length
    if (i==1 && minIndex==1) % If the last combiner box is not full
        minIndex = leftoverWireSize;
    end
    for j= minIndex:maxAWG
        [~,VDj] = voltDrop(trunkInfo(i,1),cb2invRes(j),modPV.Imp*cbStrings,modPV.Vmpmax); % Volt drop% check
        if (VDj > maxVD) % if the voltage drop is higher than the max continue loop
            continue
        elseif(VDj <= maxVD)
            trunkInfo(i,2)=j;   % Wire Size index
            trunkInfo(i,3)=VDj; % Voltage Drop
            trunkInfo(i,4)=trunkInfo(i,1)*2*2*(inv.num_inverters/4); % total length of conductors
            %indexLength(1,j)=indexLength(1,j)+leng.wire.cb2inv(i);
            trunkInfo(i,5)=minIndex; % Minimum wire size index
            trunkInfo(i,6)=cb2invRes(j); %length per 1000 ft
            trunkInfo(i,7)=cb2invRes(j)*2*trunkInfo(i,1)/1000; % resistance of run
            trunkInfo(i,8)=trunkInfo(i,4)*(wirePrice(j))/1000*2; %Cost        
            break
        end
    end
end