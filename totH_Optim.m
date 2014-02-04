function [bestangle,besttotH]=totH_Optim(data,qH,qW,tilt,totH,plotResults)
% Initalize max cost to zero for loop
global modPV eleDim modality
maxcost=0;
% % Preallocate result vectors for speed
tilt_array(1:totH(end)-totH(1)+1)=1;
totH_array(1:totH(end)-totH(1)+1)=1;
cost_array(1:totH(end)-totH(1)+1)=1;

% tilt_array=ones(length(totH),1)*tilt;
% totH_array=ones(length(tilt),1)*totH;
% totH_array=totH_array';
% Loop through tilt angles
for i= tilt
    % Set tilt to current angle
    ssccall('data_set_number', data, 'subarray1_tilt', i);
    index=1;
    % Loop through in row spacing values
    for j= totH
        % Set inter-row spacing to current value of loop
        ssccall('data_set_number', data, 'self_shading_rowspace', j);
        area=(eleDim.totW*qW*2)*(qH*2*j);
        % Create the pvsamv1 module
        % Self_Shading
        ssccall('data_set_number', data, 'self_shading_enabled', 1);
        ssccall('data_set_number', data, 'self_shading_length', modPV.module_length);
        ssccall('data_set_number', data, 'self_shading_width', modPV.module_width);
        ssccall('data_set_number', data, 'self_shading_mod_orient', modality);
        ssccall('data_set_number', data, 'self_shading_str_orient', eleDim.string_orientation);
        ssccall('data_set_number', data, 'self_shading_cellx', modPV.ncellx);
        ssccall('data_set_number', data, 'self_shading_celly', modPV.ncelly);
        ssccall('data_set_number', data, 'self_shading_ndiode', modPV.ndiode);
        ssccall('data_set_number', data, 'self_shading_nmodx', modPV.mps);
        ssccall('data_set_number', data, 'self_shading_nstrx', eleDim.nstrx*qW*2);
        ssccall('data_set_number', data, 'self_shading_nmody', eleDim.nmody);
        ssccall('data_set_number', data, 'self_shading_nrows', qH*2);
        
        module = ssccall('module_create', 'pvsamv1');
        % Run the module
        ssccall('module_exec', module, data);
        % Get annual ac output
        yearly_ac_net=ssccall('data_get_number', data, 'annual_ac_net');
        
        % Calculate gain and loss
        gain=yearly_ac_net*.13*25;
        loss=(area*0.000247105*30000);
        cost=gain-loss;
        
        % Update values for 3D plot
        tilt_array(index)=i;
        totH_array(index)=j;
        cost_array(index)=cost;
        index=index+1;
        
        % If the cost is greater than maxcost, set new best angle and totH
        if cost>maxcost
            maxcost=cost;
            bestangle=i;
            besttotH=j;
        end
    end
    if plotResults==1
        % Plot results
        plot(totH_array,cost_array);
        hold all
        xlabel('Inter-Row Shading (m)');
        ylabel('25 Year Output - Land Cost ($)');
        title('Tilt and Spacing Effect on System Price Performance');
        grid;
        % Display legend for the plot
        legend('Tilt 25', 'Tilt 26', 'Tilt 27', 'Tilt 28', 'Tilt 29', 'Tilt 30',...
            'Tilt 31', 'Tilt 32', 'Tilt 33', 'Tilt 34', 'Tilt 35');
        
        % Display the optimal in row spacing and angle
        X=['Optimal Angle: ',num2str(bestangle), ' degrees'];
        Y=['Optimal Spacing: ',num2str(besttotH), ' m'];
        disp(X);
        disp(Y);
    end
    
end