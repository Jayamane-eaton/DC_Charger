% This functions loads the model workspace data in baseworkspace, deletes
% the calibrations / signals related to data stores and save the remaining
% calibrations to a new mat file. This matfile data is transferred to sldd
% in configureSWCMemorySections.m
function newVars = convertMdlToSldd(name)
    % load the model workspace data
    load(strcat(name,'.mat'));
    % clear name of model workspace data file and Cals / Signals data related to datastore 
    clear name;
    clear -regexp PIM_ _PIM 
    clear -regexp IV_ _IV
% save model workspace data in a mat file              
   save('MdlToSlddData.mat');

end