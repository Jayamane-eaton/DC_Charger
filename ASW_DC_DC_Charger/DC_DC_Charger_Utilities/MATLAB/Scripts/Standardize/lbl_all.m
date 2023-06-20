function [] = lbl_all
%
%  lbl_all.m
%
%  Rename blocks with content names.
%
%  USAGE: lbl_all
%
%  12Apr2003
%  NgEK, Inc.
%  All Rights Reserved
%

% Version Control System Header Information (automatically updated)
% -----------------------------------------------------------------
% $RCSFile: lbl_all.m,v $
% $Revision: 1.3 $
% $Author: george $
% $Date: 2005/10/25 18:07:23 $
% -----------------------------------------------------------------

H = gcs;

% If no blocks are selected, then do on all blocks in diagram
lst = find_system(H, 'Selected', 'on');
Nsel = length(lst);
if Nsel == 0
    sel = 'off';
else
    sel = 'on';
end

%-------------------------------------------------------------------
%  Rename all constant blocks with variable names starting with C_ or T_
%-------------------------------------------------------------------
% First pass change name to unused name
lst = find_system(H, 'Selected', sel, 'BlockType', 'Constant');
vs = get_param(lst, 'Value');


for i= 1:length(lst)
    if strtok(vs{i},'_')=='C' | strtok(vs{i},'_')=='T'
        set_param(lst{i}, 'Name', [num2str(cputime) num2str(i)], 'ShowName', 'off');
    end
end
% Now change to unique names
lst = find_system(H, 'Selected', sel, 'BlockType', 'Constant');
vs = get_param(lst, 'Value');
[vs ivs] = sort(vs);
vx = 1;
if ~isempty(lst)
	vsn{1} = [vs{1}];
	for i = 2:length(lst)
		if strcmp(vs{i}, vs{i-1})
			vx = vx + 1;
			vsn{i} = [vs{i} '_' num2str(vx)];
		else
			vx = 1;
			vsn{i} = [vs{i}];
		end
	end
    for i= 1:length(lst)
        if strtok(vsn{i},'_')=='C' | strtok(vsn{i},'_')=='T'
            set_param(lst{ivs(i)}, 'Name', vsn{i}, 'ShowName', 'off');
        end
    end
end

lst = find_system(H, 'Selected', sel, 'MaskType', 'Calibratible Input');
vs = get_param(lst, 'CalValue');
for i= 1:length(lst)
    if strtok(vs{i},'_')=='C' | strtok(vs{i},'_')=='T'
        set_param(lst{i}, 'Name', [num2str(cputime) num2str(i)], 'ShowName', 'off');
    end
end
% Now change to unique names
lst = find_system(H, 'Selected', sel, 'MaskType', 'Calibratible Input');
vs = get_param(lst, 'CalValue');
[vs ivs] = sort(vs);
vx = 1;
if ~isempty(lst)
	vsn{1} = [vs{1}];
	for i = 2:length(lst)
		if strcmp(vs{i}, vs{i-1})
			vx = vx + 1;
			vsn{i} = [vs{i} '_' num2str(vx)];
		else
			vx = 1;
			vsn{i} = [vs{i}];
		end
	end
    for i= 1:length(lst)
        if strtok(vsn{i},'_')=='C' | strtok(vsn{i},'_')=='T'
            set_param(lst{ivs(i)}, 'Name', vsn{i}, 'ShowName', 'off');
        end
    end
end

%-------------------------------------------------------------------
%  Rename all workspace blocks with variable names
%-------------------------------------------------------------------
% First pass change name to unused name
lst = find_system(H, 'Selected', sel, 'BlockType', 'ToWorkspace');
for i= 1:length(lst)
    set_param(lst{i}, 'Name', [num2str(cputime) num2str(i)], 'ShowName', 'off');
end
% Now change to unique names
lst = find_system(H, 'Selected', sel, 'BlockType', 'ToWorkspace');
for i = 1:length(lst)
  v = get_param(lst{i}, 'VariableName');
  v = ['M_' v];
  set_param(lst{i}, 'Name', v, 'ShowName', 'off');
end


%-------------------------------------------------------------------
%  Rename all datastore blocks with variable names
%-------------------------------------------------------------------
% First pass change name to unused name
lst = find_system(H, 'Selected', sel, 'BlockType', 'DataStoreMemory');
for i= 1:length(lst)
    set_param(lst{i}, 'Name', [num2str(cputime) num2str(i)], 'ShowName', 'off');
end
% Now assign unique names
lst = find_system(H, 'Selected', sel, 'BlockType', 'DataStoreMemory');
vs = get_param(lst, 'DataStoreName');
[vs ivs] = sort(vs);
vx = 1;
if ~isempty(lst)
	vsn{1} = ['DS' vs{1}];
	for i = 2:length(lst)
		if strcmp(vs{i}, vs{i-1})
			vx = vx + 1;
			vsn{i} = ['DS_' vs{i} '_' num2str(vx)];
		else
			vx = 1;
			vsn{i} = ['DS_' vs{i}];
		end
	end
	for i= 1:length(lst)
		set_param(lst{ivs(i)}, 'Name', vsn{i}, 'ShowName', 'off');
	end
end

% First pass change name to unused name
lst = find_system(H, 'Selected', sel, 'BlockType', 'DataStoreRead');
for i= 1:length(lst)
    set_param(lst{i}, 'Name', [num2str(cputime) num2str(i)], 'ShowName', 'off');
end
% Now assign unique names
lst = find_system(H, 'Selected', sel, 'BlockType', 'DataStoreRead');
vs = get_param(lst, 'DataStoreName');
[vs ivs] = sort(vs);
vx = 1;
if ~isempty(lst)
	vsn{1} = ['DR' vs{1}];
	for i = 2:length(lst)
		if strcmp(vs{i}, vs{i-1})
			vx = vx + 1;
			vsn{i} = ['DR_' vs{i} '_' num2str(vx)];
		else
			vx = 1;
			vsn{i} = ['DR_' vs{i}];
		end
	end
	for i= 1:length(lst)
		set_param(lst{ivs(i)}, 'Name', vsn{i}, 'ShowName', 'off');
	end
end

% First pass change name to unused name
lst = find_system(H, 'Selected', sel, 'BlockType', 'DataStoreWrite');
for i= 1:length(lst)
    set_param(lst{i}, 'Name', [num2str(cputime) num2str(i)], 'ShowName', 'off');
end
% Now assign unique names
lst = find_system(H, 'Selected', sel, 'BlockType', 'DataStoreWrite');
vs = get_param(lst, 'DataStoreName');
[vs ivs] = sort(vs);
vx = 1;
if ~isempty(lst)
	vsn{1} = ['DW' vs{1}];
	for i = 2:length(lst)
		if strcmp(vs{i}, vs{i-1})
			vx = vx + 1;
			vsn{i} = ['DW_' vs{i} '_' num2str(vx)];
		else
			vx = 1;
			vsn{i} = ['DW_' vs{i}];
		end
	end
	for i= 1:length(lst)
		set_param(lst{ivs(i)}, 'Name', vsn{i}, 'ShowName', 'off');
	end
end

%-------------------------------------------------------------------
%  Rename all goto/from blocks with target names
%-------------------------------------------------------------------
% First pass change name to unused name
lst = find_system(H, 'Selected', sel, 'BlockType', 'From');
vs = get_param(lst, 'GotoTag');
for i= 1:length(lst)
    set_param(lst{i}, 'Name', [num2str(cputime) num2str(i)], 'ShowName', 'off');
end
% Now change to unique names
lst = find_system(H, 'Selected', sel, 'BlockType', 'From');
vs = get_param(lst, 'GotoTag');
[vs ivs] = sort(vs);
vx = 1;
if ~isempty(lst)
	vsn{1} = ['From' vs{1}];
	for i = 2:length(lst)
		if strcmp(vs{i}, vs{i-1})
			vx = vx + 1;
			vsn{i} = ['From' vs{i} '_' num2str(vx)];
		else
			vx = 1;
			vsn{i} = ['From' vs{i}];
		end
	end
    for i= 1:length(lst)
		set_param(lst{ivs(i)}, 'Name', vsn{i}, 'ShowName', 'off');
    end
end

% First pass change name to unused name
lst = find_system(H, 'Selected', sel, 'BlockType', 'Goto');
vs = get_param(lst, 'GotoTag');
for i= 1:length(lst)
    set_param(lst{i}, 'Name', [num2str(cputime) num2str(i)], 'ShowName', 'off');
end
% Now change to unique names
lst = find_system(H, 'Selected', sel, 'BlockType', 'Goto');
vs = get_param(lst, 'GotoTag');
[vs ivs] = sort(vs);
vx = 1;
if ~isempty(lst)
	vsn{1} = ['Goto' vs{1}];
	for i = 2:length(lst)
		if strcmp(vs{i}, vs{i-1})
			vx = vx + 1;
			vsn{i} = ['Goto' vs{i} '_' num2str(vx)];
		else
			vx = 1;
			vsn{i} = ['Goto' vs{i}];
		end
	end
    for i= 1:length(lst)
		set_param(lst{ivs(i)}, 'Name', vsn{i}, 'ShowName', 'off');
    end
end
