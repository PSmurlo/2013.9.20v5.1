function [eleDim]= rackDim()
% RACKDIM Gives the rack dimensions.
%   eleDim = rackDim() gives the output struct output for null input.

% element.string_orientation=wire_orientation; %Implement Later
global modality modPV

% gap=element.gap_spacing;
mod_l=modPV.module_length; %longer
mod_w=modPV.module_width;

% Input variables
if(modality==1)%Landscape
    nummodh= 4;
    nummodl= modPV.mps;
    element_height= nummodh*mod_w;%+(nummodh-1)*gap;
    element_width= nummodl*mod_l;%+(nummodl)*gap;
else%Portrait   
    nummodh= 2;
    nummodl= modPV.mps *2;
    element_height= nummodh*mod_l;%+(nummodh-1)*gap;
    element_width= nummodl*mod_w;%+(nummodl)*gap;  
end

%**Length**
%element_height*cosd(tilt)
eleDim.totW=element_width;
% eleDim.wireL=nummodh*(2*element_width+element_height+2*sind(tilt));
eleDim.modperTable=nummodh*nummodl;
eleDim.modality=modality;

% l=angled_length*rows;%finding length of array facing sun
% 
% %assuming northern hemisphere and sizing for winter solstice
% earth_angle= -23.5; %angle between earth axis and its orbit
% zenithAngle=latitude-earth_angle;
% noon_sa= 90-zenithAngle;%90 degrees -(where you are, where it is 90 degrees)
% 
% h=l*sind(tilt);%finding height of racking
% irs=h/(tand(noon_sa)); %finding length between racking
% rack_w= cosd(tilt)*l; %length of earth under racking
% tot_w=irs+rack_w; %total length
% 
% %**Width**
% tot_l=(paralell_length*MpS);%+(mod_spacing*(MpS-1))+table_spacing;