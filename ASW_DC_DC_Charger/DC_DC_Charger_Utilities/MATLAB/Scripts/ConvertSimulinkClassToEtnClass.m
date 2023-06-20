% This function will convert Simulink Signals to Eaton Signals in the SWC sldd
function updatedData = ConvertSimulinkClassToEtnClass(modelName,data)
    updatedData = data;
    disp(['Updating Simulink signals and parameters to Eaton class #' 'of ' ' - ' modelName]);
    f=fieldnames(updatedData);
    for k=1:size(f,1)
        temp1 = updatedData.(f{k});
        if strcmp(class(temp1),'Simulink.Signal') || strcmp(class(temp1),'AUTOSAR4.Signal')
            % convert to Eaton.Signal
            updatedData.(f{k}) = Eaton.Signal;
            description = temp1.Description;
            description(double(description) < 32) = ''; % Clear ASCII characters that are not letters, numbers or symbols
            updatedData.(f{k}).Description = description;
            updatedData.(f{k}).DataType = temp1.DataType;
            updatedData.(f{k}).Min = temp1.Min ;
            updatedData.(f{k}).Max = temp1.Max;
            updatedData.(f{k}).InitialValue = temp1.InitialValue;
            updatedData.(f{k}).Unit = temp1.Unit;
            updatedData.(f{k}).StorageClass = 'Auto';
            
        end
        
         if strcmp(class(temp1),'Simulink.Parameter') 
            % convert to Eaton.Parameter
            updatedData.(f{k}) = Eaton.Parameter;
            description = temp1.Description;
            description(double(description) < 32) = ''; % Clear ASCII characters that are not letters, numbers or symbols
            updatedData.(f{k}).Description = description;
            updatedData.(f{k}).DataType = temp1.DataType;
            updatedData.(f{k}).Min = temp1.Min ;
            updatedData.(f{k}).Max = temp1.Max;
            updatedData.(f{k}).Unit = temp1.Unit;
            updatedData.(f{k}).Value = temp1.Value;
            updatedData.(f{k}).CoderInfo.StorageClass = 'Custom';
            updatedData.(f{k}).CoderInfo.CustomStorageClass = 'ConstVolatileCal';
            
        end
    end
end

