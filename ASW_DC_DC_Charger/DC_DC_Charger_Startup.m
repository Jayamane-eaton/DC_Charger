
% Author               Version    Date
% Suraj Eknath Jagtap    2.0      31/03/2022
% Suraj Eknath Jagtap    3.0      03/05/2022
tic
disp('## Configuring Work folder')
 rootFolder  = fileparts(which(mfilename));
% idcs   = strfind(rootFolder,'\');
%rootFolder = rootFolder(1:idcs(end)-1);
cd (rootFolder);

myCacheFolder = [rootFolder filesep 'Work'];
if ~isfolder(myCacheFolder)
    mkdir(myCacheFolder);
else
    rmdir Work s;
    mkdir(myCacheFolder);
end
disp('## Configuring MATLAB path');
addpath(genpath(rootFolder));
rmpath(genpath([rootFolder filesep 'Release']));

%run(which('SWC_Template.slx'))
Simulink.fileGenControl('set',...
    'CacheFolder', myCacheFolder,...
    'CodeGenFolder', myCacheFolder);

clear myCacheFolder rootFolder idcs;
%bdclose all
toc
%% Model Advisor Default Configuration Setting
% This script sets the Default Configuration of the Model Advisor to EATON
% Specific Model Advisor Configuration
% To restore back to the MATLAB Default Config run the below commands in
% command window
% Advisor.Manager.refresh_customizations
% ModelAdvisor.setDefaultConfiguration('');

%{
orig_state = warning; %Save the original state of warnings
warning('off','all'); %Suppress Warning due to Temp files
Advisor.Manager.refresh_customizations
ModelAdvisor.setDefaultConfiguration('EatonModelingGuidelinesR2019aV1.mat');
Advisor.Manager.refresh_customizations
warning(orig_state);%Restore the warnings
clear orig_state
%}