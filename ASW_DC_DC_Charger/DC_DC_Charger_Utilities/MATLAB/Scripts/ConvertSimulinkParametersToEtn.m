utilsFolder = fileparts(which(mfilename));
temp = strsplit(utilsFolder,filesep);
dirData = dir([strjoin(temp(1:end-3),filesep),'\MBD\**/*.sldd']);

for jj = 1:length(dirData)
    disp(['Updating data dictionary #' num2str(jj) ' of ' num2str(length(dirData)) ' - ' dirData(jj).name]);
    ddName = dirData(jj).name;
    dicObj = Simulink.data.dictionary.open(ddName);
    secObj = getSection(dicObj,'Design Data');
    foundEntries = find(secObj,'-value','-class','Simulink.Parameter');
    
    for ii = 1:length(foundEntries)
        if strcmp(foundEntries(ii).DataSource,ddName)
            oldVal = getValue(foundEntries(ii));
            if strcmp(oldVal.CoderInfo.CustomStorageClass,'ConstVolatile')
                newVal = Eaton.Parameter;
                
                newVal.DataType = oldVal.DataType;
                description = oldVal.Description;
                description(double(description) < 32) = ''; % Clear ASCII characters that are not letters, numbers or symbols
                newVal.Description = description;
                newVal.Min = oldVal.Min;
                newVal.Max = oldVal.Max;
                newVal.Unit = oldVal.Unit;
                newVal.Value = oldVal.Value;
                newVal.CoderInfo.StorageClass = 'Custom';
                newVal.CoderInfo.CustomStorageClass = 'ConstVolatileCal';
                
                entry = getEntry(secObj,foundEntries(ii).Name);
                setValue(entry,newVal);
            end
        end
    end
    
    saveChanges(dicObj);
end
