classdef XMLFileGeneration < handle
    properties
        xmlObj
        signalBuilderGroupActive
        xlsxData
        xmlError
        ignoreFile
        Error = UnitTestError
    end
    methods
        % This function creates a xml file from an Excel file and return the xml object
        function Convert_xlsx_to_xml(obj,fileName)
            try
                obj.Error.Category = '***Xml Generation Error***';
                [numData,txtData,rawData] = xlsread(fileName);
                %convert data to strings
                obj.xlsxData = string(rawData);
                %Create a document node and define the root element by calling this method
                docNode = com.mathworks.xml.XMLUtils.createDocument('Root');
                %Create xml nodes
                createNodes(obj,docNode,obj.xlsxData);
                %Save xml file with the name of the excelfile_TestCases.xml
                [found row column] = obj.findString(obj.xlsxData,'TestHarnessName');
                obj.ignoreFile = ~found;
                if found
                    xmlFileName=obj.xlsxData(row,column+1);
                    xmlwrite(xmlFileName,docNode);
                    %read the created xml file and return it as a xml object.
                    obj.xmlObj = xmlread(xmlFileName);
                end
            catch ME
                obj.xmlError = true;
                Msg = strcat('Unable to create xml file : "', xmlFileName,'.xml"',...
                              '\nPossible reasons:',...
                              '\n- TestHarnessName not found in file: ',fileName,...
                              '\n- TestHarnessName contains special characters'); 
                setErrorMessage(obj,ME,Msg)
            end
        end 
    end
    methods (Access = private)  
        function createNodes(obj,docNode,data)
            %Get the node corresponding to the root element
            Root = docNode.getDocumentElement;
            %Create the top level nodes
            createMainNodes(obj,Root,docNode,data); 
        end
        
        function createMainNodes(obj,Root,docNode,data)
            %Define the name of the top level nodes
            Main_Nodes = {'ModelName','SubsystemPath','TestHarnessName'...
                         ,'SimulationTime','LocalVariables','TestSequences'}; 
            for i = 1: length(Main_Nodes)
                %create the top level nodes  
                TopNode = docNode.createElement(Main_Nodes(i));
                [found row column] = obj.findString(data,Main_Nodes(i));
                if found
                   %Add text content if exist to the nodes 
                   TopNode.appendChild(docNode.createTextNode(data(row,column+1)));
                end
                %append the nodes to the root node 
                Root.appendChild(TopNode);
            end
            %Create Test level nodes
            createTestNodes(obj,Root,docNode,data,TopNode);
        end
        
        function createTestNodes(obj,Root,docNode,data,TopNode)
            %Define Test level nodes names
            Test_Nodes = {'Test','TopLevel','Step'};
            %look for the rows and columns of the Test and Test Steps names 
            [resultTN rowTN TCColumn] = obj.findString(data,'Tests Name');
            [resultSN rowSN columnSN] = obj.findString(data,'Step Name');
            %Find the rows and columns where each test case starts
            [TCRow TCColumn] = obj.findTestCases(data);
            for i= 1:length(TCRow)-1
                %Create test node
                TestNode = docNode.createElement('Test');
                TopNode.appendChild(TestNode);
                StepN = 1;
                %Look for test steps , starting from the current
                %test case starts till where the next test case starts
                for j = TCRow(i): TCRow(i+1)
                    %Look for test steps
                    if ~ismissing(data(j,columnSN))
                        if(StepN==1)
                            %First test step is named TopLevel
                            Node = docNode.createElement('TopLevel');
                            TestNode.appendChild(Node);
                        else
                            if data(j,columnSN) == 'TestSetup_Defaults'
                                break;
                            else
                            %subsequent test steps are named Step
                                 Node = docNode.createElement('Step');
                                 TestNode.appendChild(Node);
                            end
                        end
                        %create nodes for each test step
                        createStepNodes(obj,docNode,Node,data,j,StepN);
                        StepN = StepN+1;
                    end    
                end 
            end
        end
        
        function createStepNodes(obj,docNode,testNode,data,stepRow,StepN)
            %Define Test Step node names
            Step_Nodes = {'Name','Actions','Description','Transition'};  
            for i = 1:length(Step_Nodes)
                %create test step nodes
                stepNode = docNode.createElement(Step_Nodes(i));
                if strcmp(Step_Nodes(i),'Name')
                    if StepN == 1
                        %text content of the first test step is the name of the
                        %test case instead of TestSetup_Defaults
                        stepNode.appendChild(docNode.createTextNode(data(stepRow,1)));   
                    else
                        %subsequents text content is the name of the test step 
                        stepNode.appendChild(docNode.createTextNode(data(stepRow,2)));
                    end
                elseif strcmp(Step_Nodes(i),'Actions')
                    %create actions nodes of current the test step
                    CreateActionsNodes(obj,docNode,data,stepNode,stepRow);
                elseif strcmp(Step_Nodes(i),'Description')
                    %Add text content for Description node
                    stepNode.appendChild(docNode.createTextNode(data(stepRow,4)));  
                else
                    %create transition nodes (Condition/NextStep)
                    createTransitionNodes(obj,docNode,data,stepNode,stepRow,StepN);
                end
                testNode.appendChild(stepNode);
            end
        end       
        
        function CreateActionsNodes(obj,docNode,Data,stepNode,StepRowN)
            %Define Action node names
            Action_Nodes = {'SetInput','SetParam','SetLocalVar','Verify'};
            %Look for the row and column where the Actions are
            [found row column] = obj.findString(Data,'Actions');
            for i = 1: length(Action_Nodes)
                  %check that the cell has actual text content
                  if ~ismissing(Data(StepRowN+i,column+1))  
                      %split the text content divided by new line ('\n') and
                      %create an action node for each action
                      lookForActionsInTheCell(obj,docNode,stepNode,Data(StepRowN+i,column+1),Action_Nodes(i));
                  end
            end
        end

        function createTransitionNodes(obj,docNode,data,stepNode,StepRowN,StepN)
			% Get the names of the test steps and the rows where they begin	
            [Steps StepRows] = obj.findSteps(data);
			% Look for the column where Transition Conditions are
            [found row column] = obj.findString(data,'Transition Condition');
			%Iterate on every test steps looking for transition conditions and next steps
            for i = 1:length(StepRows)-1
                if StepRowN == StepRows(i)
                    if ~ismissing(data(StepRowN,column))
						% Transition condition found,create a node for it and add text content from data
                        node = docNode.createElement('Condition');
                        node.appendChild(docNode.createTextNode(data(StepRowN,column)));
						% Append condition node to transition node
                        stepNode.appendChild(node);
                    end
                    for j = i+1:length(StepRows)
						%looking for the row where the next test case begins
                        if strcmp(Steps(j),'TestSetup_Defaults')
                            break
                        end
                    end
					%Create NextStep node
                    node = docNode.createElement('NextStep');
                    if(StepN==1)
                        if ~ismissing(data(StepRowN,column))
							%First step defines the transition condition to the next test case
                            node.appendChild(docNode.createTextNode(data(StepRows(j),1)));
                            stepNode.appendChild(node);
                        end
                    else
                        if ~ismissing(data(StepRowN,column))
							%Subsequent steps define transition to the next step
                            node.appendChild(docNode.createTextNode(data(StepRows(i+1),2)));
                            stepNode.appendChild(node);
                        end
                    end
                end
            end
        end

        function lookForActionsInTheCell(obj,docNode,stepNode,text,node_name)
            %Split the text content of the cell into strings separated by new line ('\n')
            cell_strings = strsplit(text,'\n');
            %Add new child node to parent node for each string found in the cell
            for i = 1:length(cell_strings)
				%Check for empty strings
                if ~strcmp(cell_strings(i),"") && ~strcmp(cell_strings(i),"0")
                    %create action node and append it to the step node
                    actionNode= docNode.createElement(node_name);
                    %if inputs comes from signal builder , do nothing
                    if strcmp(node_name,'SetInput')&&contains(cell_strings(i),'_SignalBuilder_')
                        obj.signalBuilderGroupActive = char(cell_strings(i));
                        actionNode.appendChild(docNode.createTextNode(strcat('%',cell_strings(i))));
                    else
                        actionNode.appendChild(docNode.createTextNode(cell_strings(i)));
                    end 
                    stepNode.appendChild(actionNode);
                end
            end
        end
        
        function setErrorMessage(obj,ME,errorMsg)
			obj.Error.ME = ME;
            obj.xmlError = true;
            obj.Error.appendErrorText(errorMsg);
		end
    end
    
    methods (Static,Access = private) 
        function [found x y]= findString(data,strtofind)
			%Get the size of the data
            [NumRows NumColumns]=size(data);
            found = false;
			%Look for the string in the data
            for x = 1: NumRows
                for y = 1: NumColumns
                    if strcmp(data(x,y),strtofind)
                        found = true;
                        return
                    end
                end
            end
        end
        
        function [Steps StepRows] = findSteps(data)
            [data_rows data_columns] = size(data);
			%look for the column where the step names are
            [found row StepColumn] = XMLFileGeneration.findString(data,'Step Name');
            Step_Idx = 1;
            if found
                for i = row+1:data_rows
                    if ~ismissing(data(i,StepColumn))
						%save the step names in Steps
                        Steps(Step_Idx)=data(i,StepColumn);
						%save the rows where the step begins
                        StepRows(Step_Idx) = i;
                        Step_Idx = Step_Idx + 1;
                    end
                end  
            end
            Steps(Step_Idx)= data_rows;
        end    
        
        function [TCRow TCColumn] = findTestCases(data)
			%Get the size of the data
            [rows columns] = size(data);
			%Look for Test Name column
            [resultTN rowTN TCColumn] = XMLFileGeneration.findString(data,'Tests Name');
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
        end    
    end
    
end