function A2LMerge(buildFolder)

MergedEvents = [];                 % Cell array of strings of the names of all of the events in the A2L files
MergedMeasurements = [];           % Cell array of strings of the names of the measurements in the A2L files
MergedCharacteristics = [];        % Cell array of strings of the names of the characteristics in the A2L files
MergedCompuMethods = [];           % Cell array of strings of the names of the Compu Methods in the A2L files 
MergedCompuTabs = [];              % Cell array of strings of the names of the Compu Tabs in the A2L files 
MergedCompuVTabs = [];             % Cell array of strings of the names of the Compu VTabs in the A2L files 
MergedRecordLayouts = [];          % Cell array of strings of the names of the Record Layouts in the A2L files 
MergedAxis = [];                   % Cell array of strings of the names of the Axis in the A2L files 

MergedEventsInfo = {};             % Container for Event objects
MergedMeasurementsInfo = {};       % Container for Measurement objects
MergedCharacteristicsInfo = {};    % Container for Characteristic objects
MergedAxisInfo = {};               % Container for Axis objects.
MergedRecordLayoutsInfo = {};      % Container for Record Layout objects.
MergedCompuMethodsInfo = {};       % Container for Computation method objects.
MergedCompuTabsInfo = {};          % Container for ComputationVAB method objects (used for interp).
MergedCompuVTabsInfo = {};         % Container for ComputationVTAB method objects (used for enum).

A2LFiles = FindA2LFiles(buildFolder);

for fl=1:length(A2LFiles)
    
    a2lfile = xcpA2L(string(A2LFiles(fl)));
        
    %Read and Merge Events
    for ii=1:length(a2lfile.Events)
        str = a2lfile.Events(ii);
        MergedEvents = [MergedEvents, str];
        MergedEventsInfo{end + 1} = getEventInfo(a2lfile, string(str));
    end

    %Read and Merge Measurements and related Compu Methods
    for ii=1:length(a2lfile.Measurements)
        str = a2lfile.Measurements(ii);
        if ~strcmp(MergedMeasurements, str)
            MergedMeasurements = [MergedMeasurements, str];
            MeasurementInfo = getMeasurementInfo(a2lfile, string(str));
            MergedMeasurementsInfo{end + 1} = MeasurementInfo;

            %Merge Compu Methods
            CompuMethod = MeasurementInfo.Conversion;
           
            if strcmp(class(CompuMethod), 'xcp.CompuMethodEnum')
                if ~strcmp(MergedCompuVTabs, CompuMethod.Name)
                    MergedCompuVTabs{end + 1} = CompuMethod.Name;
                    MergedCompuVTabsInfo{end + 1} = CompuMethod;
                end
            elseif strcmp(class(CompuMethod), 'xcp.CompuMethodRational')
                if ~strcmp(MergedCompuMethods, CompuMethod.Name)
                    MergedCompuMethods{end + 1} = CompuMethod.Name;
                    MergedCompuMethodsInfo{end + 1} = CompuMethod;
                end
            else
                %Unsupported Conversion type
            end
        end
    end

    %Read and Merge Characteristics, Record Layouts and Compu Methods, Axis
    for ii=1:length(a2lfile.Characteristics)
        %Merge Characteristics
        str = a2lfile.Characteristics(ii);
        if ~strcmp(MergedCharacteristics, str)
            MergedCharacteristics = [MergedCharacteristics, str];
            CharacteristicsInfo = getCharacteristicInfo(a2lfile, string(str));
            MergedCharacteristicsInfo{end + 1} = CharacteristicsInfo;

            %Merge Record Layout
            RecordLayout = CharacteristicsInfo.Deposit;
            if ~strcmp(MergedRecordLayouts, RecordLayout.Name)
                MergedRecordLayouts{end + 1} = RecordLayout.Name;
                MergedRecordLayoutsInfo{end + 1} = RecordLayout;
            end
            
            %Merge Compu Method
            CompuMethod = CharacteristicsInfo.Conversion;
            if strcmp(class(CompuMethod), 'xcp.CompuMethodEnum')
                %Merge CompuVTabs
                if ~strcmp(MergedCompuVTabs, CompuMethod.Name)
                    MergedCompuVTabs{end + 1} = CompuMethod.Name;
                    MergedCompuVTabsInfo{end + 1} = CompuMethod;
                end
            elseif strcmp(class(CompuMethod), 'xcp.CompuMethodRational')
                % Merge CompuMethod
                if ~strcmp(MergedCompuMethods, CompuMethod.Name)
                    MergedCompuMethods{end + 1} = CompuMethod.Name;
                    MergedCompuMethodsInfo{end + 1} = CompuMethod;
                end
            else
                %Unsupported Conversion type
            end
            
            %Merge Axis 
            if length(CharacteristicsInfo.AxisConversion)
                if ~strcmp(MergedAxis, CharacteristicsInfo.AxisConversion{1,1}.Name)
                    MergedAxis{end + 1} = CharacteristicsInfo.AxisConversion{1 ,1}.Name;
                    MergedAxisInfo{end + 1} = CharacteristicsInfo.AxisConversion{1,1};
                end
            end
        end
    end
end


% Write Merged ASAP File
ASAP2File = 'Eaton_ASW_Merged.A2L';

fid = fopen(fullfile(buildFolder,ASAP2File),'w+');
fprintf(fid, '/******************************************************************************\n');
fprintf(fid, '*\n');
fprintf(fid, '*\tASAP2 file: %s\n', ASAP2File);
fprintf(fid, '*\tA2L for all Eaton ASW Software Components\n');
fprintf(fid, '*\n');
fprintf(fid, '/******************************************************************************\n');
fprintf(fid, '*\n');
fprintf(fid, 'ASAP2_VERSION  1 31   /* Version 1.31 */');
fprintf(fid, '\n');
fprintf(fid, '/begin PROJECT M3Inverter "Eaton ASW"');
fprintf(fid, '\n');  
fprintf(fid, '\n\t/begin HEADER "Header Comments go here"');
fprintf(fid, '\n\t');    
fprintf(fid, '\n\t/end HEADER');
fprintf(fid, '\n');    
fprintf(fid, '\n\t/begin MODULE ModuleName  "Module Comment Goes Here"');
fprintf(fid, '\n');        
fprintf(fid, '\n\t\t/begin MOD_PAR "MOD PAR Comment Goes Here"');
fprintf(fid, '\n');              
fprintf(fid, '\n\t\t/end MOD_PAR');
fprintf(fid, '\n');            
fprintf(fid, '\n\t\t/begin MOD_COMMON  "Mod Common Comment Here"'); 
fprintf(fid, '\n\t\t\tBYTE_ORDER     MSB_LAST');
fprintf(fid, '\n\t\t/end MOD_COMMON');
fprintf(fid, '\n');

for ii=1:length(MergedRecordLayoutsInfo)
    fprintf(fid, '\n\t\t/begin RECORD_LAYOUT %s', MergedRecordLayoutsInfo{1, ii}.Name);
    fprintf(fid, '\n\t\t\t%s %d %s %s %s', MergedRecordLayoutsInfo{1, ii}.Records{1,1}.Name,MergedRecordLayoutsInfo{1, ii}.Records{1,1}.Position,MergedRecordLayoutsInfo{1, ii}.Records{1,1}.DataType,MergedRecordLayoutsInfo{1, ii}.Records{1,1}.IndexMode,MergedRecordLayoutsInfo{1, ii}.Records{1,1}.AddressType);   
    fprintf(fid, '\n\t\t/end   RECORD_LAYOUT');
    fprintf(fid, '\n');
end

for ii=1:length(MergedCharacteristicsInfo)
    fprintf(fid, '\n\t\t/begin CHARACTERISTIC');
    fprintf(fid, '\n\t\t\t/* Name                   */      %s',MergedCharacteristicsInfo{1, ii}.Name);
    str = MergedCharacteristicsInfo{1, ii}.LongIdentifier;
    str = insertBefore(str,'"','\');
    fprintf(fid, '\n\t\t\t/* Long Identifier        */      "%s"',str);
    fprintf(fid, '\n\t\t\t/* Type                   */      %s',MergedCharacteristicsInfo{1, ii}.CharacteristicType); 
    fprintf(fid, '\n\t\t\t/* ECU Address            */      0x%04x /* @ECU_Address@%s@ */',MergedCharacteristicsInfo{1, ii}.ECUAddress,MergedCharacteristicsInfo{1, ii}.Name);  
    fprintf(fid, '\n\t\t\t/* Record Layout          */      %s',MergedCharacteristicsInfo{1, ii}.Deposit.Name); 
    fprintf(fid, '\n\t\t\t/* Maximum Difference     */      0'); %Check with Axis info 
    fprintf(fid, '\n\t\t\t/* Conversion Method      */      %s',MergedCharacteristicsInfo{1, ii}.Conversion.Name); 
    fprintf(fid, '\n\t\t\t/* Lower Limit            */      %.1f',MergedCharacteristicsInfo{1, ii}.LowerLimit); 
    fprintf(fid, '\n\t\t\t/* Upper Limit            */      %.1f',MergedCharacteristicsInfo{1, ii}.UpperLimit);
    
    if strcmp(MergedCharacteristicsInfo{1, ii}.CharacteristicType, 'CURVE')
        % Add code for Axis PTS
    elseif strcmp(MergedCharacteristicsInfo{1, ii}.CharacteristicType, 'VAL_BLK')
    fprintf(fid, '\n\t\t\t/* Array Size             */ \n\t\t\t NUMBER                       %d',MergedCharacteristicsInfo{1, ii}.Dimension);    
    end
    
    fprintf(fid, '\n\t\t/end   CHARACTERISTIC');
    fprintf(fid, '\n');
    
end

for ii=1:length(MergedMeasurementsInfo)
    fprintf(fid, '\n\t\t/begin MEASUREMENT');
    fprintf(fid, '\n\t\t\t/* Name                   */      %s',MergedMeasurementsInfo{1, ii}.Name);
    str = MergedMeasurementsInfo{1, ii}.LongIdentifier;
    str = insertBefore(str,'"','\');
    fprintf(fid, '\n\t\t\t/* Long Identifier        */      "%s"',str);
    fprintf(fid, '\n\t\t\t/* Data type              */      %s',MergedMeasurementsInfo{1, ii}.LocDataType); 
    fprintf(fid, '\n\t\t\t/* Conversion Method      */      %s',MergedMeasurementsInfo{1, ii}.Conversion.Name);  
    fprintf(fid, '\n\t\t\t/* Resolution (Not used)  */      0'); 
    fprintf(fid, '\n\t\t\t/* Accuracy (Not used)    */      0');  
    fprintf(fid, '\n\t\t\t/* Lower Limit            */      %.1f',MergedMeasurementsInfo{1, ii}.LowerLimit); 
    fprintf(fid, '\n\t\t\t/* Upper Limit            */      %.1f',MergedMeasurementsInfo{1, ii}.UpperLimit);
    fprintf(fid, '\n\t\t\tECU_ADDRESS                       0x%04x /* @ECU_Address@%s@ */',MergedMeasurementsInfo{1, ii}.ECUAddress,MergedMeasurementsInfo{1, ii}.Name);
    fprintf(fid, '\n\t\t/end   MEASUREMENT');
    fprintf(fid, '\n');
end
for ii=1:length(MergedCompuMethodsInfo)
    fprintf(fid, '\n\t\t/begin COMPU_METHOD');
    fprintf(fid, '\n\t\t\t/* Name                   */      %s',MergedCompuMethodsInfo{1, ii}.Name);   
    fprintf(fid, '\n\t\t\t/* Long Identifier        */      "%s"',MergedCompuMethodsInfo{1, ii}.LongID);
    fprintf(fid, '\n\t\t\t/* Conversion Type        */      RAT_FUNC'); 
    fprintf(fid, '\n\t\t\t/* Format                 */      "%s"',MergedCompuMethodsInfo{1, ii}.Format);  
    fprintf(fid, '\n\t\t\t/* Units                  */      "%s"',MergedCompuMethodsInfo{1, ii}.Unit); 
    fprintf(fid, '\n\t\t\t/* Coefficients           */      COEFFS %d %d %d %d %d %d',MergedCompuMethodsInfo{1, ii}.a,MergedCompuMethodsInfo{1, ii}.b,MergedCompuMethodsInfo{1, ii}.c,MergedCompuMethodsInfo{1, ii}.d,MergedCompuMethodsInfo{1, ii}.e,MergedCompuMethodsInfo{1, ii}.f);  
    fprintf(fid, '\n\t\t/end   COMPU_METHOD');
    fprintf(fid, '\n');
end

for ii=1:length(MergedCompuVTabsInfo)
    
    fprintf(fid, '\n\t\t/begin COMPU_METHOD');
    fprintf(fid, '\n\t\t\t/* Name                   */      %s',MergedCompuVTabsInfo{1, ii}.Name);   
    fprintf(fid, '\n\t\t\t/* Long Identifier        */      "%s"',MergedCompuVTabsInfo{1, ii}.LongID);
    fprintf(fid, '\n\t\t\t/* Conversion Type        */      TAB_VERB'); 
    fprintf(fid, '\n\t\t\t/* Format                 */      "%s"',MergedCompuVTabsInfo{1, ii}.Format);  
    fprintf(fid, '\n\t\t\t/* Units                  */      "%s"',MergedCompuVTabsInfo{1, ii}.Unit); 
    fprintf(fid, '\n\t\t\t/* Conversion Table       */      COMPU_TAB_REF %s',MergedCompuVTabsInfo{1, ii}.CompuTab.Name);  
    fprintf(fid, '\n\t\t/end   COMPU_METHOD');
    fprintf(fid, '\n');
    
    fprintf(fid, '\n\t\t/begin COMPU_VTAB');
    fprintf(fid, '\n\t\t\t/* Name of Table          */      %s',MergedCompuVTabsInfo{1, ii}.CompuTab.Name);   
    fprintf(fid, '\n\t\t\t/* Long Identifier        */      "%s"',MergedCompuVTabsInfo{1, ii}.CompuTab.LongID);
    fprintf(fid, '\n\t\t\t/* Conversion Type        */      TAB_VERB'); 
    fprintf(fid, '\n\t\t\t/* Number of Elements     */      %d',length(MergedCompuVTabsInfo{1, ii}.CompuTab.InTab));  
    
    for iii=1:length(MergedCompuVTabsInfo{1, ii}.CompuTab.InTab)
    fprintf(fid, '\n\t\t\t/* Table Element          */      %d "%s"',MergedCompuVTabsInfo{1, ii}.CompuTab.InTab(iii), string(MergedCompuVTabsInfo{1, ii}.CompuTab.OutTab(iii))); 
    end
    
    fprintf(fid, '\n\t\t/end   COMPU_VTAB');
    fprintf(fid, '\n');
end


fprintf(fid, '\n\t/end MODULE');

fprintf(fid, '\n');
fprintf(fid, '\n/end PROJECT');
fclose(fid);


%% Search for A2L files
function [FList] = FindA2LFiles(DataFolder)

if nargin < 1
    DataFolder = uigetdir;
end

DirContents=dir(DataFolder);
FList=[];

if ~isunix
    NameSeperator='\';
else isunix
    NameSeperator='/';
end

extList={'A2L'};

for i=1:numel(DirContents)
    if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
        if(~DirContents(i).isdir)
            if (length(DirContents(i).name) > 3)
                extension=DirContents(i).name(end-2:end);
            end
            
            if(numel(find(strcmpi(extension,extList)))~=0)
                FList=cat(1,FList,{[DataFolder,NameSeperator,DirContents(i).name]});
            end
        else
            getlist=FindA2LFiles([DataFolder,NameSeperator,DirContents(i).name]);
            FList=cat(1,FList,getlist);
        end
    end
end


