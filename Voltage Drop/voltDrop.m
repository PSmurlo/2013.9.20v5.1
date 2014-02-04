function [VD,VD_percent]= voltDrop(length,resistance,Imp,Vmp)
%VOLTAGE DROP This function computes the voltage drop as well as the
%percent voltage drop percent based on the input parameters relating to the wire
%as well as the current and voltage the wire is being used for.
%   [VD,VD_percent]= voltDrop(length,resistance,Imp,Vmp)
%   the input parameter of length describes the *one way* length of the
%   conductor. The resistance is the resistance in *ohms/km* for the
%   conductor size being used. Imp and Vmp are the nominal voltage and
%   current for average operating conditions.
%
%   To be added: future nargin for 3-phase and possibly power factor input
%   parameters
%
%   See also spotVoltDrop.
%
%   Authors: Jonathan Topham, Neal Margraf, Scott Hummel
%   $Revision: 3.0 $  $Date: 2013/08/25 19:45:00 $
%
%   Photovoltaic related function.

VD= ((length*Imp).*resistance) / 1000; %OHMS/KM TO OHMS/M
VD_percent= (VD./Vmp)*100;
%takes the resistance, current at max power, 
% threephase*.866 %assuming 100 percent pf