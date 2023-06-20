classdef TestReportGeneration < handle
    properties
        modelName
        Path
        BatchMode
        testHarnessName
        subsystemName
        overallResultsChapter
        testDescriptionChapter
        testCaseSummaryChapter
        signalBuilderChapter
        mergedTestSummaryData
        mergedSummaryDataTable
        tableTestCoverage
        HarnessIndex
        tableTestCase
        xlsxData
        testCaseHyperlinkText
        tableTestCaseDescription
        HyperlinkIdx
        tableSummary
        signalBuilderBlock
		testHarnessError
        testReportError
        Error = UnitTestError
    end
    methods
        function generateTestReport(obj,SimResults,Data)
            InitProperties(obj,SimResults,Data);

            createTestReportContent(obj);
        end
        
    end
    methods (Access = {?UnitTestFactory})
        function InitProperties(obj,SimResults,Data)
            if ~obj.testReportError
                obj.modelName = SimResults.modelName; 
                obj.testHarnessName = SimResults.testHarnessName;
                obj.subsystemName = SimResults.subsystemName;
                obj.xlsxData = Data;
                obj.tableSummary = SimResults.tableSummary;
                obj.mergedTestSummaryData = SimResults.mergedTestSummaryData;
                obj.tableTestCaseDescription = SimResults.tableTestCaseDescription;
                obj.tableTestCase = SimResults.tableTestCase;
                obj.signalBuilderBlock = SimResults.signalBuilderBlock;
				obj.testHarnessError = SimResults.testHarnessError;
                obj.tableTestCoverage = SimResults.coverageTable;
            end
        end
        
        function initTestReport(obj)
            obj.overallResultsChapter = {};
            obj.testDescriptionChapter = {};
            obj.testCaseSummaryChapter = {};
            obj.signalBuilderChapter = {};
        end
        
         function [found x y]= findString(obj,data,strtofind)
            if ~obj.testReportError && ~obj.testHarnessError
                %Get the size of the data
                [NumRows NumColumns]=size(data);
                found = 0;
                %Look for the string in the data
                for x = 1: NumRows
                    for y = 1: NumColumns
                        if strcmp(data(x,y),strtofind)
                            found = 1;
                            return
                        end
                    end
                end
            else
                [found x y] = [0 0 0];
            end
        end

        function [TCRow TCColumn] = findTestCases(obj,data)
            if ~obj.testReportError && ~obj.testHarnessError
                %Get the size of the data
                [rows columns] = size(data);
                %Look for Test Name column
                [resultTN rowTN TCColumn] = findString(obj,data,'Tests Name');
                Test_Idx = 1;
                %check if any test case name exist
                if resultTN
                    for i = rowTN+1:rows
                        if ~ismissing(data(i,TCColumn))
                            %save the row number where the test case begins
                            TCRow(Test_Idx)=i;
                            Test_Idx = Test_Idx + 1;
                        end
                    end  
                end
                TCRow(Test_Idx)= rows;
            else
                [TCRow TCColumn] = [0 0];
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%-----FUNCTIONS TO GENERATE TEST REPORT----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function createCustomReport(obj)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    R = Report([obj.subsystemName,' Test Report'],'pdf');
                    open(R);
                    %Create main page
                    createMainPage(obj,R);
                    %createTableOfContents(obj,Report);
                    toc = TableOfContents;
                    toctitle = Paragraph('Table of Contents');
                    toctitle.Style = {Bold,FontFamily('Times New Roman'),HAlign('left'),FontSize('18pt')};
                    toc.Title = toctitle;
                    add(R,toc);

                    %createTestReportContent(obj);
                    add(R,obj.overallResultsChapter);
                    add(R,obj.testDescriptionChapter);
                    add(R,obj.testCaseSummaryChapter);
                    if ~isempty(obj.signalBuilderBlock)
                        add(R,obj.signalBuilderChapter);
                    end
                    close(R);
                catch ME
                    obj.setErrorMessage(ME);
                end
            end
        end  
        function createTestReportContent(obj)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    TableSum = createOverallSummaryTable(obj);
                    TCSum = createTestCaseSummaryTable(obj);

                    if isempty(obj.overallResultsChapter)
                        obj.overallResultsChapter = createChapter(obj,'Overall Results',false);
                    end
                    if isempty(obj.testDescriptionChapter)
                        obj.testDescriptionChapter = createChapter(obj,'Test Description',false);
                    end
                    if isempty(obj.testCaseSummaryChapter)
                        obj.testCaseSummaryChapter = createChapter(obj,'Test Summary',false);
                    end
                    if ~isempty(obj.signalBuilderBlock)&&isempty(obj.signalBuilderChapter)
                        obj.signalBuilderChapter = createChapter(obj,'Signal Builder Inputs',false);
                    end
                          
                    addChapterSection(obj,obj.overallResultsChapter,[obj.testHarnessName,' - Test Summary'],TableSum);
                    addChapterSection(obj,obj.overallResultsChapter,[obj.testHarnessName,' - Test Coverage'],obj.tableTestCoverage);

                    addChapterSection(obj,obj.testDescriptionChapter,[obj.testHarnessName,' - Test Cases'],TCSum);

                    createTestSummaryChapter(obj);
                    if ~isempty(obj.signalBuilderBlock)
                        obj.getSignalBuilderSnapshot();
                    end
                catch ME
                    obj.setErrorMessage(ME);
                end
            end
        end
        
        function newChapter = createChapter(obj,chpTitle,layoutStyle)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    newChapter = Chapter();
                    newChapter.Layout.Landscape = layoutStyle;
                    newChapter.Title = (chpTitle);
                catch ME
                    obj.setErrorMessage(ME);
                end
            end
        end
        
        function addChapterSection(obj,docChapter,sectionTitle,sectionContent)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    newSection = Section('Title',sectionTitle,'Content',sectionContent);
                    %newSection.LinkTarget = string(["TestDescription_",sprintf("%d",obj.HarnessIndex)])
                    if contains(sectionTitle,"Test Cases")
                        newSection.LinkTarget = ['TestDescription_',char(sprintf("%d",obj.HarnessIndex))];
                    end
                    add(docChapter,newSection);
                catch ME
                    obj.setErrorMessage(ME);
                end
            end
        end
        
        function createTestSummaryChapter(obj)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    testCaseSection = Section('Title',[obj.testHarnessName,'- TEST CASES']);
                    if ~isempty(obj.signalBuilderBlock)
                        testCaseSection.LinkTarget = [obj.testHarnessName,'- TEST CASES'];
                    end
                    SectionName = '';
                    columnWidth = {'6in','0.2in','0.4in'};
                    [numberOfRows numberOfColumns] = size(obj.tableTestCase);
                    [TestCaseStartRowIdx TestCaseColumn] = findTestCases(obj,obj.xlsxData);
                    failedResults = {};
                    TestCaseCounter = 1;
                    TestCaseTableCounter = obj.HyperlinkIdx;
                    for rowCnt = 1:numberOfRows
                        if strcmp(string(obj.tableTestCase.Result(rowCnt)),"Passed")
                            ResultIcon =  getPassIcon(obj);
                        else
                            ResultIcon =  getfailIcon(obj);
                            failedResults{length(failedResults)+1,1} = string(obj.tableTestCase.CurrentValue(rowCnt));
                        end
                        if ~ismissing(obj.tableTestCase.TestCase(rowCnt))&&~ismissing(obj.tableTestCase.TestStep(rowCnt)) %New Test Case
                            headerRowTitle = {char(["Test Step: ",string(obj.tableTestCase.TestStep(rowCnt))]),'','Result'};
                            TestStepTable = createHeaderForTable(obj,headerRowTitle,columnWidth,false);
                            SectionName = ['Test Case: ',string(obj.tableTestCase.TestCase(rowCnt))];
                            newSection = Section('Title',SectionName,'Content',TestStepTable);
                            newSection.LinkTarget = obj.testCaseHyperlinkText{TestCaseTableCounter};
                            testCaseStartRow = TestCaseStartRowIdx(TestCaseCounter);
                            testCaseEndRow = TestCaseStartRowIdx(min(TestCaseCounter+1,length(TestCaseStartRowIdx)));
                            TestStepCount = 1;
                            addTestCaseInputs(obj,testCaseStartRow,testCaseEndRow,rowCnt,ResultIcon,TestStepTable,TestStepCount);

                        elseif ismissing(obj.tableTestCase.TestCase(rowCnt))&&~ismissing(obj.tableTestCase.TestStep(rowCnt)) %New Test Step
                            %get the row number where the test step was found
                            headerRowTitle = {char(["Test Step: ",string(obj.tableTestCase.TestStep(rowCnt))]),'','Result'};
                            TestStepTable = createHeaderForTable(obj,headerRowTitle,columnWidth,false);
                            TestStepCount = TestStepCount + 1;
                            addTestCaseInputs(obj,testCaseStartRow,testCaseEndRow,rowCnt,ResultIcon,TestStepTable,TestStepCount)
                        else
                            tableEntries = {string(obj.tableTestCase.Verify_Statement(rowCnt)),...
                                            ResultIcon,string(obj.tableTestCase.Result(rowCnt))};
                            appendNewRowToTable (obj,TestStepTable,tableEntries,rowCnt,false);
                        end

                        if endOfTestCase(obj,rowCnt,numberOfRows)
                            TestCaseCounter = TestCaseCounter + 1;
                            TestCaseTableCounter = TestCaseTableCounter + 1;
                            appendFailedResultsRows(obj,TestStepTable,failedResults);
                            failedResults = {};
                            if(TestStepCount>1)
                                add(newSection,TestStepTable); 
                            end
                            add(testCaseSection,newSection);
                            add(testCaseSection,InternalLink(['TestDescription_',char(sprintf("%d",obj.HarnessIndex))],'Go back to Test Description'));     
                        elseif endOfTestStep(obj,rowCnt,numberOfRows)

                            appendFailedResultsRows(obj,TestStepTable,failedResults);
                            failedResults = {};
                            if(TestStepCount>1)
                                add(newSection,TestStepTable); 
                            end
                        end            
                    end 
                    add(obj.testCaseSummaryChapter,testCaseSection);
                catch ME
                    obj.setErrorMessage(ME);
                end
            end
        end 
        
        function endOfTC = endOfTestCase(obj,rowIdx,endOfTable)
            if ~obj.testReportError && ~obj.testHarnessError
                endOfTC = false;
                if ~ismissing(obj.tableTestCase.TestCase(min(rowIdx+1,endOfTable))) || rowIdx == endOfTable
                    endOfTC = true;
                end  
            else
                endOfTC = false;
            end
        end
        
        function endOfTS = endOfTestStep(obj,rowIdx,endOfTable)
            if ~obj.testReportError && ~obj.testHarnessError
                endOfTS = false;
                if ismissing(obj.tableTestCase.TestCase(min(rowIdx+1,endOfTable)))&&...
                   ~ismissing(obj.tableTestCase.TestStep(min(rowIdx+1,endOfTable)))
                    endOfTS = true;
                end 
            else
                endOfTS = false;
            end
        end
        
        function addTestCaseInputs(obj,tcStartRow,tcEndRow,rowIdx,resultIcon,testStepTable,testStepCounter)
            if ~obj.testReportError && ~obj.testHarnessError
                try
                      inputArray = getTestCaseInputs(obj,tcStartRow,tcEndRow);
                      tableEntries = {'Inputs:','',''};
                      appendNewRowToTable (obj,testStepTable,tableEntries,rowIdx,true);
                      %get the test inputs 
                      appendInputsToTable(obj,testStepTable,inputArray{min(testStepCounter,length(inputArray))});
                      tableEntries = {'Expected Results:','',''};
                      appendNewRowToTable (obj,testStepTable,tableEntries,rowIdx,true)
                      tableEntries = {string(obj.tableTestCase.Verify_Statement(rowIdx)),...
                                      resultIcon,string(obj.tableTestCase.Result(rowIdx))};
                      appendNewRowToTable (obj,testStepTable,tableEntries,rowIdx,false);
                catch ME
                    obj.setErrorMessage(ME);
                end     
            end
        end
        
        function appendFailedResultsRows(obj,myTable,failedResults)
            if ~obj.testReportError && ~obj.testHarnessError
                if length(failedResults)
                    TableEntries = {"Actual Results:","",""};
                    appendNewRowToTable (obj,myTable,TableEntries,2,true);
                end
                for entryCount = 1: length(failedResults)
                    TableEntries = {failedResults{entryCount},"",""};
                    appendNewRowToTable (obj,myTable,TableEntries,entryCount,false);
                end
            end
        end
        
        function appendNewRowToTable (obj,myTable,TableEntries,rowIdx,isHeaderRow)
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    newRow = TableRow();
                    if mod(rowIdx,2)
                       newRow.Style = {BackgroundColor('white'),Border('single'),VAlign('middle')};
                    else
                       newRow.Style = {BackgroundColor('#d8e6ff'),Border('single'),VAlign('middle')};
                    end
                    if isHeaderRow
                       newRow.Style= {BackgroundColor('steelblue'),Border('single'),Bold,FontFamily('Times New Roman'),...
                                      FontSize('9pt'),ResizeToFitContents(false),Color('white')};
                    end

                    for entryCount = 1: length(TableEntries)
                        if ~isempty(obj.signalBuilderBlock)&&strcmp(TableEntries{entryCount},obj.signalBuilderBlock)
                            te = TableEntry();
                            Hp = InternalLink(obj.signalBuilderBlock,TableEntries{entryCount});
                            append(te,Hp);
                        else
                            te = TableEntry(TableEntries{entryCount});
                        end
                        if(entryCount==1)
                            te.Style= {InnerMargin('0.1in', '0.1in')};
                        elseif(entryCount==2)
                            te.Style= {HAlign('right')};
                        end

                        append(newRow,te);
                    end
                    append(myTable,newRow);
                catch ME
                    obj.setErrorMessage(ME);
                end   
            end
        end
        
        function appendInputsToTable(obj,testTable,InputData)
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                InputDataArray = split(InputData,newline);
                for inputIdx = 1:length(InputDataArray)
                    tableEntries = {InputDataArray{inputIdx},'',''};
                    appendNewRowToTable (obj,testTable,tableEntries,inputIdx,false);
                end 
            end
        end
        
        
        function inputTestArray= getTestCaseInputs(obj,startRow,endRow)
            if ~obj.testReportError && ~obj.testHarnessError
                inputData = "";
                calData = "";
                InputDataCount = 1;
                for rowIdx = startRow:endRow
                     if strcmp(obj.xlsxData(rowIdx,3),"Set Model Inputs") 
                            if notEmptyCell(obj,obj.xlsxData(rowIdx,4)) 
                                inputData = obj.xlsxData(rowIdx,4);
                            end
                     elseif strcmp(obj.xlsxData(rowIdx,3),"Set Parameters")
                            if notEmptyCell(obj,obj.xlsxData(rowIdx,4))  
                                calData = obj.xlsxData(rowIdx,4);
                            end
                     elseif strcmp(obj.xlsxData(rowIdx,3),"Verify")
                            if notEmptyCell(obj,obj.xlsxData(rowIdx,4))
                                %inputTestArray = split(strcat(inputData,sprintf("\n"),calData),newline);
                                inputTestArray(1,InputDataCount) = strcat(inputData,sprintf("\n"),calData);
                                inputData = "";
                                calData = "";
                                InputDataCount = InputDataCount +1;
                            end
                     end
                end
            end
        end
        
        function notEmpty = notEmptyCell(obj,cellText)
            if ~obj.testReportError && ~obj.testHarnessError
                notEmpty = false;
                if ~strcmp(cellText,"") && ~strcmp(cellText,"0")&& ~ismissing(cellText)
                            notEmpty = true;
                end
            else
                notEmpty = false;
            end
        end
        
        function newTable = createOverallSummaryTable(obj)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    [numberOfRows numberOfColumns] = size(obj.tableSummary);
                    newTable = FormalTable(numberOfColumns);
                    headerRowTitle = {'Total Test Cases','Untested','Passed','Failed'};
                    columnWidth = {'1.5in','0.8in','0.8in','0.8in'};
                    newTable = createHeaderForTable(obj,headerRowTitle,columnWidth,true);  
                    rowEntries = {removeUnicodeCharacters(obj, obj.tableSummary.Total_Test_Cases(1)),...
                                removeUnicodeCharacters(obj, obj.tableSummary.Untested(1)),...
                                removeUnicodeCharacters(obj, obj.tableSummary.Passed(1)),...
                                removeUnicodeCharacters(obj, obj.tableSummary.Failed(1))};
                    newRow = createNewRow(obj,rowEntries,1,'TCSummary',false);
                    newRow.Style = {Border('single'),ColSep('single'),FontFamily('Times New Roman'),FontSize('9pt'),ResizeToFitContents(true),HAlign('center')};
                    append(newTable,newRow);
                catch ME
                    obj.setErrorMessage(ME);
                end   
            else
                newTable = FormalTable();
            end
        end
		
		function newString = removeUnicodeCharacters(obj,myString)
            if ~obj.testReportError && ~obj.testHarnessError
                newString = regexprep(string(myString),'[^a-zA-Z0-9._%]','');
            else
                newString = '';
            end
		end
        
        function newTable = createMergedOverallSummaryTable(obj)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    [numberOfRows numberOfColumns] = size(obj.tableSummary);
                    newTable = FormalTable(numberOfColumns);
                    headerRowTitle = {'Total Test Cases','Untested','Passed','Failed'};
                    columnWidth = {'1.5in','0.8in','0.8in','0.8in'};
                    newTable = createHeaderForTable(obj,headerRowTitle,columnWidth,true);  
                    rowEntries = {removeUnicodeCharacters(obj, obj.mergedTestSummaryData(1)),...
                                  removeUnicodeCharacters(obj, obj.mergedTestSummaryData(2)),...
                                  removeUnicodeCharacters(obj, obj.mergedTestSummaryData(3)),...
                                  removeUnicodeCharacters(obj, obj.mergedTestSummaryData(4))};
                    newRow = createNewRow(obj,rowEntries,1,'TCSummary',false);
                    newRow.Style = {Border('single'),ColSep('single'),FontFamily('Times New Roman'),FontSize('9pt'),ResizeToFitContents(true),HAlign('center')};
                    append(newTable,newRow);
                catch ME
                    obj.setErrorMessage(ME);
                end  
            else
                newTable = FormalTable();
            end
        end

        function newTable = createTestCaseSummaryTable(obj)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    [numberOfRows numberOfColumns] = size(obj.tableTestCaseDescription);
                    newTable = FormalTable(numberOfColumns);
                    obj.HyperlinkIdx = length(obj.testCaseHyperlinkText)+1;
                    headerRowTitle = {'Test Case Name','Description','','Result'};
                    columnWidth = {'3in','2.8in','0.3in','0.4in'};
                    newTable = createHeaderForTable(obj,headerRowTitle,columnWidth,true);  
                    for i = 1:numberOfRows

                        rowEntries = {obj.tableTestCaseDescription.TestCaseName(i),obj.tableTestCaseDescription.Description(i),...
                        obj.tableTestCaseDescription.Result(i)};
                        newRow = createTestCaseSummaryRow(obj,rowEntries,length(obj.testCaseHyperlinkText)+1,'TCSummary',1);
                        append(newTable,newRow);
                    end
                catch ME
                    obj.setErrorMessage(ME);
                end  
            else
                newTable = FormalTable();
            end
        end
        
        function newRow = createTestCaseSummaryRow(obj,rowEntries,rowCounter,hiperlinkText,HlinkEnable)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            newRow = TableRow();
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    if~(mod(rowCounter,2))
                        %newRow.Style = {BackgroundColor('#d8e6ff'),Border('single'),ColSep('single'),FontFamily('Times New Roman'),FontSize('8pt'),ResizeToFitContents(true), Color('black')};
                        newRow.Style = {BackgroundColor('#d8e6ff'),Border('single'),FontFamily('Times New Roman'),FontSize('8pt'),ResizeToFitContents(true), Color('black'),VAlign('middle')};
                    else
                        %newRow.Style = {BackgroundColor('white'),Border('single'),ColSep('single'),FontFamily('Times New Roman'),FontSize('8pt'),ResizeToFitContents(true), Color('black')};
                        newRow.Style = {BackgroundColor('white'),Border('single'),FontFamily('Times New Roman'),FontSize('8pt'),ResizeToFitContents(true), Color('black'),VAlign('middle')};
                    end
                    tableEntryResult = addHiperlink(obj,hiperlinkText,rowCounter,char(rowEntries{3}));
                    %tableEntryResult.Style = {};
                    TestCaseNameEntry = TableEntry(char(rowEntries{1}));
                    TestCaseNameEntry.Style ={InnerMargin('0.1in', '0.1in'),ColSep('single','black')};
                    append(newRow,TestCaseNameEntry);
                    descriptionEntry = TableEntry(char(rowEntries{2}));
                    descriptionEntry.Style ={InnerMargin('0.1in', '0.1in'),ColSep('single','black')};
                    append(newRow,descriptionEntry);
                    if strcmp(string(rowEntries{3}),'Passed')
                       iconEntry = TableEntry(getPassIcon(obj));
                    else
                       iconEntry = TableEntry(getfailIcon(obj));
                    end
                    iconEntry.Style = {HAlign('right')};
                    append(newRow,iconEntry);
                    append(newRow,tableEntryResult); 
                catch ME
                    obj.setErrorMessage(ME);
                end  
            end
        end
        
        function tableEntry = addHiperlink(obj,hiperlinkTextName,hiperlinkTextCount,hiperlinkTextText)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            tableEntry =TableEntry();
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    obj.testCaseHyperlinkText{hiperlinkTextCount} = sprintf('%s_%d',hiperlinkTextName,hiperlinkTextCount);
                    Hp = InternalLink(sprintf('%s_%d',hiperlinkTextName,hiperlinkTextCount),hiperlinkTextText);
                    append(tableEntry,Hp);
                catch ME
                    obj.setErrorMessage(ME);
                end  
            end
        end
        
        function newRow = createNewRow(obj,rowEntries,rowCounter,hiperlinkText,HlinkEnable)
            import mlreportgen.report.*
            import mlreportgen.dom.*

            newRow = TableRow();
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    if~(mod(rowCounter,2))
                        newRow.Style = {BackgroundColor('#d8e6ff'),Border('single'),ColSep('single'),FontFamily('Times New Roman'),FontSize('9pt'),ResizeToFitContents(true), Color('black')};
                    else
                        newRow.Style = {BackgroundColor('white'),Border('single'),ColSep('single'),FontFamily('Times New Roman'),FontSize('9pt'),ResizeToFitContents(true), Color('black')};
                    end
                    for i = 1:length(rowEntries)
                        if ~ismissing(rowEntries{i})
                            te =TableEntry(char(rowEntries{i}));
                            if (strcmp(string(rowEntries{i}),'Failed')||strcmp(string(rowEntries{i}),'Passed')) && HlinkEnable
                                te =TableEntry();
                                obj.testCaseHyperlinkText{rowCounter} = sprintf('%s_%d',hiperlinkText,rowCounter);
                                Hp = InternalLink(sprintf('%s_%d',hiperlinkText,rowCounter),char(rowEntries{i}));
                                append(te,Hp);
                            end
                            if(i==1)
                               te.Style= {InnerMargin('0.1in', '0.1in')};
                            end
                        else
                            te =TableEntry('');
                        end 
                        append(newRow,te);
                    end    
                catch ME
                    obj.setErrorMessage(ME);
                end  
            end
        end

        function newTable = createHeaderForTable(obj,headerNames,columnWidth,alignTextToCenter)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    newTable = FormalTable(length(headerNames));
                    if alignTextToCenter
                        newTable.Header.Style = {BackgroundColor('steelblue'),Bold,Border('single'),...
                                            FontFamily('Times New Roman'),FontSize('9pt'),ResizeToFitContents(true),...
                                            Color('white'),HAlign('center')};
                         newTable.Style = {FontFamily('Times New Roman'),FontSize('9pt'),ResizeToFitContents(true),...
                                        Color('black'),VAlign('middle')};  
                    else
                        newTable.Header.Style = {BackgroundColor('steelblue'),Bold,Border('single'),...
                                            FontFamily('Times New Roman'),FontSize('9pt'),ResizeToFitContents(true),...
                                            Color('white')};

                        newTable.Style = {FontFamily('Times New Roman'),FontSize('9pt'),ResizeToFitContents(true),...
                                        Color('black'),Width('6.6in'),VAlign('middle')};  
                    end               

                    headerRow = TableRow();
                    for i = 1: length(headerNames)
                        colEntry = TableEntry(headerNames{i});
                        if(i==1)
                            colEntry.Style= {Width(columnWidth{i}),InnerMargin('0.1in', '0.1in')};
                        else
                            colEntry.Style = {Width(columnWidth{i})};
                        end
                        %colEntry.Style = {ColSep('single','white')};
                        append(headerRow,colEntry);
                    end
                    appendHeaderRow(newTable,headerRow);    
                catch ME
                    obj.setErrorMessage(ME);
                end  
            end
        end

        function  createMainPage(obj,Report)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    %Add Title page
                    reportTitle=TitlePage();
                    title = Paragraph([obj.subsystemName,' Test Report']);
                    title.Style = {Bold,FontFamily('Times New Roman'),HAlign('center'),FontSize('24pt')};
                    reportTitle.Title = title;

                    %Add Eaton Logo to main page
                    reportTitle.Image = fullfile([obj.Error.scriptFolder,'\EatonLogo.png']);
                    author = Paragraph('Author: Eaton');
                    author.Style = {Bold,FontFamily('Times New Roman'),HAlign('center'),FontSize('14pt')};
                    reportTitle.Author = author;
                    %Add date
                    reportTitle.PubDate = date();
                    add(Report,reportTitle);
                 catch ME
                     obj.setErrorMessage(ME);
                 end  
            end
        end

        function createTableOfContents(obj,Report)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    %Add table of content
                    toc = TableOfContents;
                    toctitle = Paragraph('Table of Contents');
                    toctitle.Style = {Bold,FontFamily('Times New Roman'),HAlign('left'),FontSize('18pt')};
                    toc.Title = toctitle;
                    add(Report,toc);
                 catch ME
                     obj.setErrorMessage(ME);
                 end  
            end
        end
        
        function passIcon = getPassIcon(obj)
             import mlreportgen.dom.*
             try
                 %create an image object for the icon
                 passIcon =Image(fullfile([obj.Error.scriptFolder,'\Icons\ResultsStatusIconPassed.png']));
             catch ME
                 obj.setErrorMessage(ME);
             end  
        end

        function failIcon = getfailIcon(obj)
             import mlreportgen.dom.*
             try
                 %create an image object for the icon
                 failIcon =Image(fullfile([obj.Error.scriptFolder,'\Icons\ResultsStatusIconFailed.png']));
             catch ME
                 obj.setErrorMessage(ME);
             end  
        end
        
        function setErrorMessage(obj,ME)
			obj.Error.ME = ME;
            obj.testReportError = true;
        end
        
        function [excelFile Group] = getSignalBuilderInputs(obj)
            if ~obj.testReportError && ~obj.testHarnessError
                try
                    text = split(obj.signalBuilderBlock,'_');
                    excelFile = text{1};
                    Group = str2num(extractAfter(text{3},'Group'))+1;
                catch  ME
                    Msg = strcat('Test Report - File to be imported to signal builder could not be found,',...
                                      '\nPlease check that test case template has the right input.');
                    obj.setErrorMessage(ME,Msg);
                end
            else
                excelFile = '';
                Group = 0;
            end
       end    
        
       function getSignalBuilderSnapshot(obj)
            import mlreportgen.report.*
            import mlreportgen.dom.*
            
           if ~obj.testReportError && ~obj.testHarnessError
               try
                    if ~isempty(obj.signalBuilderBlock)
                        newSection = Section('Title',obj.signalBuilderBlock);
                        [inputFile,configstruct.groupIndex] = getSignalBuilderInputs(obj);
                        [time, data, signames, groupnames] = signalbuilder([obj.testHarnessName,'/Harness Inputs']);
                        if ~exist([obj.Path,'\Snapshots'])
                            mkdir([obj.Path,'\Snapshots']);
                        end
                        for ii = 1:length(signames)
                            %Capture snapshot of every signal in signal
                            %builder block
                            configstruct.showTitle=false;
                            configstruct.visibleSignals = ii;
                            snapshotFig = signalbuilder([obj.testHarnessName,'/Harness Inputs'],'print',configstruct,'figure');
                            print(snapshotFig, '-dpng', [obj.Path,'\Snapshots\',obj.testHarnessName,'Signal_',signames{ii}]);
                            Snapshot = Image(fullfile([obj.Path,'\Snapshots\',obj.testHarnessName,'Signal_',signames{ii},'.png']));
                            Snapshot.Height = '2.5in';
                            Snapshot.Width = '6.5in';
                            newTable = FormalTable({Snapshot});
                            newTable.Style = {Width('6.5in'),Height('2.5in')};
                            add(newSection,newTable)
                        end
                        newSection.LinkTarget = obj.signalBuilderBlock;
                        add(obj.signalBuilderChapter,newSection);
                        add(obj.signalBuilderChapter,InternalLink([obj.testHarnessName,'- TEST CASES'],['Go back to ',...
                                                                  [obj.testHarnessName,'- TEST CASES']])); 
                    end
                catch  ME
                    Msg = strcat('Test Report - Unable to get snapshot from signal builder block');
                    obj.setErrorMessage(ME,Msg);
                end
           end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    end
end