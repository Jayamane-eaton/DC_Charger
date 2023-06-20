%  Standardize a drawing...
%   - same size, shape, location
%
%
%  USAGE:  standardize;
%
%  15Oct2003
%  NgEK, Inc.
%  All Rights Reserved
%

% Version Control System Header Information (automatically updated)
% -----------------------------------------------------------------
% $RCSFile: standardize.m,v $
% $Revision: 1.10 $
% $Author: george $
% $Date: 2006/05/01 04:53:25 $
% Updated by: Rushabh Mehta 07/08/2019
% -----------------------------------------------------------------


%   Usage: Open library and unlock then run script.

% Standardize look and feel ---------------------------------------------------
try
    progress = waitbar(0.05, 'Closing open Subsystems', 'Name', 'Standardizing');
    set_param(bdroot,'Lock','off');
    openblks = find_system(bdroot,'Open','on');
    if length(openblks) > 1
        for j=2:length(openblks)
            set_param(openblks{j},'Open','off');
        end
    end
    
    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(0.1, progress, 'Deselecting blocks');
    
    selectedblks = find_system(bdroot,'Selected','on');
    if length(selectedblks) > 1
        for j=1:length(selectedblks)
            set_param(selectedblks{j},'Selected','off');
        end
    end
    try
        set_param(bdroot,'BrowserShowLibraryLinks','on');
    catch
        add_param(bdroot,'BrowserShowLibraryLinks','on');
    end

    lbl_all;

    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(0.15, progress, 'Setting Screen Size and Zoom');
    
    % Set standard screen size and zoom -------------------------------------------
    set_param(bdroot,'Location',[350 100 1350 850]);
    set_param(bdroot,'ZoomFactor','100');
    set_param(bdroot,'ModelBrowserVisibility','on');
    set_param(bdroot,'ModelBrowserWidth',250);
    lst = find_system(bdroot, 'BlockType','SubSystem');
    for i=1:length(lst)
        bptr = lst{i};
        try
            set_param(bptr,'Location',[350 100 1350 850]);
            set_param(bptr,'ZoomFactor','100');
            set_param(bptr,'ModelBrowserVisibility','on');
            set_param(bptr,'ModelBrowserWidth',250);
        catch
        end
    end

    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(0.2, progress, 'Turning off ''SaturateOnIntegerOverflow''');
    
    % Turn SaturateOnIntegerOverflow off ------------------------------------------
    lst = find_system(bdroot, 'Type', 'block', ...
                         'SaturateOnIntegerOverflow', 'on');
    N = length(lst);
    if N > 0
       disp('SaturateOnIntegerOverflow set to off for:');
    end
    for i = 1:N
       disp(lst{i});
       set_param(lst{i}, 'SaturateOnIntegerOverflow', 'off');
    end

    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(0.3, progress, 'Turning off ''ZeroCross''');
    
    % Turn ZeroCross off ----------------------------------------------------------
    lst = find_system(bdroot, 'Type', 'block', ...
                         'ZeroCross', 'on');
    N = length(lst);
    if N > 0
       disp('ZeroCross set to off for:');
    end
    for i = 1:N
       disp(lst{i});
       set_param(lst{i}, 'ZeroCross', 'off');
    end

    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(0.35, progress, 'Re-Enabling Disabled Links');
    
    % Re-enable disabled links-----------------------------------------------------
    %if findstr(bdroot,'INMGMTEMCURR')==[]
        % Re-enable disabled links-------------------------------------------------
        lst = find_system(bdroot, 'linkstatus', 'inactive');
        N = length(lst);
        if N > 0
           disp('Re-enabling links for:');
        end
        for i = 1:N
           disp(lst{i});
           r = input('Do you want to restore the link for the block above (Y/N) ? ','s');
           if r(1)=='Y' || r(1)=='y'
               set_param(lst{i}, 'linkstatus', 'restore');
           end
        end
    %end

    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(0.4, progress, 'Setup CVS keywords for Model Info block');
    
    % Setup the CVS keywords for the Model Info block -----------------------------
    tmp = get_param(bdroot,'ModifiedByFormat');
    tmp = findstr(tmp,'Auto');
    if(isempty(tmp))
        set_param(bdroot,'ModifiedByFormat','$%<Auto> $');
    end

    tmp = get_param(bdroot,'ModifiedDateFormat');
    tmp = findstr(tmp,'Auto');
    if(isempty(tmp))
        set_param(bdroot,'ModifiedDateFormat','$Date: %<Auto> $');
    end

    tmp = get_param(bdroot,'ModelVersionFormat');
    tmp = findstr(tmp,'Auto');
    if(isempty(tmp))
        set_param(bdroot,'ModelVersionFormat','$1.%<AutoIncrement:00> $');
    end

    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(0.5, progress, 'Setting switch Thresholds to 0.5');

    % Set switch thresholds to 0.5 ------------------------------------------------
    lst = find_system(bdroot, ...
                        'FollowLinks', 'off', ...
                        'LookUnderMasks', 'on', ...
                        'BlockType', 'Switch');
    N = length(lst);
    if N > 0
       disp('Setting thresholds for switches:');
    end
    for i = 1:N
        thd_old= get_param(lst{i}, 'Threshold');
        if ~strcmp(thd_old,'0.5')
            disp([ lst{i} ' was ' thd_old]);
            set_param(lst{i}, 'Threshold', '0.5');
        end
    end

    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(0.6, progress, 'Setting subsystem colors');
    
    ps_esg;

    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(0.7, progress, 'Setting block colors');
    
    pp_esg;
    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
%     waitbar(0.8, progress, 'Renaming Outports');
%     
%     RenameOutports;

    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
%     waitbar(0.9, progress, 'Searching for Uninitialized Ouports');
% 
%     FindUninitializedOutports;
%     
    %%%%%%%%%%%%
    % PROGRESS
    %%%%%%%%%%%%
    waitbar(1, progress, 'Done!');
    
    close(progress);
catch err
    try
        [name1 name2] = err.stack.name;
        [line1 line2] = err.stack.line;
    catch err2
        name1 = err.stack.name;
        name2 = 'n/a';
        line1 = err.stack.line;
        line2 = 'n/a';
    end
    msgbox(['Standardize encountered an error. Your file is still being saved, ' ...
                  'but it is your responsibility to correct the error before checkin.' ...
                  char(10) char(10)  'Error in ' name1 ' line ' num2str(line1) ':' char(10) ...
                  err.message char(10) ...                  
                  'Previous call:  ' name2 ' line ' num2str(line2) ':' char(10) ...
                  ], 'Standardize Error', 'warn');
    close(progress);
end