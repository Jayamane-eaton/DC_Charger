function [softwareComp] = loadSWCFromARXML(filePath)

thisArxml = ArxmlReader(filePath);
softwareComp = createSWC(thisArxml,strrep(thisArxml.arxmlName,'.arxml',''),thisArxml.SWCName);
disp(['%%%%%%%%%%%%%%%%%%%%%%%%% Validating SWC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
softwareComp.validate;

end

function [softwareComp] = createSWC(arxmlImport,path,name);

%% create SWC
softwareComp = SoftwareComponent(path,name);

%% create SW imp
softwareComp.SWImp = SWImp(path,arxmlImport.SWImp{1}.Name);
softwareComp.SWImp.progLanguage = arxmlImport.SWImp{1}.ProgLanguage;
softwareComp.SWImp.SWVersion = arxmlImport.SWImp{1}.SWVersion;

%% create ports
allPorts = [arxmlImport.RPorts;arxmlImport.PPorts];
for(ii = 1:length(allPorts))
    softwareComp.ports{ii} = createPortElement(arxmlImport,path,allPorts{ii}.Name);
end

%% create internal behavior
softwareComp.internalBehavior = InternalBehavior(path,arxmlImport.InternalBehavior{1}.Name);
softwareComp.internalBehavior.supportsMultipleInst = arxmlImport.InternalBehavior{1}.SupportsMultipleInst;

%% create data type mapping set
for(jj = 1:length(arxmlImport.InternalBehavior{1}.DTMSRefs))
    %find the data type mapping set
    for(ii = 1:length(arxmlImport.DataTypeMappingSets))
        %find the compumethod reference
        [dataTypeMappingSetPath,dataTypeMappingSetName] = extractObjectDetails(arxmlImport.InternalBehavior{1}.DTMSRefs{jj}.DataElementRef);
        if(strcmp(dataTypeMappingSetName,arxmlImport.DataTypeMappingSets{ii}.Name))
            thisDataTypeMappingSet = arxmlImport.DataTypeMappingSets{ii};
            break;
        end
    end
    
    %extract the details and create the data object
    softwareComp.internalBehavior.dataTypeMappingSets{jj} = DataTypeMappingSet(dataTypeMappingSetPath,thisDataTypeMappingSet.Name);
    softwareComp.internalBehavior.dataTypeMappingSets{jj}.appDataTypeRef = thisDataTypeMappingSet.AppDataRef;
    softwareComp.internalBehavior.dataTypeMappingSets{jj}.impDataTypeRef = thisDataTypeMappingSet.ImpDataRef;
        
end

%% create timing events
for(ii = 1:length(arxmlImport.InternalBehavior{1}.TimingEvents))
    softwareComp.internalBehavior.timingEvents{ii} = TimingEvent(path,arxmlImport.InternalBehavior{1}.TimingEvents{ii}.Name);
    softwareComp.internalBehavior.timingEvents{ii}.disabledModeRefs = arxmlImport.InternalBehavior{1}.TimingEvents{ii}.DisabledModeRefs;
    softwareComp.internalBehavior.timingEvents{ii}.period = arxmlImport.InternalBehavior{1}.TimingEvents{ii}.Period;
    
    %% assign runnable
    for(jj =1:length(arxmlImport.InternalBehavior{1}.TimingEvents{ii}.RunnableNames))
        [runnablePath,runnableName] = extractObjectDetails(arxmlImport.InternalBehavior{1}.TimingEvents{ii}.RunnableNames{jj});
        %TODO: this will break id there is multiple runnables
        
        for(kk = 1:length(arxmlImport.InternalBehavior{1}.Runnables))
            if(strcmp(arxmlImport.InternalBehavior{1}.Runnables{kk}.Name,runnableName))
                thisRunnable = arxmlImport.InternalBehavior{1}.Runnables{kk};
                break;
            end
        end
        
        
        softwareComp.internalBehavior.timingEvents{ii}.runnables{jj} = Runnable(path,thisRunnable.Name);
        softwareComp.internalBehavior.timingEvents{ii}.runnables{jj}.minStartInterval = thisRunnable.MinStartInterval;
        softwareComp.internalBehavior.timingEvents{ii}.runnables{jj}.canBeInvokedConcurrently = thisRunnable.CanBeInvokedConcurenly;
        
        %% assign ports to runnables
        for(kk = 1:length(thisRunnable.PortReadAccess))
            [portReadAccessPath,portReadAccessName] = extractObjectDetails(thisRunnable.PortReadAccess{kk}.PortRef);
            for(mm = 1:length(softwareComp.ports))
                   if(strcmp(softwareComp.ports{mm}.name,portReadAccessName))
                       softwareComp.internalBehavior.timingEvents{ii}.runnables{jj}.portReadAccess{kk} = softwareComp.ports{mm};
                   end
            end
        end

        for(kk = 1:length(thisRunnable.PortWriteAccess))
            [portWriteAccessPath,portWriteAccessName] = extractObjectDetails(thisRunnable.PortWriteAccess{kk}.PortRef);
            for(mm = 1:length(softwareComp.ports))
                   if(strcmp(softwareComp.ports{mm}.name,portWriteAccessName))
                       softwareComp.internalBehavior.timingEvents{ii}.runnables{jj}.portWriteAccess{kk} = softwareComp.ports{mm};
                   end
            end
        end
        
    end
   
end

%% create init events
for(ii = 1:length(arxmlImport.InternalBehavior{1}.InitEvents))
    softwareComp.internalBehavior.initEvents{ii} = InitEvent(path,arxmlImport.InternalBehavior{1}.InitEvents{ii}.Name);
    
    %% assign runnable
    for(jj =1:length(arxmlImport.InternalBehavior{1}.InitEvents{ii}.RunnableNames))
        [runnablePath,runnableName] = extractObjectDetails(arxmlImport.InternalBehavior{1}.InitEvents{ii}.RunnableNames{jj});
        %TODO: this will break id there is multiple runnables
        
        for(kk = 1:length(arxmlImport.InternalBehavior{1}.Runnables))
            if(strcmp(arxmlImport.InternalBehavior{1}.Runnables{kk}.Name,runnableName))
                thisRunnable = arxmlImport.InternalBehavior{1}.Runnables{kk};
                break;
            end
        end
        
        
        softwareComp.internalBehavior.initEvents{ii}.runnables{jj} = Runnable(path,thisRunnable.Name);
        softwareComp.internalBehavior.initEvents{ii}.runnables{jj}.minStartInterval = thisRunnable.MinStartInterval;
        softwareComp.internalBehavior.initEvents{ii}.runnables{jj}.canBeInvokedConcurrently = thisRunnable.CanBeInvokedConcurenly;
        
        %% assign ports to runnables
        for(kk = 1:length(thisRunnable.PortReadAccess))
            [portReadAccessPath,portReadAccessName] = extractObjectDetails(thisRunnable.PortReadAccess{kk}.PortRef);
            for(mm = 1:length(softwareComp.ports))
                   if(strcmp(softwareComp.ports{mm}.name,portReadAccessName))
                       softwareComp.internalBehavior.initEvents{ii}.runnables{jj}.portReadAccess{kk} = softwareComp.ports{mm};
                   end
            end
        end

        for(kk = 1:length(thisRunnable.PortWriteAccess))
            [portWriteAccessPath,portWriteAccessName] = extractObjectDetails(thisRunnable.PortWriteAccess{kk}.PortRef);
            for(mm = 1:length(softwareComp.ports))
                   if(strcmp(softwareComp.ports{mm}.name,portWriteAccessName))
                       softwareComp.internalBehavior.initEvents{ii}.runnables{jj}.portWriteAccess{kk} = softwareComp.ports{mm};
                   end
            end
        end
        
    end
   
end
        
end

function [portElement] = createPortElement(arxmlImport,path,name);

%% create port
thisPort = [];
    
%create app data type
for(ii = 1:length(arxmlImport.PPorts))
    %find data type refrence in arxml import data
    if(strcmp(arxmlImport.PPorts{ii}.Name,name))
        thisPort = arxmlImport.PPorts{ii};
        type = 'P';
        break;
    end
end

if(isempty(thisPort))
 %create app data type
    for(ii = 1:length(arxmlImport.RPorts))
        %find data type refrence in arxml import data
        if(strcmp(arxmlImport.RPorts{ii}.Name,name))
            thisPort = arxmlImport.RPorts{ii};
            type = 'R';
            break;
        end
    end
end

%create new object and assign data
portElement = Port(path,thisPort.Name);
portElement.type = type;

%% create interface
[interfacePath, interfaceName] = extractObjectDetails(thisPort.InterfaceRef);
%create app data type
for(ii = 1:length(arxmlImport.SRInterfaces))
   
    %find data type refrence in arxml import data
    if(strcmp(arxmlImport.SRInterfaces{ii}.Name,interfaceName))
        
        thisInterface = arxmlImport.SRInterfaces{ii};
        break;
        
    end
   
end

for(ii = 1:length(arxmlImport.CSInterfaces))
   
    %find data type refrence in arxml import data
    if(strcmp(arxmlImport.CSInterfaces{ii}.Name,interfaceName))
        
        thisInterface = arxmlImport.CSInterfaces{ii};
        break;
        
    end
   
end

for(ii = 1:length(arxmlImport.MSInterfaces))
   
    %find data type refrence in arxml import data
    if(strcmp(arxmlImport.MSInterfaces{ii}.Name,interfaceName))
        
        thisInterface = arxmlImport.MSInterfaces{ii};
        break;
        
    end
   
end

portElement.interface = Interface(interfacePath,thisInterface.Name);
portElement.interface.isService = thisInterface.isService;
portElement.interface.serviceKind = thisInterface.ServiceKind;

%% add interface data elements 

for(ii=1:length(thisInterface.Elements))
    
    thisElement = thisInterface.Elements{ii};
    
    portElement.interface.dataElements{ii} = InterfaceDataElement(interfacePath,thisElement.Name);
    portElement.interface.dataElements{ii}.calAccess = thisElement.CalAccess;
    portElement.interface.dataElements{ii}.SWImpPolicy = thisElement.SWImpPolicy;
    
    %% create app data type
    [appDataTypePath, appDataTypeName] = extractObjectDetails(thisElement.DataTypeRef);
    portElement.interface.dataElements{ii}.dataType = createAppDataType(arxmlImport,appDataTypePath,appDataTypeName);
    
    %% create initial value
    [intialValuePath, intialValueName] = extractObjectDetails(thisElement.InitValueRef);

    %find data constant
    for(jj = 1:length(arxmlImport.Constants))
        %find data type refrence in arxml import data
        if(strcmp(arxmlImport.Constants{jj}.Name,intialValueName))   
            thisConstant = arxmlImport.Constants{jj};
            break;
            
        end
    end
    
    portElement.interface.dataElements{ii}.initValue = DataConstant(intialValuePath,thisConstant.Name);
    portElement.interface.dataElements{ii}.initValue.category = thisConstant.Category;
    portElement.interface.dataElements{ii}.initValue.valuePhys = thisConstant.ValuePhys;
    
    %% assign the unit for init value
    
    if(~isempty(thisConstant.UnitRef))
        
        [unitPath, unitName] = extractObjectDetails(thisConstant.UnitRef);
        for(jj = 1:length(arxmlImport.Units))
            
            %find the compumethod reference
            if(strcmp(arxmlImport.Units{jj}.Name,unitName))
                thisUnit = arxmlImport.Units{jj};
                break;
            end
            
        end
        
        portElement.interface.dataElements{ii}.initValue.unit = Unit(unitPath,thisUnit.Name);
        portElement.interface.dataElements{ii}.initValue.unit.displayName = thisUnit.DisplayName;
        portElement.interface.dataElements{ii}.initValue.unit.factorToSI = thisUnit.FactorToSI;
        portElement.interface.dataElements{ii}.initValue.unit.offsetToSI = thisUnit.OffsetToSI;
        portElement.interface.dataElements{ii}.initValue.unit.physicalDimensionRef  = thisUnit.PhysicalDimRef;
    
    end
    
    %% assign the com spec
    if(strcmp(portElement.type,'P'))
        
        thisPort.ComSpecs{1};
        for(ii = 1:length(thisPort.ComSpecs))
            
            [dataElementPath, dataElementName] = extractObjectDetails(thisPort.ComSpecs{ii}.DataElementRef);
            if(strcmp(dataElementName,portElement.interface.dataElements{ii}.name))
                thisComSpec = thisPort.ComSpecs{ii};
            end
            
        end
%      '/Interfaces/SenderReceiverInterfaces/IF_InMgmtEMCurr_iStar1MchPhAMesPri/InMgmtEMCurr_iStar1MchPhAMesPri'
        portElement.interface.dataElements{ii}.comSpec = ComSpec(portElement.interface.dataElements{ii}.name);
        portElement.interface.dataElements{ii}.comSpec.handleOutOfRange = thisComSpec.HandleOutOfRange;
        portElement.interface.dataElements{ii}.comSpec.usesEndToEndProt = thisComSpec.UsesEndToEndProt;
        
        %% create initial value
        [intialValuePath, intialValueName] = extractObjectDetails(thisComSpec.InitalValueConstRef);
        
        %find data constant
        for(jj = 1:length(arxmlImport.Constants))
            %find data type refrence in arxml import data
            if(strcmp(arxmlImport.Constants{jj}.Name,intialValueName))
                thisConstant = arxmlImport.Constants{jj};
                break;
                
            end
        end
        
        portElement.interface.dataElements{ii}.comSpec.initValue = DataConstant(intialValuePath,thisConstant.Name);
        portElement.interface.dataElements{ii}.comSpec.initValue.category = thisConstant.Category;
        portElement.interface.dataElements{ii}.comSpec.initValue.valuePhys = thisConstant.ValuePhys;
        
        if(~isempty(thisConstant.UnitRef))
            
            [unitPath, unitName] = extractObjectDetails(thisConstant.UnitRef);
            for(jj = 1:length(arxmlImport.Units))
                
                %find the compumethod reference
                if(strcmp(arxmlImport.Units{jj}.Name,unitName))
                    thisUnit = arxmlImport.Units{jj};
                    break;
                end
                
            end
            
            portElement.interface.dataElements{ii}.comSpec.initValue.unit = Unit(unitPath,thisUnit.Name);
            portElement.interface.dataElements{ii}.comSpec.initValue.unit.displayName = thisUnit.DisplayName;
            portElement.interface.dataElements{ii}.comSpec.initValue.unit.factorToSI = thisUnit.FactorToSI;
            portElement.interface.dataElements{ii}.comSpec.initValue.unit.offsetToSI = thisUnit.OffsetToSI;
            portElement.interface.dataElements{ii}.comSpec.initValue.unit.physicalDimensionRef  = thisUnit.PhysicalDimRef;
            
        end
        
        
    end
end


end

function [appDataType] = createAppDataType(arxmlImport,path,name);
%create app data type
for(ii = 1:length(arxmlImport.AppDataTypes))
    
    thisAppDataType = [];
    
    %find data type refrence in arxml import data
    if(strcmp(arxmlImport.AppDataTypes{ii}.Name,name))
        
        thisAppDataType = arxmlImport.AppDataTypes{ii};
        break;
        
    end
end

%create new object and assign data
appDataType = AppDataType(path,thisAppDataType.Name);
appDataType.category = thisAppDataType.Catagory;
appDataType.description = thisAppDataType.Description;

%% create compu method
[CompuMethodPath, CompuMethodName] = extractObjectDetails(thisAppDataType.CompuMethod);

%create compu method
for(ii = 1:length(arxmlImport.CompuMethods))
    
    %find the compumethod reference
    if(strcmp(arxmlImport.CompuMethods{ii}.Name,CompuMethodName))
        thisCompuMethod = arxmlImport.CompuMethods{ii};
        break;
    end
    
end

appDataType.compuMethod = CompuMethod(CompuMethodPath,thisCompuMethod.Name);
appDataType.compuMethod.category = thisCompuMethod.Catagory;
appDataType.compuMethod.LSB = thisCompuMethod.Scale;

try
appDataType.compuMethod.offset = thisCompuMethod.Offset;
catch
    stop = 1;
end

%% create the unit for the compuMethod
[unitPath, unitName] = extractObjectDetails(thisCompuMethod.UnitRef);

%create compu method
for(ii = 1:length(arxmlImport.Units))
    
    %find the compumethod reference
    if(strcmp(arxmlImport.Units{ii}.Name,unitName))
        thisUnit = arxmlImport.Units{ii};
        break;
    end
    
end

appDataType.compuMethod.unit = Unit(unitPath,thisUnit.Name);
appDataType.compuMethod.unit.displayName = thisUnit.DisplayName;
appDataType.compuMethod.unit.factorToSI = thisUnit.FactorToSI;
appDataType.compuMethod.unit.offsetToSI = thisUnit.OffsetToSI;
appDataType.compuMethod.unit.physicalDimensionRef  = thisUnit.PhysicalDimRef;

%% create data constraint
[dataConstraintPath, dataConstraintName] = extractObjectDetails(thisAppDataType.DataConstraint);

%find the data constraint
for(ii = 1:length(arxmlImport.AppDataConsts))
    %find the compumethod reference
    if(strcmp(arxmlImport.AppDataConsts{ii}.Name,dataConstraintName))
        thisDataConstraint = arxmlImport.AppDataConsts{ii};
        break;
    end
    
end

%assign the properties
appDataType.dataConstraint = DataConstraint(dataConstraintPath,thisDataConstraint.Name);
appDataType.dataConstraint.physConstUpLim = thisDataConstraint.PhysConstLowLim;
appDataType.dataConstraint.physConstLowLim = thisDataConstraint.PhysConstUpLim;

%% create data type mapping set

%find the data type mapping set
for(ii = 1:length(arxmlImport.DataTypeMappingSets))
    %find the compumethod reference
    if(strcmp(arxmlImport.DataTypeMappingSets{ii}.AppDataRef,[appDataType.package,appDataType.name]))
        thisDataTypeMappingSet = arxmlImport.DataTypeMappingSets{ii};
        break;
    end
    
end

%find full path to data type mapping set
for(ii = 1:length(arxmlImport.InternalBehavior{1}.DTMSRefs))
    %find the compumethod reference
    [dataTypeMappingSetPath, dataTypeMappingSetName] = extractObjectDetails(arxmlImport.InternalBehavior{1}.DTMSRefs{ii}.DataElementRef);
    if(strcmp(dataTypeMappingSetName,thisDataTypeMappingSet.Name))
        thisDataTypeMappingSetRef = arxmlImport.InternalBehavior{1}.DTMSRefs{ii};
        break;
    end
    
end

%extract the details and create the data object
[dataTypeMappingSetPath, dataTypeMappingSetName] = extractObjectDetails(thisDataTypeMappingSetRef.DataElementRef);
appDataType.dataTypeMappingSet = DataTypeMappingSet(dataTypeMappingSetPath,dataTypeMappingSetName);
appDataType.dataTypeMappingSet.appDataTypeRef = thisDataTypeMappingSet.AppDataRef;
appDataType.dataTypeMappingSet.impDataTypeRef = thisDataTypeMappingSet.ImpDataRef;


%% create implmentation data type
%get the details
[impDataTypePath, impDataTypeName] = extractObjectDetails(appDataType.dataTypeMappingSet.impDataTypeRef);

%find the implemenation data type
for(ii = 1:length(arxmlImport.ImpDataTypes))
    %find the compumethod reference
    if(strcmp(arxmlImport.ImpDataTypes{ii}.Name,impDataTypeName))
        thisImpDataType = arxmlImport.ImpDataTypes{ii};
        break;
    end
    
end

%assign the data
appDataType.impDataType = ImpDataType(impDataTypePath,impDataTypeName);
appDataType.impDataType.category = thisImpDataType.Category;
appDataType.impDataType.typeEmitter = thisImpDataType.TypeEmitter;

%% create base type

if(~isempty(thisImpDataType.BaseTypeRef))
    [baseTypePath, baseTypeName] = extractObjectDetails(thisImpDataType.BaseTypeRef);
    
    %find the base type
    for(ii = 1:length(arxmlImport.BaseTypes))
        %find the compumethod reference
        if(strcmp(arxmlImport.BaseTypes{ii}.Name,baseTypeName))
            thisBaseTypeType = arxmlImport.BaseTypes{ii};
            break;
        end
        
    end
    
    %assign the data
    appDataType.impDataType.baseType = BaseType(baseTypePath,thisBaseTypeType.Name);
    appDataType.impDataType.baseType.baseTypeSize = thisBaseTypeType.BaseTypeSize;
    appDataType.impDataType.baseType.serviceKind = thisBaseTypeType.ServiceKind;
    
elseif(~isempty(thisImpDataType.ImpDataTypeRef)) 
    %if no base type is defined check for imp data ref
    appDataType.impDataType.impTypeRef = thisImpDataType.ImpDataTypeRef;
end

end

function [path, name] = extractObjectDetails(object)

%find seperator
idx = findstr(object,'/');

%get path to object
path = object(1:idx(end));

%get name of object
name = object(idx(end)+1:end);

end