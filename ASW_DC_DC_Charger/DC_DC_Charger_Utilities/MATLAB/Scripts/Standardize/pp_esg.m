function [] = pp
%
%  pp.m
% 
%  Apply style guide color and size scheme to diagram.
%  (equivalent to pretty_print)
%
%  USAGE:  pp
%
%  If no blocks are selected, whole diagram is addressed
%  otherwise only selected blocks are affected.
%
%  George Brunemann
%
%  NgEK, Inc.
%

% Version Control System Header Information (automatically updated)
% -----------------------------------------------------------------
% $RCSFile: pp.m,v $
% $Revision: 1.3 $
% $Author: george $
% $Date: 2005/10/25 18:07:23 $
% -----------------------------------------------------------------

% Position = vector of coordinates (in pixels) not enclosed in quotation
% marks: [left top right bottom]

cr = sprintf('\n');
H = gcs;

% If no blocks are selected, then do on all blocks in diagram
lst = find_system(H, 'Selected', 'on');
Nsel = length(lst);
if Nsel == 0
    sel = 'off';
    disp(['Standardizing all blocks within ' char(H)]);
else
    sel = 'on';
    disp(['Only Standardizing Selected Blocks within ' char(H) char(10) '. Select no blocks to do whole system.']);
end

% Set all input ports to ORANGE, 20 x 20
lst = find_system(H, 'LookUnderMasks', 'on', 'Selected', sel, 'BlockType', 'Inport');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'orange');
   set_param(char(lst(i)),'ForegroundColor','black')
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
   end
   midpoint = P(1) + (P(3) - P(1))/2;
   P(1) = midpoint - 10;
   P(3) = midpoint + 10;
   midpoint = P(2) + (P(4) - P(2))/2;
   P(2) = midpoint - 10;
   P(4) = midpoint + 10;
   set_param(char(lst(i)), 'Position', P)
end

% Set all output ports to LIGHT BLUE, 20 x 20
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'Outport');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'lightBlue');
   set_param(char(lst(i)),'ForegroundColor','black')
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
   end
   midpoint = P(1) + (P(3) - P(1))/2;
   P(1) = midpoint - 10;
   P(3) = midpoint + 10;
   midpoint = P(2) + (P(4) - P(2))/2;
   P(2) = midpoint - 10;
   P(4) = midpoint + 10;
   set_param(char(lst(i)), 'Position', P)
end

% Set all datastores to White, height 20
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'DataStoreMemory');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
   n = get_param(lst(i), 'DataStoreName');
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
      n = n{1};
   end
   P(3) = max(P(3), P(1) + 10 + 6 * size(n, 2));
   P(4) = P(2) + 20;
   set_param(char(lst(i)), 'Position', P)
end
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'DataStoreRead');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')   
   n = get_param(lst(i), 'DataStoreName');
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
      n = n{1};
   end
   P(3) = max(P(3), P(1) + 10 + 6 * size(n, 2));
   P(4) = P(2) + 20;
   set_param(char(lst(i)), 'Position', P)
end
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'DataStoreWrite');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
   n = get_param(lst(i), 'DataStoreName');
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
      n = n{1};
   end
   P(3) = max(P(3), P(1) + 10 + 6 * size(n, 2));
   P(4) = P(2) + 20;
   set_param(char(lst(i)), 'Position', P)
end
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'RelationalOperator');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
end
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'ReferenceBlock', 'common_lib_NG/To xPC Scope');
disp(['Re-linking ' int2str(length(lst)) ' Green Blocks']);
for i = 1:length(lst)
    set_param(char(lst(i)),'ReferenceBlock','common_lib/Approved Simulink/Basic IO/To xPC Scope');
end

%Set GreenBlocks color, size, and Name Option
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'ReferenceBlock', 'common_lib/Approved Simulink/Basic IO/To xPC Scope');
for i = 1:length(lst)
    set_param(char(lst(i)),'BackgroundColor','darkGreen')
    set_param(char(lst(i)),'ForegroundColor','black')
    P = get_param(lst(i), 'Position');
    P = P{1};
    P(4) = P(2) + 20;
    P(3) = P(1) + 25;
    set_param(char(lst(i)), 'Position', P)

    checked = get_param(char(lst(i)),'NameFromSignal');
    userName = get_param(char(lst(i)), 'UserName');
    sigName = get_param(char(lst(i)), 'InputSignalNames');
    sigName = regexprep(sigName{1}, '[<> ]', '');
    if strcmp(sigName, userName)
        set_param(char(lst(i)), 'NameFromSignal', 'on');
        checked = 'on';
    end
    if strcmp(checked, 'on')
        set_param(char(lst(i)), 'UserName', '');
    else
        sigName = userName;
    end
    set_param(char(lst(i)), 'Name', ['WS_' char(sigName)], 'ShowName', 'off');
end



% Set constant-block calibrations to ORANGE, height 20
% Set constant-block test inputs to MAGENTA, height 20
% Set all other constant blocks to YELLOW, height 20
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'Constant');
for i = 1:length(lst)
   v = get_param(lst(i), 'Value');
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
      v = v{1};
   end
   switch strtok(v,'_')
       case 'CA'
          set_param(char(lst(i)), 'BackgroundColor', 'lightBlue');
          P(1) = min(P(1), P(3) - 10 - 6 * size(num2str(v), 2));
          P(4) = P(2) + 20;
       case {'C','CS','CW'}
          set_param(char(lst(i)), 'BackgroundColor', 'orange');
          P(1) = min(P(1), P(3) - 10 - 6 * size(num2str(v), 2));
          P(4) = P(2) + 20;
       case {'T','TC','TO'}
          set_param(char(lst(i)), 'BackgroundColor', 'magenta');
          P(1) = min(P(1), P(3) - 10 - 6 * size(num2str(v), 2));
          P(4) = P(2) + 20;
       otherwise
          set_param(char(lst(i)), 'BackgroundColor', 'yellow');            
   end
   set_param(char(lst(i)),'ForegroundColor','black')
   set_param(char(lst(i)), 'Position', P)
end

% Set common_lib calibrations to ORANGE, height 20
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'SubSystem', 'ReferenceBlock', 'common_lib/IO/Calibration with Pretty Print Value');
for i = 1:length(lst)
   set_param(char(lst(i)),'BackgroundColor','orange')
   set_param(char(lst(i)),'ForegroundColor','black')
   N = get_param(char(lst(i)), 'CalValue');
   P = get_param(lst(i), 'Position');
   P = P{1};
   P(4) = P(2) + 20;
   P(3) = max(P(3), P(1) + 20 + 6 * size(N, 2));
   set_param(char(lst(i)), 'Position', P)
end

% Set masked calibrations to ORANGE, height 20
% Set masked test inputs to MAGENTA, height 20
% Set masked other constant blocks to YELLOW, height 20
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'MaskType', 'Calibratible Input');
for i = 1:length(lst)
   v = get_param(lst(i), 'CalValue');
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
      v = v{1};
   end
   [~,b]=strtok(v,'_');
   c=b(2:end);
   d=extractAfter(c,'_');
   switch d
       case 'CA'
           set_param(char(lst(i)), 'BackgroundColor', 'lightBlue');
           P(4) = P(2) + 20;
       case {'C','CS','CW'}
            set_param(char(lst(i)), 'BackgroundColor', 'orange');
            P(4) = P(2) + 20;
      case {'T','TC','TO'}
         set_param(char(lst(i)), 'BackgroundColor', 'magenta');
         P(4) = P(2) + 20;
      otherwise
         set_param(char(lst(i)), 'BackgroundColor', 'yellow');
   end
   set_param(char(lst(i)),'ForegroundColor','black')
   
   P(1) = min(P(1), P(3) - 10 - 6 * size(num2str(v), 2));

   set_param(char(lst(i)), 'Position', P)
end

% Set all gotos to WHITE, height 20
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'Goto');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white'); 
   set_param(char(lst(i)),'ForegroundColor','black')
   v = get_param(lst(i), 'GotoTag');
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
      v = v{1};
   end
   P(3) = max(P(3), P(1) + 40 + 6 * size(num2str(v), 2));
   P(4) = P(2) + 20;
   set_param(char(lst(i)), 'Position', P)
end

% Set all froms to WHITE, height 20
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'From');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white'); 
   set_param(char(lst(i)),'ForegroundColor','black')
   v = get_param(lst(i), 'GotoTag');
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
      v = v{1};
   end
   P(3) = max(P(3), P(1) + 40 + 6 * size(num2str(v), 2));
   P(4) = P(2) + 20;
   set_param(char(lst(i)), 'Position', P)
end

% Set all monitors to GREEN, height 20
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'ToWorkspace');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'green');  
   set_param(char(lst(i)),'ForegroundColor','black')
   v = get_param(lst(i), 'VariableName');
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
      v = v{1};
   end
   P(3) = max(P(3), P(1) + 20 + 6 * size(num2str(v), 2));
   P(4) = P(2) + 20;
   set_param(char(lst(i)), 'Position', P)
end

% Set all unit delays to show ic, size 20 x 20
lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'UnitDelay');
for i = 1:length(lst)
   set_param(char(lst(i)), 'AttributesFormatString','ic=%<X0>');
   P = get_param(lst(i), 'Position');
   if iscell(P)
      P = P{1};
   end
   P(3) = P(1) + 20;
   P(4) = P(2) + 20;
   set_param(char(lst(i)), 'Position', P)
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'BlockType', 'Lookup');
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');  % Set all 1D table lookups to WHITE
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'LookUnderMasks', 'on',  'Selected', sel, 'ReferenceBlock', ...
            ['simulink3/Functions' cr '& Tables/Look-Up' cr 'Table (2-D)']);
for i = 1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');  % Set all 2D table lookups to WHITE
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'MaskType', 'Adjustable Linear Table');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'MaskType', 'Adjustable_Surface_Interpolation');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'MaskType', 'Adjustable_Surface_Interpolation_Shared_Axis');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'MaskType', 'Variable Rate Limiter');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'BlockType', 'Sum');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'BlockType', 'Product');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'BlockType', 'Logic');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'BlockType', 'MinMax');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'BlockType', 'UnitDelay');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'BlockType', 'Switch');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

lst = find_system(H, 'BlockType', 'DataTypeConversion');
for i=1:length(lst)
   set_param(char(lst(i)), 'BackgroundColor', 'white');
   set_param(char(lst(i)),'ForegroundColor','black')
end

%Verify need for lbl_all on EPS before allowing to run J.Dunfee 2009.04.07
lbl_all;

end

