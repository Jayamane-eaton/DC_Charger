clc;

%% creation of new folder for storing regression testing xlsx data and locations
MBDFolder = what('MBD');
rootFolder_A = strcat(MBDFolder.path,'\Unit Test Reports\')
if ~exist(rootFolder_A, 'dir')
    mkdir(rootFolder_A);
    addpath(rootFolder_A);
end
dest_folder = [rootFolder_A,'RegressionTest\'];
if ~exist(dest_folder, 'dir')
  mkdir(dest_folder);
  addpath(dest_folder);
end
%% Identify all the folders containing 'Test Data' for all the SWCs
rootFolder = fileparts(which('M3Inverter_startup.m'));
UnitTestFolder = fileparts(which('UnitTestFactory.m'));
diary(fullfile(UnitTestFolder,'TestFiles.txt'));
    dir(strcat(rootFolder,'\MBD\**/*.xlsx'));
diary off
clc;

text = fileread(fullfile(UnitTestFolder,'TestFiles.txt'));
delete(fullfile(UnitTestFolder,'TestFiles.txt'));
textLines = splitlines(text);
UTFolders = {};
folderCount = 1;
files = "";
for ii=1:length(textLines)
    if startsWith(textLines{ii},'Files Found in:')
        if contains(textLines{ii},{'Architecture\SystemDesk','MBD\CodeGen','MBD\DesignReports',...
                'MBD\Main','MBD\NPe','MBD\PlantModels','MBD\VAndV'})
        else
            UTFolders{folderCount} = erase(extractAfter(textLines{ii},'Files Found in:'),' ');
            folderCount = folderCount +1;
        end
    end
end

%% Fetching the regression test data from individual SWCs test folder and storing it in a repository for batch execution
 for kk=1:length(UTFolders)
     pathTest = UTFolders{kk};
     SWCNames = dir(pathTest);
     pathFolders = regexp(pathTest, '\', 'split');
     for iFd = 3:length(SWCNames)
         testXlsx = dir([pathTest,'\','*.xlsx']);
         n_testCases = length(testXlsx);
         
         if n_testCases > 0 
                 for num1 = 1:n_testCases
                     
                     repositoryTestCases{num1,1} = testXlsx(num1).name;
                     repositoryTestCases{num1,2} = strcat(testXlsx(num1).folder,'\');
                     repositoryTestCases{num1,3} = testXlsx(num1).date;
                 end
                 filenameTest = strcat(dest_folder,pathFolders{length(pathFolders)},'.mat');
                 save(filenameTest,'repositoryTestCases');
         end
         clear repositoryTestCases filenameTest;
     end
 end
