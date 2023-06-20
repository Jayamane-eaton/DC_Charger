% ExtractCalibrations Extract Calibrations from individual model simulink 
% data dictionaries and generates a single text file Calibrations.txt
%
%   ExtractCalibrations(rootFolder)
%   Input argument - rootFolder: Root folder path
%   Output: Generate Calibrations.txt file in rootFolder/Build directory
%   
%   eg: in the command window write - 
%   ExtractCalibrations('C:\Users\E0395640\Documents\RTC\M3InverterVFm1BisDev\')
%   
%   The output .txt file will be generated at the topmost folder: eg -
%   \RTC\M3InverterVFm1BisDev.
%   Convert this txt file into .xlsx by setting delimiter to be 'Tab'.
%   Inspect the file and make changes to the excel for formatting the CALs
%   which are arrays.
function ExtractCalibrations(rootFolder)

slddfiles = FindslddFiles(fullfile(rootFolder, 'MBD'));

fid = fopen(fullfile(rootFolder,'Calibrations.txt'),'w+');

fprintf(fid,'Name');
fprintf(fid,'\tDescription');
fprintf(fid,'\tDataType');
fprintf(fid,'\tValue');
fprintf(fid,'\tMin');
fprintf(fid,'\tMax');

for ii=1:length(slddfiles)
    myDictionaryObj = Simulink.data.dictionary.open(string(slddfiles(ii)));
    dDataSectObj = getSection(myDictionaryObj,'Design Data');
    exportToFile(dDataSectObj,'myDictionaryConfigurations.mat')
    
    data=load('myDictionaryConfigurations.mat');
    f=fieldnames(data);
    
    for k=1:size(f,1)
        temp1 = data.(f{k});
        calname = string(f{k});
        if (strcmp(class(temp1),'Simulink.Parameter') && ~(strncmp(calname,'P_',2)) && ~(strncmp(calname,'CONST_',6)))
            fprintf(fid,'\n%s', calname);
            fprintf(fid,'\t%s', string(data.(f{k}).Description));
            fprintf(fid,'\t%s', string(data.(f{k}).DataType));
            if(strcmp(data.(f{k}).DataType, 'Single'))
                fprintf(fid,'\t%f', data.(f{k}).Value);
                fprintf(fid,'\t%f', data.(f{k}).Min);
                fprintf(fid,'\t%f', data.(f{k}).Max);
                
            else
                fprintf(fid,'\t%d', data.(f{k}).Value);
                fprintf(fid,'\t%d', data.(f{k}).Min);
                fprintf(fid,'\t%d', data.(f{k}).Max);
                
            end
        end
    end
end

fclose(fid);


%% Search for files with specific extension in given folder and subfolders
    function [FList] = FindslddFiles(DataFolder)
        
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
        
        extList={'sldd'};
        
        for i=1:numel(DirContents)
            if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
                if(~DirContents(i).isdir)
                    if (length(DirContents(i).name) > 4)
                        extension=DirContents(i).name(end-3:end);
                    end
                    
                    if(numel(find(strcmpi(extension,extList)))~=0)
                        FList=cat(1,FList,{[DataFolder,NameSeperator,DirContents(i).name]});
                    end
                else
                    getlist=FindslddFiles([DataFolder,NameSeperator,DirContents(i).name]);
                    FList=cat(1,FList,getlist);
                end
            end
        end
    end
end



