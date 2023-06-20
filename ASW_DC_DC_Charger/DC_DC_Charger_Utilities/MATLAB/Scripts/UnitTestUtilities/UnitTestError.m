classdef UnitTestError < handle
    properties
        Msg
        Category
        ME
        scriptFolder = fileparts(which('UnitTestFactory.m'))
    end
    methods (Access = {?XMLFileGeneration,?TestHarnessGeneration,?TestReportGeneration,?UnitTestFactory})
       function logErrors(obj)
            %sldiagviewer.diary([obj.scriptFolder,'\UnitTest_ErrorLog.txt'])
            fid=fopen([obj.scriptFolder,'\UnitTest_ErrorLog.txt'],'a');
            %fprintf(fid,[obj.Category,'\n']);
            Msg_Text = split(obj.Msg,newline);
            for ii=1:length(Msg_Text)
                if isempty(Msg_Text{ii})
                else
                    fprintf(fid,[Msg_Text{ii},'\n']);
                end
            end
            fclose(fid);
       end
       
       function appendErrorText(obj,text)
            fid=fopen([obj.scriptFolder,'\UnitTest_ErrorLog.txt'],'a');
            fprintf(fid,['#########ERROR#######','\n']);
            Msg_Text = split(text,newline);
            for ii=1:length(Msg_Text)
                if isempty(Msg_Text{ii})
                else
                    fprintf(fid,[Msg_Text{ii},'\n']);
                end
            end
            fclose(fid);
       end 
       
       function addTextToFile(obj,text)
            fid=fopen([obj.scriptFolder,'\UnitTest_ErrorLog.txt'],'a');
            Msg_Text = split(text,newline);
            for ii=1:length(Msg_Text)
                if isempty(Msg_Text{ii})|| strcmp(Msg_Text{ii},sprintf('\r'))
                else
                    fprintf(fid,[Msg_Text{ii},'\n']);
                end
            end
            fclose(fid);
       end 
       function deleteLogErrorFile(obj)
           delete([obj.scriptFolder,'\UnitTest_ErrorLog.txt']);
       end
    end
end