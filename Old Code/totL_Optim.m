function [bestangle,besttotL]=totL_Optim(data,final,tilt,totL,plotResults)
% Initalize max cost to zero for loop
maxcost=0;
% Preallocate result vectors for speed
tilt_array(1:totL(end)-totL(1)+1)=0;
totL_array(1:totL(end)-totL(1)+1)=0;
cost_array(1:totL(end)-totL(1)+1)=0;

% Loop through tilt angles
for i= tilt
    % Set tilt to current angle
    ssccall('data_set_number', data, 'subarray1_tilt', i);
    index=1;
    % Loop through in row spacing values
    for j= totL
        % Set inter-row spacing to current value of loop
        ssccall('data_set_number', data, 'self_shading_rowspace', j);
        area=(totW*final.qW*2)*(final.qH*2*j);
        % Create the pvsamv1 module
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
        totL_array(index)=j;
        cost_array(index)=cost;
        index=index+1;
        
        % If the cost is greater than maxcost, set new best angle and totL
        if cost>maxcost
            maxcost=cost;
            bestangle=i;
            besttotL=j;
        end
    end
    if plotResults==1
        % Plot results
        plot(totL_array,cost_array);
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
        Y=['Optimal Spacing: ',num2str(besttotL), ' m'];
        disp(X);
        disp(Y);
    end
    
end