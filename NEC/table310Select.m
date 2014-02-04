function [table,tTa]= table310Select(tableIdentity)
%Table 310 Select Selects an NEC table by string input and returns the
%specified ambient temperature and table contained in the NEC.
%   [table,tTa]= table310Select(tableIdentity)
%
%   tableIdentity is the name of the table in the NEC sectopm 310 which is being
%   referenced for ampacity information. There is room for more to be
%   added, but as of now only two are used.
%
%   tTa is the ambient temperature found in the NEC which is used in conjunction with a
%   corresponding table for temperature derate see 'help
%   temperatureDerateFormula' or 'temperatureDeratechart' for more help.
%   
%   table is a matrix of the NEC table. the rows correspond to the table as
%   follows:
%   
%   'Cu' 75C
%   'Cu' 90C
%   'Al' 75C
%   'Al' 90C
%
%   See also VDresults, table310Select, getIndex, completeDerate, tempDerate.
%
%   Authors: Jonathan Topham, Neal Margraf, Scott Hummel
%   $Revision: 3.0 $  $Date: 2013/08/25 19:45:00 $
%
%   NEC related function.

switch(tableIdentity)%75C and 90C ONLY
    case '15b20'
%        
%         %Ampacities of not more than 3 single insulated conductors, rated up to and
%         %including 2000 volts, supported on a messenger, based on ambient air
%         %temperature 40C.
%         
%         table= [0 0 0 0 0 57 76 101 118 135 158 183 212 245 287 320 359 397 430 496 553 610 638 660 704 748 0 0 0 0;
%             0 0 0 0 0 66 89 117 138 158 185 214 247 287 335 374 419 464 503 580 647 714 747 773 826 879 0 0 0 0;
%             0 0 0 0 0 44 59 78 92 106 123 143 165 192 224 251 282 312 339 392 440 488 512 532 572 612 0 0 0 0;
%             0 0 0 0 0 51 69 91 107 123 144 167 193 224 262 292 328 364 395 458 514 570 598 622 669 716 0 0 0 0];
%         tTa = 40; %Table Temperature Ambient
    case '15b17'
        %Use this table for spot to trunk runs
        %Allowable Ampacities of Single-Insulated Conductors rated up to
        %2000v in free air based on ambient temperature 30C.
        table= [
            0 0 25 30 40 60 80 105 120 140 165 195 225 260 300 340 375 420 455 515 575 630 655 680 730 780 890 980 1070 1155;
            0 0 30 35 50 70 95 125 145 170 195 230 265 310 360 405 445 505 545 620 690 755 787 815 870 935 1065 1175 1280 1385;
            0 24 35 40 55 80 105 140 165 190 220 260 300 350 405 455 500 570 615 700 780 850 885 920 980 1055 1200 1325 1445 1560; % first value is actually 18 but wont work without 0
            0 0 0 25 35 45 60 80 95 110 130 150 175 200 235 265 280 330 355 405 455 500 515 535 580 625 710 795 875 960;
            0 0 0 30 40 55 75 100 115 135 155 180 210 240 280 315 350 395 425 485 545 595 620 645 700 750 855 950 1050 1150;
            0 0 0 35 45 60 85 115 130 150 175 205 235 270 315 355 395 445 480 545 615 670 700 725 790 845 965 1070 1185 1295];
        tTa = 30; %Table Temperature Ambient
    case '15b30'
    case 'moreMayBeAdded'
end