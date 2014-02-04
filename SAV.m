function [output,q] = SAV(q)

x = q(1);
y = q(2);
z = q(3);

[totalCNTCost,VDmax,t2iVDP,s2tVDP,totalWire,numTables,totW,totH,qW,qH, ... 
          totalCost,totalCableTrayCost,totalWireCost,wireInstallCost,...
          installCostSpots,wireIndex,totalWireS2T,totalWireS2S,...
          totalWireT2I,totalWireS2TCost,totalWireS2SCost,totalWireT2ICost...
          installCostWireIndex,installCost10awg] ...
          = pvAlenconFunction([x,y,z]);

disp(horzcat('Quadrants are ',num2str(qW),' tables wide and ',num2str(qH),' tables tall.'));
disp(horzcat('There are ',num2str(numTables),' tables and ',num2str(numTables),' SPOTs.'));
disp(horzcat(num2str(totalWire),' meters of conductor would cost $',num2str(totalWireCost)));
disp(horzcat(num2str(totalWireS2S),' meters of conductor for the strings to the SPOTs costs $',num2str(totalWireS2SCost),' (',wiresize(5),')'));
disp(horzcat(num2str(totalWireS2T),' meters of conductor for the SPOTs to the trunk costs $',num2str(totalWireS2TCost),' (',wiresize(wireIndex),')'));
disp(horzcat(num2str(totalWireT2I),' meters of conductor for the trunk to the inverter costs $',num2str(totalWireT2ICost),' (',wiresize(wireIndex),')'));
disp(horzcat('The cost of the cable tray is $',num2str(totalCableTrayCost)));
disp(horzcat('The cost of the cable tray combined with the conductor is $',num2str(totalCNTCost)));
disp(horzcat('The cost of labor for the ',wiresize(wireIndex),' is $',num2str(installCostWireIndex)));
disp(horzcat('The cost of labor for the 10 awg is $',num2str(installCost10awg)));
disp(horzcat('The cost of labor for SPOT installation is $',num2str(installCostSpots)));
disp(horzcat('Maximum voltage drop is ',num2str(VDmax)));
disp(horzcat('The total cost, including cable tray, SPOTs, and labor, is $',num2str(totalCost)));

labellist = {'Number of Tables Total';'Tables Per Quadrant';...
             'Quadrant Height (tables)';'Quadrant Width (tables)'; ...
             'Maximum Volt Drop Percent';'Cost of Cable Tray + Conductor';...
             'Total Length of Conductor';'Cost of Conductor';...
             'Cost of Cable Tray';'Total Cost including Tray and Spots';...
             'Wire Index'};
         
numbers = {numTables; numTables/4; qH; qW; VDmax; totalCNTCost; totalWire;...
          totalWireCost; totalCableTrayCost; totalCost; wireIndex};
      
output = horzcat(labellist,numbers);

figure;
pvFarmDraw(0,0,totW,totH,qH,qW,1.996,0.994,4,19,0);