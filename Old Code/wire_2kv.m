function [Insulation,OD,weight,price] =wire_2kv(type)
%Copper PV Wire Shoals
Cu_wire_2kv=[   0,0,    0.075,  0.07,   0.075,  0.085,  0.085,  0.085,  0,  0.085,  0.105,  0.105,  0.105,  .105,   .105,   .12,    .12,    .12,    .12,    .12,    .135,   0,  .135,   0,  0,  .135,   0,0,0,0;%Insulation Thickness (inches)
                0,0,    0.220,  0.237,  0.261,  0.312,  .349,   .396,   0,  0.456,  .531,   .57,    0.614,  .664,   0.72,   .801,   .854,   .904,   .949,   1.033,  1.139,  0,  1.241,  0,  0,  1.39,   0,0,0,0;%Nominal Outside Diameter (inches)
                0,0,    31.9,   41.3,   56.6,   85.7,   121,    176,    0,  261,    338,    413,    506,    623,    769,    880,    1042,   1205,   1375,   1700,   2032,   0,  2515,   0,  0,  3335,   0,0,0,0;%lbs/10000ft
                0,0,    542,    602,    315,    785,    1005,   1553,   0,  2230,   2902,   3515,   4276,   5637,   4000,   0,      0,      0,      0,      0,      0,      0,  0,      0,  0,  0,      0,0,0,0];%$/1000ft #10 quote from CivicSolar

%Aluminumprice= Cu_wire_2kv(4,:)*3.28084/1000; %$/m; PV Wire Southwire

Al_wire_2kv=[   0,0,0,0,0,0,  0.085,  0.085,  0,  0.085,  0,  0.105,  0.105,  0.105,  0.105,  0.120, 0,  0.120,   0,  0.120, 0,0,  0.135, 0,0,  0.135, 0,0,0,0;%insulation thickness (inches)
                0,0,0,0,0,0,  0.339,  0.383,  0,  0.438,  0,  .546,   .586,   .633,   .685,   .76,   0, .856,     0,  .976,  0,0,  1.178, 0,0,  1.33,  0,0,0,0;%nominal outside diameter (inches)
                0,0,0,0,0,0,  55,     75,     0,  104,    0,  164,    196,    235,    284,    342,   0, 452,      0,  614,   0,0,  902,   0,0,  1166,  0,0,0,0;%weight lbs/1000ft
                0,0,0,0,0,0,  333,    458,    0,  643,    0,  1004,   1195,   1440,   1737,   2115,  0, 3560,     0,  4206,  0,0,  5830,  0,0,  8154,  0,0,0,0];%$/1000ft %first 8 estimated

if(strcmp('Cu',type)==1)
    wire=Cu_wire_2kv;
elseif(strcmp('Al',type)==1)
    wire=Al_wire_2kv;
end
%split properties

Insulation= wire(1,:)*0.0254; %m
OD= wire(2,:)*0.0254; %m
weight= wire(3,:)*(.45352)*(3.28084)*(1000);%kgs/m
price= wire(4,:)*1000*3.28084; %$/m;



%march 1st copper prices (and #10 quote from CivicSolar)
% 
% Cu_price=3.46;%$/lb
% Cu_price=Cu_price*(1/453.592);%$/g
% Cu_density=8.96*1000000; %g/m^3 %source: wikipedia % @ room temperature
% dollar_per_volume_copper=Cu_price*Cu_density;
% 
% Cu_diameter=(Cu_wire_2kv(2,:)-Cu_wire_2kv(1,:))/39.3701; %m
% Cu_area=((Cu_diameter/2).^2)*pi; %m^2 (or volume per meter)
% 
% price_copper=dollar_per_volume_copper*Cu_area; %$/m
% price_wire= Cu_wire_2kv(4,:).*(1/(3.28084)).*(1/1000); %$/m
% wire_markup=price_wire-price_copper;
% markup=wire_markup./price_copper;
% price_estimated_Cu=price_copper* %__ is average markup
% price_estimated_Cu_std=price_estimated_Cu*1000*3.28084;
% 
% %march 1st Aluminum prices
% 
% Al_price=.87;%$/lb
% Al_price=Al_price*(1/453.592);%$/g
% Al_density=2.70*1000000; %g/m^3 %source: wikipedia % @ room temperature
% dollar_per_volume_Aluminum=Al_price*Al_density;
% 
% Al_diameter=(Al_wire_2kv(2,:)-Al_wire_2kv(1,:))./39.3701; %m
% Al_area=((Al_diameter/2).^2)*pi; %m^2 (or volume per meter)
% 
% price_Al=dollar_per_volume_Aluminum*Al_area; %$/m
% price_wire= Al_wire_2kv(4,:).*(1/(3.28084)).*(1/1000); %$/m
% wire_markup_al=price_wire-price_Al;
% markup=wire_markup_al./price_Al;
% price_estimated_Al=price_Al*.6 %6 is average markup %in meters
% price_estimated_Al_std=price_estimated_Al*1000*3.28084





