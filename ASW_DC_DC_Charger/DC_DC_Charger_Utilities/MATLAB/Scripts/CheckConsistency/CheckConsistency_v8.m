
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create the report instance
%Create the import list
import mlreportgen.report.*;
import mlreportgen.dom.*;
%Let's put the report into the separate DIR. 

fileFullPath = mfilename('fullpath');
temp = strsplit(fileFullPath,filesep);
fileDIR = strjoin(temp(1:end - 1),filesep);
baseDIR = uigetdir(fileDIR,'Select project''s ROOT directory');
res = 1;
if ~isfolder(baseDIR)
    disp('Cannot find project''s ROOT directory');
    res = 0;
    return;
end

if(res)
    arxmlDIR = [baseDIR '\Architecture'];
    if ~isfolder(arxmlDIR)
        disp('Cannot find ''\Architecture'' directory');
    return;
    end
    
    scriptsDIR = [baseDIR '\Utilities\MATLAB'];
    if ~isfolder(scriptsDIR)
        disp('Cannot find ''\Utilities\MATLAB'' directory');
    return;
    end
    
    slddMainDIR = [baseDIR '\MBD\Main'];
    if ~isfolder(slddMainDIR)
        disp('Cannot find ''\MBD\Main'' directory');
    return;
    end
    
    modelsDIR = [baseDIR '\MBD'];
    if ~isfolder(modelsDIR)
        disp('Cannot find ''\MBD'' directory');
    return;
    end
end

cd (arxmlDIR);
ARxmlFileList = dir ('**/SWC_*.arxml');
ARxmlFileListNames = {ARxmlFileList(:).name}';
ARxmlFileFolder = {ARxmlFileList(:).folder}';
cd (fileDIR);
addpath(fileDIR, arxmlDIR, slddMainDIR);
addpath(genpath(modelsDIR));
addpath(genpath(scriptsDIR));

ARxmlDestDIR = [fileDIR '\ARxmlModels'];
if isfolder(ARxmlDestDIR) %Kill the old files if any
    [sstatus, message, messageid] = rmdir(ARxmlDestDIR, 's');
end
[status, msg, msgID] = mkdir(ARxmlDestDIR); 

Simulink.data.dictionary.closeAll('-discard');
h_mdlExplorer = daexplr;

ARxmlFileListFullNames = strcat(ARxmlFileFolder, '\', ARxmlFileListNames);

for k = 1:length(ARxmlFileListFullNames) %test 3 / ARxmlFileListFullNames
    createSwCFromARXML(char(ARxmlFileListFullNames(k)), char(ARxmlDestDIR));
    bdclose('all');
end

h_mdlExplorer.delete;
bdclose('all');
% return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[status, msg, msgID] = mkdir('Reports'); 
reportsDIR = [pwd '\Reports'];
reportFileName = [reportsDIR '\DV_Report'];

rpt = Report(reportFileName,'HTML-FILE'); %Cloud be PDF but there is a problem with active LINKS
rpt.Layout.PageNumberFormat = 'n';

titPage = TitlePage('Title','M2:M3 – Consistency check', 'Author','IS COE – SWEC');
titPage.PubDate = char(datetime('now'));
add(rpt, titPage);

%Create TOC
toc = TableOfContents();
toc.Layout.PageNumberFormat = 'i';
add(rpt,toc);
%end of report setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Compare sets of New and Old files
%fileToTest = dir ('**/SWC_*.slx');

rootDIR = fileDIR;
selpathNew = ARxmlDestDIR;

cd (selpathNew);
FileListNew = dir ('**/SWC_*.slx');
selpathOld = modelsDIR;

cd (selpathOld);
FileListOld = dir ('**/SWC_*.slx');
cd (rootDIR);

newFilesFullNames = {FileListNew(:).name}';
newFilesNames = newFilesFullNames; %keep Names and Folders in separate DIRs due to necessity to rename files
newFilesFolder = {FileListNew(:).folder}';
oldFilesNames = {FileListOld(:).name}';

addFiles = ismember(newFilesFullNames, oldFilesNames);
[delFiles, location] = ismember(oldFilesNames, newFilesFullNames); %save Location to couple NEW and OLD version of files

newFilesFullNames = strcat({FileListNew(:).folder}', '\', newFilesFullNames);
oldFilesFullNames = strcat({FileListOld(:).folder}', '\', oldFilesNames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Write to report
ch0 = Chapter('Files existence');
parF = Paragraph('Note that models converted from *.ARXML files serve as baseline for this analysis. From this point of view if any of files or blocks are identified as MISSING they are not presented in the baseline');
add(ch0, parF);
parF = Paragraph('When some files/blocks are marked as NEW they are in baseline but have not been found in model development version.');
add(ch0, parF);
parF = Paragraph('Directory with *.ARXML files: ');
parF.Bold = true;    
msg = Text(char(ARxmlFileFolder(1)));
msg.Bold = false;
append(parF, msg);
add(ch0, parF);
parF = Paragraph('Directory with models under development: ');
parF.Bold = true;    
msg = Text(char(selpathOld));
msg.Bold = false;
append(parF, msg);
add(ch0, parF);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Identify a new files
if(~all(addFiles))
    addFileNames = newFilesNames(~addFiles); %Save only new files
    addFilePathNames = newFilesFullNames(~addFiles); %Save only new files
    
    %Write to report
    txtF = Text(['There are ' num2str(size(addFileNames, 1)) ' NEW files:']);
    txtF.Bold = true;
    add(ch0, txtF);    

    toTable = [addFileNames addFilePathNames];
    tablstr = cell2table(toTable, 'VariableNames',{'Model_Name' 'Mode_Full_Path'});
    tf_p = Table(tablstr);
    tf_p.Style = {Border('inset','#5f5f5f','2px'),Width('95%'),OuterMargin('0px','0px','20px','0px')};
    tf_p.TableEntriesInnerMargin = '6pt';
    tf_p.Border = 'solid';
    tf_p.TableEntriesStyle = {HAlign('left')};
    tf_p.row(1).Style = {Bold(),HAlign('center')};
    
    for i=2:2:(size(addFileNames, 1) + 1)
        tf_p.Children(1,i).Style = {BackgroundColor('#f5f5f5')};
    end

    add(ch0,tf_p);
end
   
%Identify deleted files
leftNameList = oldFilesFullNames;
if(~all(delFiles))
    delFileNames = oldFilesNames(~delFiles); %Save only deleted files
    delFilePathNames = oldFilesFullNames(~delFiles); %Save only deleted files
    
    %Write to report
    txtF = Text(['There are ' num2str(size(delFileNames, 1)) ' MISSING files:']);
    txtF.Bold = true;
    add(ch0, txtF);
       
    toTable = [delFileNames delFilePathNames];
    tablstr = cell2table(toTable, 'VariableNames',{'Model_Name' 'Model_Full_Path'});
    tf_p = Table(tablstr);
    tf_p.Style = {Border('inset','#5f5f5f','2px'),Width('95%'),OuterMargin('0px','0px','20px','0px')};
    tf_p.TableEntriesInnerMargin = '6pt';
    tf_p.Border = 'solid';
    tf_p.TableEntriesStyle = {HAlign('left')};
    tf_p.row(1).Style = {Bold(),HAlign('center')};
    
    for i=2:2:(size(delFileNames, 1) + 1)
        tf_p.Children(1,i).Style = {BackgroundColor('#f5f5f5')};
    end

    add(ch0,tf_p);
    
    leftNameList = oldFilesFullNames(delFiles); %for following comparision let's select only new versions of existing files
    leftModelList = oldFilesNames(delFiles);
    location = location(delFiles); %save Location to couple NEW and OLD version of files
end

%Prepare DIR to save tmporarily NEW files versions /Simulink cannot handle
%models with the same names evenif there are placed in separate DIRs/

tempDIR = [pwd '\Reports\Temporary'];
if isfolder(tempDIR) %Kill the old files if any
    [sstatus, message, messageid] = rmdir(tempDIR, 's');
end
[status, msg, msgID] = mkdir(tempDIR); 

newFilesNames = newFilesNames(location); %Save only those files which have OLD versions
newFilesTmp = regexprep(newFilesNames, '.slx', '_.slx'); %rename
newFilesFolder = newFilesFolder(location); %original folder

for K = 1 : length(newFilesTmp) %remove
    copyfile( fullfile(newFilesFolder{K}, newFilesNames{K}), fullfile(tempDIR, newFilesTmp{K}) );
end

rightNameList = fullfile(tempDIR, newFilesTmp);

%Add Chapter to the report
add(rpt,ch0);
ch1 = Chapter('Check results - Brief');
ch2 = Chapter('Check results - Detailed');
reportCell = cell(size(rightNameList, 1), 6);
for k = 1:size(rightNameList, 1) %loop for all files
    rightName = char(rightNameList(k));
    leftName = char(leftNameList(k));
    
    %Open systems
    handleRight = load_system(rightName);
    handleLeft = load_system(leftName);

    %Prepare report paragraph
    txt = Paragraph(['File name: ' leftName]);
    txt.Bold = true;

    %Search in the root of the model
    [rootCheck, missCell, newCell] = findBlocks(handleRight, handleLeft, ch2, txt);
    tmp = size(missCell, 1); 
    if( size(newCell, 1) > tmp) 
        tmp = size(newCell, 1); 
    end
    rootCell = cell(tmp, 4);
    rootCell(1:size(missCell, 1),1:2) = missCell(:,:);
    rootCell(1:size(newCell, 1),3:4) = newCell(:,:);
    %rootCell = [missCell newCell];

    [missed, added] = countBlocks(handleRight, handleLeft);
    reportCell(k,1) = leftModelList(k); %cellstr(leftName);
    reportCell(k,2) = num2cell(missed);
    reportCell(k,3) = num2cell(added);
    
    %Search inside SYS
    opt = Simulink.FindOptions('SearchDepth',1);
    objectsOld = Simulink.findBlocks(handleLeft, opt);
    objectsNew = Simulink.findBlocks(handleRight, opt);

    blocksOld = get_param(objectsOld, 'Name');   %old file
    blocksNew = get_param(objectsNew, 'Name');   %New file
    blockOldSYS = char(blocksOld(contains(blocksOld, 'sys')));
    objOldSYS = objectsOld(contains(blocksOld, 'sys'));% Search for SYS block in OLD version
    objNewSYS = objectsNew(contains(blocksNew, 'sys'));% Search for SYS block in NEW version
    %in the future -> add comparision of both main blocks names
    
    if(isempty(objOldSYS) || isempty(objNewSYS) )
        disp('there is no main block')
    end
    
    %Write to the report
    if(rootCheck)
        add(ch2, txt);
    end

    txtRoot = Text(['There are differences inside the main block: ' blockOldSYS]);
    txtRoot.Bold = true; 
    
    [sysCheck, missCell, newCell] = findBlocks(objNewSYS, objOldSYS, ch2, txtRoot);
    tmp = size(missCell, 1); 
    if( size(newCell, 1) > tmp) 
        tmp = size(newCell, 1); 
    end
    sysCell = cell(tmp, 4);
    sysCell(1:size(missCell, 1),1:2) = missCell(:,:);
    sysCell(1:size(newCell, 1),3:4) = newCell(:,:);
    %sysCell = [missCell newCell];size(rightNameList, 1)
    tmp = size(sysCell, 1); 
    if( size(rootCell, 1) > tmp) 
        tmp = size(rootCell, 1); 
    end
    resCell = cell(tmp, 8);
    resCell(1:size(rootCell, 1),1:4) = rootCell(:,:);
    resCell(1:size(sysCell, 1),5:8) = sysCell(:,:);    
    
    titCell ={'Block_name'  'Block_type'  'Block_name1'  'Block_type1'  'Block_name2'  'Block_type2'  'Block_name3'  'Block_type3'};
    tblTit = cell2table(titCell);
    
    emptyCells = cellfun('isempty', resCell);
    resCell(emptyCells) = {''};
    tblField = cell2table(resCell);
    
    tempCell = [titCell; resCell];
    
    tblReport = cell2table(resCell, 'VariableNames', titCell);
    r = TableRow;
    te = TableEntry('Root model');
    te.ColSpan = 4;
    append(r, te);
    te = TableEntry('SYS block');
    te.ColSpan = 4;
    append(r, te);
    
    tbl_main = Table();
    append(tbl_main, r);
    r1 = TableRow;
    te = TableEntry('Missed Blocks');
    te.ColSpan = 2;   
    append(r1, te);
    te = TableEntry('New Blocks');
    te.ColSpan = 2;  
    append(r1, te);
    te = TableEntry('Missed Blocks');
    te.ColSpan = 2;
    append(r1, te);
    te = TableEntry('New Blocks');
    te.ColSpan = 2;  
    append(r1, te);
    append(tbl_main, r1);
    
    for j = 1:size(resCell, 1)  
    r1 = TableRow;
        for i = 1:size(resCell, 2)
            te = TableEntry();
            append(te,char(resCell(j,i)));
            append(r1, te);
        end
    append(tbl_main, r1);
    end
    
    tbl_h = Table(tblReport);

    tbl_main.Style = {Border('inset','#5f5f5f','2px'),Width('95%'),OuterMargin('0px','0px','20px','0px')};
    tbl_main.TableEntriesInnerMargin = '6pt';
    tbl_main.Border = 'solid';
    tbl_main.TableEntriesStyle = {HAlign('left')};
    
    
    
    tbl_main.row(1).Style = {Bold(),HAlign('center')};
    tbl_main.row(2).Style = {Bold(),HAlign('center')};
    
    
    for i=2:2:(size(resCell, 1) + 1)
        tbl_main.Children(1,i).Style = {BackgroundColor('#f5f5f5')};
    end
    tbl_main.Children(1,3).Children(1,3).Style = {Border('solid','#000000','16px')};

    %%%%%%%%%%%add(ch1,tbl_main);
    %add(ch1,tbl_h);
    
    
    [missed, added] = countBlocks(objNewSYS, objOldSYS);
    reportCell(k,4) = cellstr(blockOldSYS);
    reportCell(k,5) = num2cell(missed);
    reportCell(k,6) = num2cell(added);
    
    %Write to the report
    if(rootCheck && sysCheck)
        msg = Text(' ..........OK');
        msg.Bold = false;
        append(txt, msg);
        %add(ch, txt);
    end

    close_system(rightName);
    close_system(leftName);
    bdclose;
end %FOR loop

if isfolder(tempDIR) %Kill the old files if any
    [sstatus, message, messageid] = rmdir(tempDIR, 's');
end

    tablstr = cell2table(reportCell, 'VariableNames',{'Model_Name' 'Blocks_MISSING_in_ROOT' 'Blocks_NEW_in_ROOT' 'Main_Block_Name' 'Blocks_MISSING_in_SYSblock' 'Blocks_NEW_in_SYSblock'});
    tf_h = Table(tablstr);
    tf_h.Style = {Border('inset','#5f5f5f','2px'),Width('95%'),OuterMargin('0px','0px','20px','0px')};
    tf_h.TableEntriesInnerMargin = '6pt';
    tf_h.Border = 'solid';
    tf_h.TableEntriesStyle = {HAlign('left')};
    tf_h.row(1).Style = {Bold(),HAlign('center')};
    
    for i=2:2:(size(rightNameList, 1) + 1)
        tf_h.Children(1,i).Style = {BackgroundColor('#f5f5f5')};
    end

    add(ch1,tf_h);
%Add Chapter to the report
add(rpt,ch1);
%Add Chapter to the report

    tablstr = cell2table(reportCell, 'VariableNames',{'Model_Name' 'Blocks_MISSING_in_ROOT' 'Blocks_NEW_in_ROOT' 'Main_Block_Name' 'Blocks_MISSING_in_SYSblock' 'Blocks_NEW_in_SYSblock'});
    tf_h = Table(tablstr);
    tf_h.Style = {Border('inset','#5f5f5f','2px'),Width('95%'),OuterMargin('0px','0px','20px','0px')};
    tf_h.TableEntriesInnerMargin = '6pt';
    tf_h.Border = 'solid';
    tf_h.TableEntriesStyle = {HAlign('left')};
    tf_h.row(1).Style = {Bold(),HAlign('center')};

    

add(rpt,ch2);
%View report. Do not call 'close' method after view, it is closed already.
rptview(rpt);
    
bdclose('all');
return;

%function
function [miss, add] = countBlocks(hRight, hLeft)
    miss = 0;
    add = 0;
  
    opt = Simulink.FindOptions('SearchDepth',1);
    
    %Acquire all blocks handles
    objectsRight = Simulink.findBlocks(hRight, opt);
    objectsLeft = Simulink.findBlocks(hLeft, opt);

    blocksR = get_param(objectsRight, 'Name'); %new file
    blocksL = get_param(objectsLeft, 'Name');  %old file
    %need to check for zero blocks

    LeftRight = ismember(blocksL, blocksR); %Old blocks in New   Do not use CONTAINS
    RightLeft = ismember(blocksR, blocksL); %new blocks added
    
    if(~all(LeftRight))
    
        iLeftRight = ~(LeftRight); %Save only missed blocks
    
        %acquire block type for report
        missBlocksType = get_param((objectsLeft(iLeftRight)), 'BlockType' );
        %block type filter
        filter = ["Ground","Terminator"];
        BlockTypeFilter = contains(missBlocksType, filter);
        missBlocksType = missBlocksType(~BlockTypeFilter);
        miss = size(missBlocksType, 1);
    end
    
    if(~all(RightLeft)) 

        iRightLeft = ~(RightLeft); %Save only additional blocks
    
        %acquire block type for report
        addBlocksType = get_param((objectsRight(iRightLeft)), 'BlockType' );    
        %block type filter
        filter = ["Ground","Terminator"];
        BlockTypeFilter = contains(addBlocksType, filter);
        addBlocksType = addBlocksType(~BlockTypeFilter);
        add = size(addBlocksType, 1);
    end
end

function [res, missCell, newCell] = findBlocks(hRight, hLeft, chapter, par)
%Create the import list
import mlreportgen.report.*;
import mlreportgen.dom.*;

res = 0;
opt = Simulink.FindOptions('SearchDepth',1);

%Acquire all blocks handles
objectsRight = Simulink.findBlocks(hRight, opt);
objectsLeft = Simulink.findBlocks(hLeft, opt);

blocksR = get_param(objectsRight, 'Name'); %new file
blocksL = get_param(objectsLeft, 'Name');  %old file
%need to check for zero blocks

LeftRight = ismember(blocksL, blocksR); %Old blocks in New   Do not use CONTAINS
RightLeft = ismember(blocksR, blocksL); %new blocks added

if(~(all(LeftRight) && all(RightLeft)))
    add(chapter,par);
end

% Let's find which blocks have been deleted
if(~all(LeftRight))
    
    iLeftRight = ~(LeftRight); %Save only missed blocks
    %missBlocksName = char(blocksL(iLeftRight));
    missBlocksName = blocksL(iLeftRight);
    
    %acquire block type for report
    missBlocksType = get_param((objectsLeft(iLeftRight)), 'BlockType' );
    %block type filter
    filter = ["Ground","Terminator"];
    BlockTypeFilter = contains(missBlocksType, filter);
    missBlocksType = missBlocksType(~BlockTypeFilter);
    
    missBlocksName = missBlocksName(~BlockTypeFilter);
    %missBlocksName = char(missBlocksName);
    
    if (size(missBlocksType, 1) > 1) 
        [missBlocksType, Idx] = sort(missBlocksType);
    else
        missBlocksType = cellstr(missBlocksType);
        Idx = 1;
    end
    
    %Write to the report
    par = Paragraph(['There are ' num2str((max(size(missBlocksType)))) ' missed blocks inside the NEW model:']);
    add(chapter,par);
    par = Paragraph('Note that blocks of types: "Ground", "Terminator" were filtered out');
    add(chapter,par);
    
    emptyCell(1:size(missBlocksType, 1)) = par;
    missCell = cell(size(missBlocksType, 1), 2);
    
    for i = 1:size(missBlocksType, 1)
        par = Paragraph('Block type: ');
        par.Bold = true;    
        msg = Text(char(missBlocksType(i)));
        
        missCell(i, 2) = missBlocksType(i);
        
        msg.Bold = false;
        append(par, msg);
        msg = Text(' Block name: ');
        msg.Bold = true;
        append(par, msg);
        %msg = Text(missBlocksName(Idx(i),:));
        msg = Text(char(missBlocksName(Idx(i)) ) );
        
        missCell(i, 1) = missBlocksName(Idx(i));
        
        msg.Bold = false;
        append(par, msg);
        %disp([' Block name: ' missBlocksName(Idx(i),:)]);

        emptyCell(i) = par;
    end
    
    %Add list of all blocks to the report
    if (size(missBlocksType, 1) == 1)
        ol = OrderedList({emptyCell});
    else
        ol = OrderedList(emptyCell);
    end
    add(chapter, ol);    
    clear emptyCell ol;
else
    missCell = {};
end

% Let's find which blocks have been added   
if(~all(RightLeft)) 

    iRightLeft = ~(RightLeft); %Save only additional blocks
    addBlocksName = blocksR(iRightLeft);
    
    %acquire block type for report
    addBlocksType = get_param((objectsRight(iRightLeft)), 'BlockType' );    
    %block type filter
    filter = ["Ground","Terminator"];
    BlockTypeFilter = contains(addBlocksType, filter);
    addBlocksType = addBlocksType(~BlockTypeFilter);
    
    addBlocksName = addBlocksName(~BlockTypeFilter);
    %addBlocksName = char(addBlocksName);
    
    if (size(addBlocksType, 1) > 1) 
        [addBlocksType, Idx] = sort(addBlocksType);
    else
        addBlocksType = cellstr(addBlocksType);
        Idx = 1;
    end
    
    %Write to the report
    par = Paragraph(['There are ' num2str(size(addBlocksType, 1)) ' new blocks inside the NEW model:']);
    add(chapter,par);
    par = Paragraph('Note that blocks of types: "Ground", "Terminator" were filtered out');
    add(chapter,par);
    
    emptyCell(1:size(addBlocksType, 1)) = par;
    newCell = cell(size(addBlocksType, 1), 2);
    
    for i = 1:size(addBlocksType, 1)
    	par = Paragraph('Block type: ');
        par.Bold = true;    
        msg = Text(char(addBlocksType(i)));
        
        newCell(i, 2) = addBlocksType(i);
        
        msg.Bold = false;
        append(par, msg);
        msg = Text(' Block name: ');
        msg.Bold = true;
        append(par, msg);
        %msg = Text(addBlocksName(Idx(i),:));
        msg = Text(char(addBlocksName(Idx(i)) ) );
        
        newCell(i, 1) = addBlocksName(Idx(i));
        
        msg.Bold = false;
        append(par, msg);
  
        emptyCell(i) = par;   
    end
    
    %Add list of all blocks to the report
    if (size(addBlocksType, 1) == 1)
        ol = OrderedList({emptyCell});
    else
        ol = OrderedList(emptyCell);
    end

    add(chapter, ol);  
    clear emptyCell ol;
  
else
    if (all(LeftRight)) %Models are identical
        res = 1;
    end
    newCell = {};

end

end %function
