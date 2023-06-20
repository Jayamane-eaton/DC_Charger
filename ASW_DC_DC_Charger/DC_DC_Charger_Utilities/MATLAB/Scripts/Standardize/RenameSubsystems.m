%
%NAME:
%      RenameSubystems.m
% 
%USAGE:  
%      RenameSubystems [-live]
%
%DESCRIPTION:
%      Renames Subsystems to give heirarchical number scheme
%      for easy reference in communications and work. Without option
%      '-live' it will only show what it would have done as opposed to
%      doing it for real.
%
%      Upon running, it gives the option for a starting Prefix to the model
%      blocks as well as an option to start either from the currently
%      selected block or the root of the current file.
%
%OPTIONS:
%      -live
%              Actually perform name changes as opposed to simply
%              displaying what would otherwise be changed.
%
%AUTHOR:
%  Sean Lauren
%
function RenameSubystems(varargin)

    prefix = '';
    name = '';
    ref = '';
    lst = find_system(bdroot, 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'SubSystem', 'ShowName', 'on');
    startBlock = lst(1);
    live = false;
    
    if nargin > 0
        tmpstr = char(varargin);
        %remove the leading dash
        tmpstr = tmpstr(2:end);
    else
        tmpstr = 'test';
    end
    
    switch tmpstr
        case 'live'
            disp([char(10) '********************************WARNING*********************************'])
            disp('**  It is highly recommended that you save any changes you have made  **');
            disp('**  prior to running this script as it touches any and all subsystems **'); 
            disp('**  that do not follow a sequential number order.                     **');
            disp('**  For questions or concerns, contact Sean Lauren.                   **'); 
            disp(['************************************************************************' char(10)]);
            live = true;
            set_param(bdroot,'Lock','off');
        otherwise
            disp([char(10) '***********You are in Test Mode Only. Use option "-live" to perform actual name changes***********' char(10)]);
            live = false;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine Start Location
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    startLoc = input(['Where should renaming begin?' char(10) '    [1] Current Block: "' gcb '"' char(10) '    [2] Root: ' char(startBlock) char(10) '    [3] Cancel' char(10) '(1, 2, 3)? >> '], 's');
    switch startLoc
        case '1'
            startBlock = gcb;
            name = get_param(startBlock, 'Name');
            ref = get_param(startBlock, 'ReferenceBlock');
            prefix = getPotentialPrefix(name);
            disp([char(10) '************Starting from Current Block************' char(10)]);
        case '2'
            name = get_param(startBlock, 'Name');
            name = name{1};
            ref = get_param(startBlock, 'ReferenceBlock');
            ref = ref{1};
            prefix = getPotentialPrefix(name);
            disp([char(10) '************Starting from Root************' char(10)]);
        case '3'
            disp('************Cancelling Rename Request************');
            return;
        otherwise
            disp('************Invalid Input. Cancelling Rename Request************');
            return;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine Prefix Designation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    prefixResponse = input(['Would you like to set up a prefix?' char(10) '    [1] Default: "' prefix '"' char(10) '    [2] Manual Input' char(10) '    [3] None' char(10) '(1, 2, 3)? >> '], 's');
    switch prefixResponse
        case '1'
            disp([char(10) '************Utilizing Default Prefix************' char(10)]);
        case '2'
            prefix = input(['Please enter desired Prefix (i.e. Diag_, Trn_)' char(10) 'Prefix >> '], 's');
            %If user forgot a trailing '_', add it on
            if prefix(length(prefix)) ~= '_'
                prefix = [prefix '_'];
            end
        case '3'
            disp([char(10) '************No prefix desired************' char(10)])
            prefix = '';
        otherwise
            disp('************Invalid Response. Cancelling Rename Request************');
            return
    end
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Begin Renaming
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    newName = [prefix stripName(name)];
    sameName = namesEquate(newName, name);
    if ~sameName
        disp([newName ' <-- ' char(name)]);
        if live
            set_param(char(startBlock), 'Name', newName);
        end
    end
    % If not a Library block, go Deeper to rename
    if size(ref, 2) == 0
        if live && ~sameName
            objPath = char(startBlock);
            objPath = objPath(1:length(objPath)-length(name));
            GoDeeper([objPath newName], 1, prefix, live);
        else
            GoDeeper(startBlock, 1, prefix, live);
            
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GoDeeper(subSystem, depth, prefix)
%       
% Recursively calls itself to rename all subsystems within the given 
% subsystem
% 
% PARAMETERS:
% subsystem = subsystem to search for lower subsystems within to rename
%
% depth = depth within subsystem heirarchy for printing purposes
%
% prefix = keeps track of heirarchical structure through recursive 
%          iterations (i.e. "Diag_1_3_2_")
%
% live = true if renaming is desired, false if output of what would
%        otherwise be renamed is desired
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GoDeeper(subSystem, depth, prefix, live)
    lst = find_system(subSystem, 'LookUnderMasks', 'on', ...
                      'SearchDepth', 1, 'BlockType', 'SubSystem', ...
                      'ShowName', 'on');
    %first item in list is always the parent subsystem so start at 2 (the
    %first child)
    for i = 2:length(lst)
        ref = get_param(lst(i), 'ReferenceBlock');
        isCommonLib = findstr(ref{1}, 'common_lib');
        %make sure it's not a commonLib block which does not need prefix
        if isempty(isCommonLib)
            %determine tabbing for pretty printing
            for d = 1:depth
                fprintf('    ');
            end
            %print new name and what it came from (-1 is to account for parent
            %being 1. First child is 2 but needs to be numbered 1, etc.
            name = get_param(lst(i), 'Name');
            strippedName = stripName(name{1});
            newName = [prefix itochar(i-1, length(lst)-1) '_' strippedName];
            sameName = namesEquate(newName, name{1});
            if ~sameName
                disp([newName ' <-- ' char(name)]);
                if live
                    set_param(char(lst(i)), 'Name', newName);
                end
            end

            %For each child of the parent, if it's not a library link, traverse
            %and rename all of its respective children
            if size(ref{1}, 2) == 0
                %-1 is to account for parent being 1. First child is 2 but 
                %needs to be numbered 1, etc.
                if live && ~sameName
                    objPath = char(lst(i));
                    objPath = objPath(1:length(objPath)-length(name{1}));
                    GoDeeper([objPath newName], depth + 1, [prefix itochar(i-1, length(lst)-1) '_'], live);
                else
                    GoDeeper(lst(i), depth + 1, [prefix itochar(i-1, length(lst)-1) '_'], live);
                end
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [name] stripName(currName)
%       
% Parses on '_' and '.' characters to determine the real name of the 
% subsystem apart from any numerical prefixes (i.e. 1.2.3, 1_2_3). It
% simply returns all characters after a series of numbers. 
%
% EXAMPLE:
% "Diag_1_2.3.4_TheName2_4" would return "TheName2_4"
%
% PARAMETERS:
% currName = The current name of the subsystem block
%
% RETURNS:
% name = the name passed in without the prefix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [name] = stripName(currName)
    splitname = regexp(currName, '[_.]', 'split');
    nameStart = 1;
    foundNums = false;
    name = char('');
    %For each item that was separated by '_' or '.'
    for i = 1:length(splitname)
        charMatches = regexp(splitname(i), '[a-zA-Z]');
        %if no characters were found, it is probably numeric and hence
        %a prefix. Keep going until alphabetic characters are found.
        if isempty(charMatches{1})
            foundNums = true;
        %if alphabetic characters are found and we previously found numbers
        %this is probably the start of the subsystem name
        elseif foundNums == true
            nameStart = i;
            break;
        end
    end
    %begin appending together the separated word chunks from where the name
    %is expected to have started
    for i = nameStart:length(splitname)
        name = [name char(splitname(i)) '_'];
    end
    %remove trailing '_' from appending loop
    name(length(name)) = '';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [prefix] getPotentialPrefix(name)
%       
% Parses on '_' and '.' characters to determine the prefix of the 
% subsystem preceeding its name. It simply returns all characters prior to
% when a series of numbers ends. Meant to run only once to guess the 
% desired prefix for quicker use.
%
% EXAMPLE:
% "Diag_1_2.3.4_TheName2_4" would return "Diag_1_2_3_4_"
% "Diag_TheName2_4" would return nothing
%
% PARAMETERS:
% name = name of the subsystem being parsed
%
% RETURNS:
% prefix = the prefix of the name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [prefix] = getPotentialPrefix(name)
    splitname = regexp(name, '[_.]', 'split');
    nameStart = 1;
    foundNums = false;
    prefix = char('');
    %For each item that was separated by '_' or '.'
    for i = 1:length(splitname)
        charMatches = regexp(splitname(i), '[a-zA-Z]');
        %if no characters were found, it is probably numeric and hence
        %a prefix. Keep going until alphabetic characters are found.
        if isempty(charMatches{1})
            foundNums = true;
        %if alphabetic characters are found and we previously found numbers
        %this is probably the start of the subsystem name
        elseif foundNums == true
            nameStart = i;
            break;
        end
    end
    %If we've found numbers before a possible name, let's use everything
    %before that name as the guessed prefix desired.
    if foundNums
        for i = 1:nameStart-1
            prefix = [prefix char(splitname(i)) '_'];
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [chars] itochar(val, max)
%       
% Turns an int into an array of characters. If more than 10 or 100 blocks 
% are present in a subsystem it adds leading '0'(s) to keep proper order 
% in naming.
% 
% val = integer to be converted to characters
%
% max = the maximum number used in the current subsystem (to know if 
%       leading '0' is necessary)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chars] = itochar(val, max)
    chars = char(mod(val, 10) + double('0'));
    if val >= 10
        chars = [char(mod(val/10, 10) + double('0')) chars];
    elseif max >= 10
        chars = ['0' chars];
    end
    if val >= 100
        chars = [char(mod(val/100, 10) + double('0')) chars];
    elseif max >= 100
        chars = ['0' chars];
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [equate] namesEquate(name1, name2)
%       
% Takes two character arrays and determines if they are 100% identical
% 
% PARAMATERS:
% name1 = first char array
% name2 = second char array
%
% RETURNS:
% equate = true if names are 100% identical, false otherwise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [equate] = namesEquate(name1, name2)
    equate = true;
    %if they're not the same size, then they're definitely not the same.
    %Cannot utilize == if not the same size anyway
    if length(name1) == length(name2)
        charsEquate = name1 == name2;
        %Utilizing == on an array yields an array of Boolean results
        %ANDing them together will tell me if they're all true
        for i = 1:length(charsEquate)
            equate = equate & charsEquate(i);
        end
    else
        equate = false;
    end
    if equate
        disp(name1);
    end

end
