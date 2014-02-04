function [mod_wire_price,CT_width,total_weight]=per_foot2total(price,num_runs,runs_mod,num_CB,OD,weight)

if nargin > 4
    total_length=runs_length*runs_mod*2*num_CB;
    mod_wire_price=total_length*price;
    CT_width=OD*num_runs;
    total_weight=weight*total_length;
    
else
    total_length=runs_length*runs_mod*2*num_CB; 
    mod_wire_price=total_length*price;
end

