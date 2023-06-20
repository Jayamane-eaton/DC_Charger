% createSwCFromARXML creates a new Simulink model from an ARXML SwC descriptor
%   createSwCFromARXML
%   Displays a user dialog, used to select the ARXML file to be imported,
%   displays a user dialog for the location of the newly created Simulink
%   model and uses the data dictionary located in 
%   <Project Root>\DataDictionaries\ModelConfigs.sldd
%
%   createSwCFromARXML(arxmlFilePath,destDir)
%   - arxmlFilePath: Full path to the ARXML file to be imported
%   - destDir: Path to the folder that will store the new Simulink model
%
%   createSwCFromARXML(arxmlFile)
%   Uses ARXML file name from argument, asks for model location and uses
%   default DD

function createSwCFromARXML(arxmlFilePath,destDir)
if nargin < 1
    [file,path] = uigetfile('*.arxml','Select ARXML file');
    if file == 0, return, end
    arxmlFilePath = [path file];
end

if nargin < 2
    destDir = uigetdir(pwd, 'Select destination folder for the newly created model');
    if destDir == 0, return, end
end

%%% Configure Work folder
pathName = mfilename('fullpath');
temp = strsplit(pathName,filesep);
temp = strjoin(temp(1:end-4),filesep);
workFolder = [temp '\Work'];
if ~isfolder(workFolder)
    mkdir(workFolder)
end
addpath(workFolder);
Simulink.fileGenControl('set',...
    'CacheFolder', workFolder,...
    'CodeGenFolder', workFolder)

pathName = mfilename('fullpath');
temp = strsplit(pathName,filesep);
temp = strjoin(temp(1:end-4),filesep);
dataDictionaries.types = [temp '\MBD\Main\AutosarSwcDataTypes.sldd'];
dataDictionaries.config = [temp '\Utilities\MATLAB\Config\ModelConfigs.sldd'];
createSimulinkModelFromARXML(arxmlFilePath,destDir,dataDictionaries);

end

function createSimulinkModelFromARXML(arxmlFilePath,destDir,dataDictionaries)

%%% Create full file paths for each file type
[folder,name] = fileparts(arxmlFilePath);

arxmlName = strcat(name,'.arxml');
ddName = strcat(name,'.sldd');
slxName = strcat(name,'.slx');

destDir = [destDir '\' name];
if ~isfolder(destDir)
    mkdir(destDir)
end

arxmlFullfile = strcat(folder,'\',arxmlName);
ddFullfile = strcat(destDir,'\',ddName);
slxFullfile = strcat(destDir,'\',slxName);

%%% Error checking
% Check if arxml file exists exists in current folder
if ~isfile(arxmlFullfile)
    error('ARXML file input must be a valid file name on path')
end

% check if model for the file exists exists in current folder
if isfile(slxFullfile)
    error('Simulink model already exists. Use update script instead or delete existing simulink model')
end

% check if model is open (but not saved)
tmp = find_system('SearchDepth',0);
if size(tmp)>0
    for i=1:size(tmp)
        if isequal(slxName, tmp(1))
           error('Simulink model with name already open. Either close without saving to use this script or save and use update script.')
        end
    end
end

% Check if data dictionary for the file exists in the work folder
if isfile(ddFullfile)
    error('Data Dictionary already exists. Use update script instead or delete existing Data Dictionary')
end
% Create a data dictionary
swcDataDictionaryObj = Simulink.data.dictionary.create(ddFullfile);
addpath(destDir);

% Import arxml, create model, attach data dictionary, create runnable
importerObj = arxml.importer(arxmlFullfile) %#ok
application_components = importerObj.getComponentNames;
swcModelHandle = importerObj.createComponentAsModel(application_components{1}, ...
    'ModelPeriodicRunnablesAs','Auto',...
    'DataDictionary',ddName);
modelName = get_param(swcModelHandle,'Name');

% Get data from component data dictionary
dDataSectObj = getSection(swcDataDictionaryObj,'Design Data');

% Open AutosarSwcDataTypes.sldd
master_ddFullfile = dataDictionaries.types;
master_swcDataDictionaryObj = Simulink.data.dictionary.open(master_ddFullfile);
master_dDataSectObj = getSection(master_swcDataDictionaryObj,'Design Data');

% Move data from component data dictionary to AutosarSwcDataTypes.sldd
entries = find(dDataSectObj);
for ii = 1:length(entries)
    if(~isempty(find(master_dDataSectObj,'Name',entries(ii).Name)))
        disp(['## Existing entry ' entries(ii).Name ' in AutosarSwcDataTypes.sldd was updated'])
        deleteEntry(master_dDataSectObj,entries(ii).Name)
    end
    addEntry(master_dDataSectObj,entries(ii).Name,getValue(entries(ii)));
    deleteEntry(dDataSectObj,entries(ii).Name)
end

% Attach referenced data dictionaries
f = fieldnames(dataDictionaries);
for ii = 1:length(f)
    [ddDir,ddName,ext] = fileparts(dataDictionaries.(f{ii}));
    addpath(ddDir);
    addDataSource(swcDataDictionaryObj,strcat(ddName,ext));
end

% Save data dictionaries and close them
saveChanges(swcDataDictionaryObj);
hide(swcDataDictionaryObj);
close(swcDataDictionaryObj);

saveChanges(master_swcDataDictionaryObj);
hide(master_swcDataDictionaryObj);
close(master_swcDataDictionaryObj);

% Save model in destination directory
save_system(modelName,[destDir '\' slxName]);
[~,modelName,~] = fileparts(slxName);

% Set active model configuration
cref = Simulink.ConfigSetRef;
cref.Name = 'ModelConfig';
cref.SourceName = 'CodeGenConfig_Autosar';
attachConfigSet(modelName,cref,true);
setActiveConfigSet(modelName,'ModelConfig');
save_system(modelName);
open(bdroot);%Move to model top level
% Execute standardize
standardize

% Shorten port names
shortenPortNames

% Save model
save_system(modelName);

end