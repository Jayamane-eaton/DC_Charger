%--------------------------------------------------------------------------
% Filename: bit_morph.m
%
% Description: Performs self-modification on Simulink bit pack and unpack
% block based on desired uint datatype (number of bits).
%
% Author: L J Brackney   NgEK, Inc.
% Date:   8/27/2004
%
% Arguments
%   Pack:
%       1 - Bit unpack
%       2 - Bit pack
%   DType:
%       1 - UINT8
%       2 - UINT16
%       3 - UINT32
%--------------------------------------------------------------------------

h = gcb;                          % Shorthand for block handle

% Detect if number of inputs or outputs has changed
x             = get_param(h, 'Ports');
N_in_old      = x(1);
N_out_old     = x(2);

Add_IntIn     = false;
Add_BitIn     = false;
Add_IntOut    = false;
Add_BitOut    = false;
Remove_IntIn  = false;
Remove_BitIn  = false;
Remove_IntOut = false;
Remove_BitOut = false;

if (Pack==1) && (DType==1)         % Define number of inputs, outputs, and data type
    N_in        = 1;              % based on bit operation mode and type specified in mask
    N_out       = 8;
    UStr        = 'uint8(';
    if (N_in_old>1)   Add_IntIn     = true; Remove_BitIn = true; end;
    if (N_out_old==1) Remove_IntOut = true; Add_BitIn    = true; end;
elseif (Pack==1) && (DType==2)
    N_in        = 1;
    N_out       = 16;
    UStr        = 'uint16(';
    if (N_in_old>1)   Add_IntIn     = true; Remove_BitIn = true; end;
    if (N_out_old==1) Remove_IntOut = true; Add_BitIn    = true; end;
elseif (Pack==1) && (DType==3)
    N_in        = 1;
    N_out       = 32;
    UStr        = 'uint32(';
    if (N_in_old>1)   Add_IntIn     = true; Remove_BitIn = true; end;
    if (N_out_old==1) Remove_IntOut = true; Add_BitIn    = true; end;
elseif (Pack==2) && (DType==1)
    N_in        = 8;
    N_out       = 1;
    UStr        = 'uint8(';
    if (N_in_old==1) Remove_IntIn  = true; Add_BitIn = true; end;
    if (N_out_old>1) Add_IntOut    = true; Remove_BitOut = true; end;
elseif (Pack==2) && (DType==2)
    N_in        = 16;
    N_out       = 1;
    UStr        = 'uint16(';
    if (N_in_old==1) Remove_IntIn  = true; Add_BitIn = true; end;
    if (N_out_old>1) Add_IntOut    = true; Remove_BitOut = true; end;
elseif (Pack==2) && (DType==3)
    N_in        = 32;
    N_out       = 1;
    UStr        = 'uint32(';
    if (N_in_old==1) Remove_IntIn  = true; Add_BitIn = true; end;
    if (N_out_old>1) Add_IntOut    = true; Remove_BitOut = true; end;
end;

% Get list of blocks and lines in scheduler
lb = find_system(h, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'on', 'type', 'block');
ll = find_system(h, 'SearchDepth', 1, 'FollowLinks', 'on', 'FindAll', 'on', 'LookUnderMasks','on', 'type', 'line');

% Determine if mask has changed since last update
MaskChanged = false;
if ~(N_out==N_out_old) || ~(N_in==N_in_old)
   MaskChanged = true;
end;

if MaskChanged                                     % Only rebuild diagram if mask has changed
   while ~(isempty(ll)),                           % Remove any lines
         delete_line(ll(1));
         ll = find_system(h, 'SearchDepth', 1, 'FollowLinks', 'on', 'FindAll', 'on', 'LookUnderMasks','on', 'type', 'line');
   end;

   if ~(isempty(lb))                               % Remove the old blocks
       for i=2:length(lb),
           blkname = char(lb(i));
           if ~(isempty(findstr(blkname,'BitIn'))) && ((str2num(get_param(blkname,'Port')) > N_in) || Remove_BitIn)
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'BitOut'))) && ((str2num(get_param(blkname,'Port')) > N_out) || Remove_BitOut)
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'BitOp')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'IntIn'))) && (Remove_IntIn)
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'IntOut'))) && (Remove_IntOut)
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Compare')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Number')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Switch')))
              delete_block(blkname)
           end;
       end;
   end;

   x0 = 40; y0 = 40;                                               % Specify upper corner of the diagram

   if (Pack==1)                                                    % Add blocks and lines for Bit Unpacker
      if Add_IntIn
         add_block('built-in/Inport',[h '/IntIn'], 'Position',[x0 y0 x0+20 y0+20], 'BackgroundColor','Orange');
      end;
      for i=1:N_out,
          yy=y0+(i-1)*60;
          if (i>N_out_old) || Add_BitOut
             add_block('built-in/Outport',[h '/BitOut' num2str(i)], 'Position',[x0+270 yy+10 x0+290 yy+30], 'BackgroundColor','LightBlue');
          end;
          add_block('simulink/Math Operations/Bitwise Logical Operator',[h '/BitOp' num2str(i)],'Position',[x0+70 yy-10 x0+110 yy+30], 'ShowName','Off', 'Operator', 'AND', 'Operand2', [UStr num2str(2^(N_out-i)) ')']);
          add_block('built-in/Relational Operator',[h '/Compare' num2str(i)], 'Position',[x0+230 yy x0+250 yy+30],'Operator','==','ShowName','Off');
          add_block('built-in/Constant',[h '/Number' num2str(i)], 'Position',[x0+120 yy+15 x0+200 yy+35], 'BackgroundColor','Yellow', 'Value',[UStr num2str(2^(N_out-i)) ')'],'ShowName','Off');
          add_line(h, ['BitOp' num2str(i) '/1'],['Compare' num2str(i) '/1']);
          add_line(h, ['Number' num2str(i) '/1'],['Compare' num2str(i) '/2']);
          add_line(h, ['Compare' num2str(i) '/1'],['BitOut' num2str(i) '/1']);
          add_line(h, 'IntIn/1', ['BitOp' num2str(i) '/1' ], 'AUTOROUTING','ON');
      end;
  else                                                             % Add blocks and lines for Bit Packer
      if Add_BitIn
         add_block('built-in/Inport',[h '/BitIn1'], 'Position',[x0+60 y0+35 x0+80 y0+55], 'BackgroundColor','Orange');
      end;
      add_block('simulink/Math Operations/Bitwise Logical Operator',[h '/BitOp1'],'Position',[x0+50 y0-10 x0+90 y0+30], 'ShowName','Off', 'Operator', 'OR', 'Operand2', [UStr num2str(2^(N_in-1)) ')']);
      add_block('built-in/Switch',[h '/Switch1'],  'Position',[x0+120 y0-10 x0+150 y0+100], 'Criteria','u2 ~= 0','ShowName','Off','Threshold','0.5');
      add_block('built-in/Constant',[h '/Number'], 'Position',[x0-30 y0 x0+20 y0+20], 'BackgroundColor','Yellow', 'Value',[UStr '0)'],'ShowName','Off');
      add_line(h, ['Number/1'],['BitOp1/1']);
      add_line(h, ['BitOp1/1'],['Switch1/1']);
      add_line(h, ['BitIn1/1'],['Switch1/2']);
      add_line(h, ['Number/1'],['Switch1/3'], 'AUTOROUTING','ON');
      for i=2:N_in,
          xx=x0+(i-1)*150+50;
          yy=y0+(i-1)*35;
          if (i>N_in_old) || Add_BitIn
             add_block('built-in/Inport',[h '/BitIn' num2str(i)], 'Position',[xx+10 yy+35 xx+30 yy+55], 'BackgroundColor','Orange');
          end;
          add_block('simulink/Math Operations/Bitwise Logical Operator',[h '/BitOp' num2str(i)],'Position',[xx yy-10 xx+40 yy+30], 'ShowName','Off', 'Operator', 'OR', 'Operand2', [UStr num2str(2^(N_in-i)) ')']);
          add_block('built-in/Switch',[h '/Switch' num2str(i)],  'Position',[xx+70 yy-10 xx+100 yy+100], 'Criteria','u2 ~= 0','ShowName','Off');
          add_line(h, ['BitOp' num2str(i) '/1'],['Switch' num2str(i) '/1']);
          add_line(h, ['BitIn' num2str(i) '/1'],['Switch' num2str(i) '/2']);
          add_line(h, ['Switch' num2str(i-1) '/1'],['BitOp' num2str(i) '/1']);
          add_line(h, ['Switch' num2str(i-1) '/1'],['Switch' num2str(i) '/3'], 'AUTOROUTING','ON');
      end;
      if Add_IntOut
         add_block('built-in/Outport',[h '/IntOut'], 'Position',[xx+140 yy+35 xx+160 yy+55], 'BackgroundColor','LightBlue');
      end;
      add_line(h, ['Switch' num2str(N_in) '/1'],['IntOut/1']);
  end;

% And finally redraw the front of the block
   out_labels = {};
   in_labels  = {};

   if (Pack==1)
      Title = 'disp(''Bit\nUnpacker'');';
      for i=1:N_out,
         out_labels(i) = {['port_label(''output'',' num2str(i) ',''Bit ' num2str(N_out-i) ''');']};
      end;
         in_labels = {['port_label(''input'',' num2str(1) ',''Input'');']};
   else
      Title = 'disp(''Bit\nPacker'');';
      for i=1:N_in,
         in_labels(i) = {['port_label(''input'',' num2str(i) ',''Bit ' num2str(N_in-i) ''');']};
     end;
         out_labels = {['port_label(''output'',' num2str(1) ',''Output'');']};
   end;
   display = {'patch([0.3 0.3 0.7 0.7], [0.35 0.65 0.65 0.35], [255/255 127/255 255/255])',
              char(Title),
              '',
              char(in_labels),
              char(out_labels)};
   set_param(h,'MaskDisplay',char(display));
end;