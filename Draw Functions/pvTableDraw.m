function pvTableDraw(x,y,modW,modH,rows,cols)
modX = x;

for i = 1:cols
    modY = y;
    for j = 1:rows
        rectangle('Position',[modX modY modW modH])
        modY = modY + modH;
    end
    modX = modX + modW;
end