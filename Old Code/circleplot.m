function circleplot(xc, yc, r) 
t = 0 : .1 : 2*pi; 
x = r * cos(t) + xc; 
y = r * sin(t) + yc; 
plot(x, y)