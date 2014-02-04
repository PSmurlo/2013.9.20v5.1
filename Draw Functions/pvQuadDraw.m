function pvQuadDraw(x,y,tableW,tableH,quadRows,quadCols,cbSide)

tableX = x;

for i = 1:quadCols
    tableY = y;
    for j = 1:quadRows
%         pvTableDraw(tableX,tableY,modW,modH,tableRows,tableCols)
        tableY = tableY + tableH;
    end
    tableX = tableX + tableW;
    if i ~= quadCols && mod(i,2) == 1
        rectangle('Position',[tableX y 0.001 quadRows*tableH-tableH],'EdgeColor','red','LineWidth',2)
    end
end

if quadCols == 1
    stepValue = 6;
elseif quadCols == 2
    stepValue = 3;
elseif quadCols == 3
    stepValue = 2;
else
    stepValue = 1;
end

cbH = y + 1;

if cbSide == 1
    for i = 1:stepValue:quadRows
        rectangle('Position',[(x-6) (cbH) 2 2],'EdgeColor','red')
        cbH = cbH + tableH*stepValue;
    end
end

axis equal