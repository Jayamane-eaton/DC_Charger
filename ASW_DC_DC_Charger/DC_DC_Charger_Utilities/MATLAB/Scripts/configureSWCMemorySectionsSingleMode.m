function configureSWCMemorySectionsSingleMode
%This function is used to configure the SWAddrMethods for model Runnables,Calibrations
%and Variables for single SWC

deleteLogErrorFile();
scriptFolder = fileparts(which('configureSWCMemorySections.m'));
cd(scriptFolder); % change directory to scripts folder


% individual mode execution
[arxmlFile,arxmlfilePath] = uigetfile('*.arxml','Select arxml file'); % select arxml file
if isfile(fullfile(arxmlfilePath,arxmlFile))
    [Path,Filename,FileExt] = fileparts(fullfile(arxmlfilePath,arxmlFile));
    if strcmp(FileExt,'.arxml')
        if ~isempty(which([Filename,'.slx']))
            disp(['### Processing file: ',Filename]);
            addTextToFile(['### Processing file: ',Filename]);
            modelName = updateSwCFromARXML(fullfile(arxmlfilePath,arxmlFile),...
                which([Filename,'.slx']));
            
            configureSWCMemorySections(modelName);
            %%Save Model
            save_system(modelName);
            close_system(modelName);
            
        end
    end
end


disp('Check Log Error file:');
disp([scriptFolder,'\SwAddrMethod_ErrorLog.txt']);

    function modelName = updateSwCFromARXML(arxmlFile,slModel)
        try
            load_system(slModel);
            [~,modelName,~] = fileparts(slModel);
            try
                obj = arxml.importer(arxmlFile);
                obj.updateModel(slModel, 'LaunchReport', 'Off');
            catch ME
            end
            
            if isfile([modelName '_backup.slx'])
                delete([modelName '_backup.slx']);
            end
            
            swcDataDictionaryObj = Simulink.data.dictionary.open([modelName '.sldd']);
            saveChanges(swcDataDictionaryObj);
            hide(swcDataDictionaryObj);
            close(swcDataDictionaryObj);
        catch ME
        end
        shortenPortNames
        updateBlockName
    end

    function addTextToFile(text)
        scriptFolder = fileparts(which('configureSWCMemorySections.m'));
        fid=fopen([scriptFolder,'\SwAddrMethod_ErrorLog.txt'],'a');
        Msg_Text = split(text,newline);
        for ii=1:length(Msg_Text)
            if isempty(Msg_Text{ii})
            else
                fprintf(fid,[Msg_Text{ii},'\n']);
            end
        end
        fclose(fid);
    end

    function deleteLogErrorFile()
        scriptFolder = fileparts(which('configureSWCMemorySections.m'));
        if exist([scriptFolder,'\SwAddrMethod_ErrorLog.txt'])
            delete([scriptFolder,'\SwAddrMethod_ErrorLog.txt']);
        end
    end
end