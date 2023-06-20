% updateSwCFromARXML updates an existing model per ARXML definitions
%
%   updateSwC(arxmlFilePath,destDir)
%   - arxmlFilePath: Full path to the ARXML file to be imported
%   - destDir: Path to the folder that will store the new Simulink model
%
%   updateSwC(arxmlFile)
%   Uses ARXML file name from argument, asks for model location and uses
%   default DD

function updateSwCFromARXML(arxmlFile,slModel,launchReport)
if nargin < 1
    [file,path] = uigetfile('*.arxml','Select ARXML file');
    if file == 0, return, end
    arxmlFile = [path file];
end

if nargin < 2
    [file,path] = uigetfile('*.slx', 'Select existing Simulink model to be updated');
    if file == 0, return, end
    slModel = [path file];
end

if nargin < 3
    launchReport = 'on';
end

load_system(slModel);

obj = arxml.importer(arxmlFile);
obj.updateModel(slModel, 'LaunchReport', launchReport);

[~,modelName,~] = fileparts(slModel);
if isfile([modelName '_backup.slx'])
    delete([modelName '_backup.slx']);
end

swcDataDictionaryObj = Simulink.data.dictionary.open([modelName '.sldd']);
saveChanges(swcDataDictionaryObj);
hide(swcDataDictionaryObj);
close(swcDataDictionaryObj);

standardize
shortenPortNames
% updateBlockName