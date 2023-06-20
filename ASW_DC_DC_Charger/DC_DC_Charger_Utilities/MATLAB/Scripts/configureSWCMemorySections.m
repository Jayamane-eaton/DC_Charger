function configureSWCMemorySections(modelName)
    try
        VarMemSec = {};
        CalibMemSec = {};
        CodeMemSec = {};
        disp('### Configuring memory section###');
        %Open Data Dictionary
        myDictionaryObj = Simulink.data.dictionary.open([modelName,'.sldd']);
        %Remove referenced DataDictionary
        myDictionaryObj.removeDataSource('AutosarSwcDataTypes.sldd');
        %Read Desig Data section
        dDataSectObj = getSection(myDictionaryObj,'Design Data');
        %Export DataDictionary to file
        exportToFile(dDataSectObj,'myDictionaryConfigurations.mat');
        data=load('myDictionaryConfigurations.mat');
        %Restore referenced DataDictionary
        myDictionaryObj.discardChanges;
        %read simulink mapping
        slMap = autosar.api.getSimulinkMapping(modelName);
        %Find Swc Address Methods
        arProps = autosar.api.getAUTOSARProperties(modelName);
        arRunn = find(arProps,[],'Runnable');
        arSwAddrMthds = find(arProps,[],'SwAddrMethod');

        [VarMemSec,CalibMemSec,CodeMemSec] = getMemorySections(arSwAddrMthds);

        if isempty(VarMemSec) || isempty(CalibMemSec) || isempty(CodeMemSec)
            disp('###ERROR### Check log error file for more details.');
            addTextToFile(strcat('###ERROR### At least one of the Memory Sections (CODE,CALIB or VAR) is not defined for model: ',modelName));
            %Close model discarding the changes
            bdclose(modelName);
        else
            % change the configuration to correct code gen configuration
            % per ASIL partition
            setModelActiveConfig(modelName,CalibMemSec);

            % change Simulink Signals to Eaton Signals
            %ConvertSimulinkClassToEtnClass(modelName);
            data = ConvertSimulinkClassToEtnClass(modelName,data);

            mdlWks = get_param(modelName,'ModelWorkspace');
            mdlWksData = mdlWks.whos;

            % Move parameters back to data dictionary if they are stored in model workspace
            if ~isempty(mdlWksData)
                save(mdlWks,'mdlWksDataParam.mat');
                count = 0;
                for jj = 1:length(mdlWksData)
                    if ~contains(mdlWksData(jj).name,'PIM') && ~contains(mdlWksData(jj).name,'IV_')
                        count = count+1;
                        NewmdlWksData(count) = mdlWksData(jj);
                    end
                end% end for loop
                % function to save model workspace variables in a mat file
                convertMdlToSldd('mdlWksDataParam');
                importFromFile(dDataSectObj,'MdlToSlddData.mat','existingVarsAction','overwrite');
                delete('mdlWksDataParam.mat');
                delete('MdlToSlddData.mat');
                %Save changes to DataDictionary
                myDictionaryObj.saveChanges;

                if exist('NewmdlWksData')
                    for kk=1:length(NewmdlWksData)
                        clear(mdlWks,NewmdlWksData(kk).name);
                    end
                end
                save_system(modelName);
            end

            % access data calibations and variables stored in data dictionary and change their storage class
            f=fieldnames(data);
            for k=1:size(f,1)
                temp1 = data.(f{k});
                calname = string(f{k});
                signalError = false;
                if strcmp(class(temp1),'Eaton.Parameter')
                    if strcmp(CalibMemSec,'CALIB_Core0ASILA')
                        data.(f{k}).StorageClass = 'Core0ConstVolatileASILA';
                    elseif strcmp(CalibMemSec,'CALIB_Core0ASILB')
                        data.(f{k}).StorageClass = 'Core0ConstVolatileASILB';
                    elseif strcmp(CalibMemSec,'CALIB_Core0ASILC')
                        data.(f{k}).StorageClass = 'Core0ConstVolatileASILC';
                    elseif strcmp(CalibMemSec,'CALIB_Core0QM')
                        data.(f{k}).StorageClass = 'Core0ConstVolatileQM';
                    elseif strcmp(CalibMemSec,'CALIB_Core1ASILA')
                        data.(f{k}).StorageClass = 'Core1ConstVolatileASILA';
                    end

                elseif  strcmp(class(temp1),'Eaton.Signal')
                    if strcmp(VarMemSec,'VAR_Core0ASILA')
                        data.(f{k}).StorageClass = 'VARCore0ASILA';  
                    elseif strcmp(VarMemSec,'VAR_Core0ASILB')
                        data.(f{k}).StorageClass = 'VARCore0ASILB';
                    elseif strcmp(VarMemSec,'VAR_Core0ASILC')
                        data.(f{k}).StorageClass = 'VARCore0ASILC';
                    elseif strcmp(VarMemSec,'VAR_Core0QM')
                        data.(f{k}).StorageClass = 'VARCore0QM';
                    elseif strcmp(VarMemSec,'VAR_Core1ASILA')
                        data.(f{k}).StorageClass = 'VARCore1ASILA';
                    end

                    modelVars = Simulink.findVars(modelName,'Name',calname);
                    if ~isempty(modelVars)
                        PortHandles = get_param(modelVars.Users,'PortHandles');
                        outportHandle = PortHandles{1}.Outport;
                        if (length(outportHandle) > 1)
                            lineInfo = get_param(outportHandle, 'Line');
                            for mm = 1:length(lineInfo)
                                nameInfo{mm} = get_param(lineInfo{mm},'name');
                            end% end for loop
                            IndexName = strcmp(nameInfo, modelVars.Name);
                            outportHandleFinal = outportHandle(IndexName);
                        else
                            outportHandleFinal = outportHandle;
                        end

                        try
                            arMappedTo = getSignal(slMap,outportHandleFinal);
                            if ~strcmp(arMappedTo,'Auto')
                                mapSignal(slMap,outportHandleFinal,'Auto');
                            end
                        catch ME
                            addTextToFile(strcat('####WARNING### There are no signals mapped to this object: ',calname));
                            signalError = true;
                        end 
                    end
                end % end if strcmp(class(temp1),'Eaton.Parameter')
            end % end for loop
            try
                if ~isempty(data)
                    save('updatedsldd.mat','-struct','data');
                    importedVars = importFromFile(dDataSectObj,'updatedsldd.mat','existingVarsAction','overwrite');
                    delete('updatedsldd.mat');
                end
            catch ME
                disp(ME.identifier)
            end
            %Save changes to DataDictionary
            myDictionaryObj.saveChanges;

            for ii = 1:length(arRunn)
                arRunnableName = get(arProps,arRunn{ii},'Name');
                % Map IEV Runnables
                if ~isempty(arRunnableName)
                    if endsWith(arRunnableName,'_IEV')
                        mapFunction(slMap,'InitializeFunction',arRunnableName,'SwAddrMethod',CodeMemSec);
                        % Map TEV Runnables
                    elseif endsWith(arRunnableName,'_TEV')
                        if length(arRunn)>2
                            %Multiple periodic Runnables
                            mapFunction(slMap,arRunnableName,arRunnableName,'SwAddrMethod',CodeMemSec);
                        else
                            %Single function call Runnables
                            mapFunction(slMap,'StepFunction',arRunnableName,'SwAddrMethod',CodeMemSec);
                        end
                        % Map OIE Runnables
                    elseif endsWith(arRunnableName,'_OIE')
                        if length(arRunn)>2
                            %Multiple periodic Runnables
                            mapFunction(slMap,arRunnableName,arRunnableName,'SwAddrMethod',CodeMemSec);
                        else
                            %Single function call Runnables
                            mapFunction(slMap,arRunnableName,arRunnableName,'SwAddrMethod',CodeMemSec);
                        end
                    end
                end
            end % end for loop
        end % end if empty Memory Sections
    catch ME
        %Restore Data Dictionary
        myDictionaryObj.discardChanges;
        %Close model discarding the changes
        bdclose(modelName);
        disp('###ERROR### Check log error file for more details.');
        addTextToFile(strcat('###ERROR### Following model could not be updated:',modelName,'\nMake sure there are no compilations errors'));
    end
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

function [VarMemSec,CalibMemSec,CodeMemSec]= getMemorySections(arSwAddrMthds)
    VarMemSec = {};
    CalibMemSec = {};
    CodeMemSec = {};
    if ~isempty(arSwAddrMthds)
        for ii=1:length(arSwAddrMthds)
            if startsWith(arSwAddrMthds{ii},'VAR')
                VarMemSec =  arSwAddrMthds{ii};
            elseif startsWith(arSwAddrMthds{ii},'CALIB')
                CalibMemSec =  arSwAddrMthds{ii};
            elseif startsWith(arSwAddrMthds{ii},'CODE')
                CodeMemSec =  arSwAddrMthds{ii};
            end
        end
    end
end

function setModelActiveConfig(modelName,CalibMemSec)
    % change the configuration to correct code gen configuration
    % per ASIL partition
    activeConfigObj = getActiveConfigSet(modelName);

    if strcmp(CalibMemSec,'CALIB_Core0ASILA')
        set_param(activeConfigObj,'SourceName','CodeGenConfig_Autosar_Core0ASILA')

    elseif strcmp(CalibMemSec,'CALIB_Core0ASILB')
        set_param(activeConfigObj,'SourceName','CodeGenConfig_Autosar_Core0ASILB')

    elseif strcmp(CalibMemSec,'CALIB_Core0ASILC')
        set_param(activeConfigObj,'SourceName','CodeGenConfig_Autosar_Core0ASILC')

    elseif strcmp(CalibMemSec,'CALIB_Core0QM')
        set_param(activeConfigObj,'SourceName','CodeGenConfig_Autosar')

    elseif strcmp(CalibMemSec,'CALIB_Core1ASILA')
        set_param(activeConfigObj,'SourceName','CodeGenConfig_Autosar_Core1ASILA')
    end
end