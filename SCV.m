function SCV(q)

x = q(1);
y = q(2);
z = q(3);
load('sizes.mat')

[totalCNTCost,vd,conductor,costs,misc] = newPvConvFunction([x,y,z]);

conductor.size

disp(horzcat('Quadrants are ',num2str(misc.quad.width),' tables wide and ',num2str(misc.quad.height),' tables tall.'));
disp(horzcat('There are ',num2str(misc.table.number),' tables and ', ... 
              num2str(misc.cb),' combiner boxes with ',num2str(misc.cbstrings),' strings each.'));
disp(horzcat('The cost of the combiner boxes is $',num2str(costs.cb)));
disp(horzcat(num2str(conductor.wire.total),' meters of conductor would cost $',num2str(costs.wire.total)));
disp(horzcat(num2str(conductor.wire.ns),' meters of conductor for the combiner boxes to the trunks costs $',num2str(costs.wire.ns),' (',sizes(conductor.size),' Al)'));
disp(horzcat(num2str(conductor.wire.we),' meters of conductor for the strings to the combiner boxes costs $',num2str(costs.wire.we),' (',sizes(5),')'));
disp(horzcat('The cost of labor for the ',sizes(conductor.size),' Al conductor is $ ',num2str(costs.labor.ns)));
disp(horzcat('The cost of labor for the 10 awg Cu strings is $',num2str(costs.labor.we)));
disp(horzcat('The cost of labor for the installation of combiner boxes is $',num2str(costs.labor.cb)));
disp(horzcat('The cost of conductor plus the appropriate cable tray is $',num2str(totalCNTCost)));
disp(horzcat('The total cost of the cable tray is $',num2str(costs.tray.total)));
disp(horzcat('The total cost of labor to install the conductor, cable tray, and combiner boxes is $',num2str(costs.labor.total)));
disp(horzcat('Maximum voltage drop is ',num2str(vd.max)));
disp(horzcat('The total cost, including combiner boxes and labor costs, is $',num2str(costs.total)));

figure;
pvFarmDraw(0,0,misc.table.width,misc.table.height,misc.quad.height,misc.quad.width,1.996,0.994,4,19,misc.cb);