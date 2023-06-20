classdef UnitTestFactory < handle
    %This class handles Unit Testing
    %Generates a xml file from the test case template
    %Create a test harness , run simulation and collect results
    %Generate test report
    properties
        xmlFile = XMLFileGeneration;
        testHarness = TestHarnessGeneration;
        testReport = TestReportGeneration;
        UTError = UnitTestError;
        globalError = false
        OverallResultsTable
    end
    
    methods
        function obj = UnitTestFactory()
            try
            optSelected= getUserInput(obj);
            obj.UTError.deleteLogErrorFile();
            load_system simulink;
            tic
            catch ME
                obj.setErrorMessage(ME);
            end
            if(optSelected == 0)
                try
                obj.OverallResultsTable = table('Size',[0 6],'VariableTypes',...
                                          {'categorical','categorical','categorical','categorical','categorical','categorical'});
                obj.OverallResultsTable.Properties.VariableNames = {'SWC_Name','System_Under_Test','Total_Test_Cases','Untested','Passed','Failed'};
                %Batch Mode execution
                obj.testReport.BatchMode = true;
                % run the script the fetch the regression testing data xlsx  
                accessRegData = which('AccessTestCases.m');
                run(accessRegData);
                repositoryP = what('RegressionTest');
                repositoryPath = strcat(repositoryP.path,'\');
                repositoryFiles = dir(repositoryPath);
                catch ME
                    obj.setErrorMessage(ME);
                end
                % batch mode execution
                for batch = 3:length(repositoryFiles)
                    try
                    filenameBatch = strcat(repositoryPath,repositoryFiles(batch).name);
                    load(filenameBatch);  
                    nFiles = length(repositoryTestCases(:,1));

                    if nFiles > 1
                        file = repositoryTestCases(:,1);
                    else
                        file = char(repositoryTestCases(:,1));
                    end
                    obj.testReport.Path = char(repositoryTestCases(1,2));
                    obj.runUnitTest(file);
                    obj.copyTestReportToBatchFolder();
                    clear repositoryTestCases filenameBatch nFiles
                    catch ME
                        obj.setErrorMessage(ME);
                    end
                end
                batchFolder = what('Unit Test Reports');
                writetable(obj.OverallResultsTable,[batchFolder.path,'\UnitTestOverallResults.xlsx']);
            elseif (optSelected == 1)
                try
                    %Single SWC Mode execution
                    [file,obj.testReport.Path] = uigetfile('*.xlsx','Select Excel file','MultiSelect', 'on');
                    if isequal(file,0) || isequal(obj.testReport.Path,0)
                        %Do nothing , no file selected
                    else
                        obj.runUnitTest(file);
                    end
                catch ME
                    obj.setErrorMessage(ME);
                end
            else
            end
            if obj.globalError
                %error(['1 or more errors found , Please check log error file: ',[obj.UTError.scriptFolder,'\UnitTest_ErrorLog.txt']]);
                disp(fileread([obj.UTError.scriptFolder,'\UnitTest_ErrorLog.txt']));
            end
            toc
        end   
    end
    
    methods (Access = private)   
        %This method executes the xml file,test harness and test report generation
        function runUnitTest(obj,file)
            obj.testReport.initTestReport();
            %change to directory where the file is read from
            cd(obj.testReport.Path);
            %Clear previous results from Test Manager 
            obj.testHarness.mergedTestSummaryData = [0 0 0 0];
            obj.testReport.HarnessIndex = 0;
            obj.testHarness.harnessCount = 0;
            %check if multiple files selected
            if iscell(file)
                %read data from file
                for  i =1 :length(file)
                    try
                    obj.xmlFile.xmlError = false;
                    obj.testHarness.testHarnessError = false;
                    obj.testReport.testReportError= false;
                    obj.validateFile(file{i});
                    if ~obj.xmlFile.ignoreFile
                        obj.testReport.HarnessIndex = obj.testReport.HarnessIndex + 1;
                        obj.testHarness.harnessCount = obj.testReport.HarnessIndex;
                        obj.createTestHarness(file{i});
                        obj.testHarness.closeHarness();
                           % save merged coverage data
                           if ~isempty(obj.testHarness.mergedCoverageData)
                               try
                                cvsave(strcat(obj.testHarness.modelName,'_','MergedCovRpt'), obj.testHarness.mergedCoverageData);
                                % generate html report for merged coverage data file
                                ExtractCoverageInfoAll(obj);
                               catch ME
                                   obj.testHarness.setErrorMessage(ME);
                               end
                           end
                        
                        obj.reestoreAll();
                        
                    end
                    catch ME
                        obj.reestoreAll();
                        obj.setErrorMessage(ME);
                    end
                end
                if ~obj.xmlFile.ignoreFile || (obj.testReport.HarnessIndex>1)
                    try
                        obj.testReport.mergedSummaryDataTable = obj.testReport.createMergedOverallSummaryTable();
                        obj.testReport.tableTestCoverage = obj.testHarness.createMergedCoverageTable();
                        obj.testReport.addChapterSection(obj.testReport.overallResultsChapter,[obj.testHarness.modelName,' - Merged Test Coverage'],obj.testReport.tableTestCoverage);
                        obj.testReport.addChapterSection(obj.testReport.overallResultsChapter,[obj.testHarness.modelName,' - Merged Results'],obj.testReport.mergedSummaryDataTable);
                    catch ME
                        obj.setErrorMessage(ME);
                    end
                end
            else
                try
                    %single file selected
                    obj.xmlFile.xmlError = false;
                    obj.testHarness.testHarnessError = false;
                    obj.testReport.testReportError= false;
                    obj.validateFile(file);
                    if ~obj.xmlFile.ignoreFile
                        obj.testReport.HarnessIndex = 1;
                        obj.testHarness.harnessCount = 1;
                        obj.createTestHarness(file);
                           % save merged coverage data
                           if ~isempty(obj.testHarness.mergedCoverageData)
                                cvsave(strcat(obj.testHarness.modelName,'_','MergedCovRpt'), obj.testHarness.mergedCoverageData);
                                % generate html report for merged coverage data file
                                ExtractCoverageInfoAll(obj);
                           end
                        obj.reestoreAll();
                        obj.testHarness.closeHarness();
                        obj.testHarness.saveModel();
                        obj.testHarness.closeModel(); 
                    end
                catch ME
                    obj.reestoreAll();
                    obj.setErrorMessage(ME);
                end
            end
            if ~obj.xmlFile.ignoreFile || (obj.testReport.HarnessIndex>0)
                %Generate test report
                obj.testReport.createCustomReport(); 
                obj.logTestReportError();
                
                if exist([obj.testReport.Path,'Snapshots'],'dir')
                   rmdir([obj.testReport.Path,'Snapshots'],'s');
                end
            end
        end
        
        function validateFile(obj,file)
            try
                %initialize SignalBuilder property from xmlFile obj
                obj.xmlFile.signalBuilderGroupActive = {};
                %create an xml file from an excel file
                obj.xmlFile.Convert_xlsx_to_xml(file);
                if obj.xmlFile.ignoreFile
                    obj.testHarness.Error.appendErrorText('This file doesn''t match with the test case template format.');
                    disp('This file doesn''t match with the test case template format.')
                end
            catch ME
                obj.setErrorMessage(ME);
            end
        end
        %This method creates the test harness
        function createTestHarness(obj,file)
            try
            obj.testHarness.Error.addTextToFile(['******************************************',...
                                                 '******************************************',...
                                                    '\nProccessing file: ',file]);
                %create test harness,run simulation and collect results
                obj.testHarness.createTestHarness(obj.xmlFile);
                %log errors if exist
                obj.logTestHarnessError();
                %create test report content
                obj.testReport.generateTestReport(obj.testHarness,obj.xmlFile.xlsxData);
                %log errors if exist
                obj.logTestReportError();
            catch ME
                
                obj.setErrorMessage(ME);
            end
        end
        
        %This method gets the script's execution mode
        function optSelected= getUserInput(obj)
            try
                obj.testReport.BatchMode = false;
                %get execution mode from user
                disp('Select script execution mode:');
                disp('Batch SWC mode : 0');
                disp('Single SWC mode : 1');
                userInput =  input('mode:');
                if isempty(userInput)
                    userInput = '1';
                elseif userInput == 0|| userInput == 1
                else
                    disp('InvalidSelection');
                    userInput = '-1';
                end
                optSelected = userInput;
            catch ME
                obj.setErrorMessage(ME);
            end
        end
        
        %This method copies the generated test report into Unit Test Report
        %folder when batch mode selected
        function copyTestReportToBatchFolder(obj)
            if ~obj.testHarness.testHarnessError && ~obj.testReport.testReportError
                try
                batchFolder = what('Unit Test Reports');
                FileName = [obj.testReport.subsystemName ,' Test Report.pdf'];
                source = fullfile(obj.testReport.Path,FileName);
                destination = fullfile(batchFolder.path,FileName);
                copyfile(source,destination);
                obj.OverallResultsTable(length(obj.OverallResultsTable.SWC_Name)+1,:) = {obj.testReport.modelName,...
                                                                                         obj.testHarness.subsystemName,...
                                                                                         string(obj.testHarness.mergedTestSummaryData(1)),...
                                                                                         string(obj.testHarness.mergedTestSummaryData(2)),...
                                                                                         string(obj.testHarness.mergedTestSummaryData(3)),...
                                                                                         string(obj.testHarness.mergedTestSummaryData(4))};
                catch ME
                    obj.setErrorMessage(ME);
                end
            end
        end
        %This method in case of an error reestores any configuration changed in DD or model
        %configuration,closes model and test harness.
        function reestoreAll(obj)
            if obj.testHarness.testHarnessError
                try
                    SWCDictonary = Simulink.data.dictionary.open([obj.testHarness.modelName,'.sldd']);
                    modelData = getSection(SWCDictonary,'Design Data');
                    discardChanges(SWCDictonary);
                    mdlWks = get_param(obj.testHarness.modelName,'ModelWorkspace');
                    reload(mdlWks);
                    obj.testHarness.closeHarness();
                    obj.testHarness.saveModel();
                    obj.testHarness.closeModel(); 
                catch ME
                    obj.setErrorMessage(ME);
                end
                obj.testHarness.testHarnessError = false; %disable error to allow execution of following methods.

                obj.testHarness.testHarnessError = true; %Enable error back.
                delete([obj.testReport.Path,'LoggedWarningsFromCommandWindow']);
                delete([obj.testReport.Path,[obj.testReport.testHarnessName,'_TestReport.docx']]);
            end
            %obj.testHarness.restoreMultiTaskingInReferencedConfiguration();
            
        end
        
        function logTestHarnessError(obj)
            if obj.testHarness.testHarnessError
                if isempty(obj.testHarness.modelName)
                    obj.testHarness.Error.Msg = strcat('ModelName : ',obj.testHarness.Error.ME.message);
                elseif isempty(obj.testHarness.testHarnessName)
                    obj.testHarness.Error.Msg = strcat('Test Harness Name : ',obj.testHarness.Error.ME.message);
                elseif isempty(obj.testHarness.subsystemPath)
                    obj.testHarness.Error.Msg = strcat('SubsystemPath : ',obj.testHarness.Error.ME.message);
                else
                    obj.testHarness.Error.Msg = obj.testHarness.Error.ME.message;%getReport(obj.testHarness.Error.ME);
                end
                %obj.testHarness.Error.logErrors();
                obj.globalError = true;
            end
        end
        
        function logTestReportError(obj)
            if obj.testReport.testReportError
                %obj.testReport.Error.Msg = getReport(obj.testReport.Error.ME);
                obj.testReport.Error.Msg = obj.testReport.Error.ME.message;
                %obj.testReport.Error.logErrors();
                obj.globalError = true;
            end
        end 
        
        function setErrorMessage(obj,ME)
			obj.UTError.ME = ME;
            obj.UTError.appendErrorText(ME.message);
        end
        
         function ExtractCoverageInfoAll(obj)
            if ~obj.globalError
               try
                   disp('processing merged coverage data file:');
                   % find .CVT files stored in the SWC test folder 
                   fileCVT = dir('*.cvt');
                   % if there multiple CVT files stored in the test folder,
                   % delete all the CVT except Merged CVT file for coverage
                   % data
                   mergedCVTfilename = strcat(obj.testHarness.modelName,'_','MergedCovRpt');
                   if isstruct(fileCVT)
                      for nameInfo = 1:length(fileCVT)
                          Idx_Merged = contains(fileCVT(nameInfo).name,mergedCVTfilename,'IgnoreCase',true) && ...
                              ~contains(fileCVT(nameInfo).name,'Copy','IgnoreCase',true);
                          if (Idx_Merged == 1)
                              [cvtos, cvdos] = cvload(fileCVT(nameInfo).name);
                              cvhtml(strcat(obj.testHarness.modelName,'_','CoverageReport','.html'),cvdos{1});
                              com.mathworks.mlservices.MatlabDesktopServices.getDesktop.closeGroup('Web Browser'); 
                          else
                              delete(fileCVT(nameInfo).name);
                          end
                      end
                   else
                   [cvtos, cvdos] = cvload(fileCVT.name);
                   cvhtml(strcat(obj.testHarness.modelName,'_','CoverageReport','.html'),cvdos{1});
                   com.mathworks.mlservices.MatlabDesktopServices.getDesktop.closeGroup('Web Browser'); 
                   end
               catch ME
                   obj.setErrorMessage(ME);
               end
           end
        end
           
    end
end

