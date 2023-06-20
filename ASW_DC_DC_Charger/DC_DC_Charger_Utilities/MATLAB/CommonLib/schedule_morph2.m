%--------------------------------------------------------------------------
% Filename: schedule_morph2.m
%
% Description: Performs self-modification on Simulink scheduler block.
% Diagram is built to create appropriate trigger signals based on number
% of desired triggers.
%
% Author: L J Brackney   NgEK, Inc.
% Date:   4/26/2006
%
% Arguments
%   NTriggers - Number of subsystems to trigger
%--------------------------------------------------------------------------

h = gcb;                          % Shorthand for block handle
N_out = Number+1;

% Get list of blocks and lines in scheduler
lb = find_system(h, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'on', 'type', 'block');
ll = find_system(h, 'SearchDepth', 1, 'FollowLinks', 'on', 'FindAll', 'on', 'LookUnderMasks','on', 'type', 'line');

% Determine if mask has changed since last update
MaskChanged = false;

% Detect if number of outputs has changed
x         = get_param(h, 'Ports');
N_out_old = x(2);
if ~(N_out==N_out_old)
   MaskChanged = true;
end;
    
if MaskChanged                                     % Only rebuild diagram if number of tasks has changed
   while ~(isempty(ll)),                           % Remove any lines
         delete_line(ll(1));
         ll = find_system(h, 'SearchDepth', 1, 'FollowLinks', 'on', 'FindAll', 'on', 'LookUnderMasks','on', 'type', 'line');
   end;

   if ~(isempty(lb))                               % Remove the old blocks
       for i=1:length(lb),
           blkname = char(lb(i));
           if ~(isempty(findstr(blkname,'Task')))
              if (str2num(get_param(blkname,'Port')) > N_out+1)
                 delete_block(blkname)
              end;
           end;
           if ~(isempty(findstr(blkname,'Function-Call Generator')))
               delete_block(blkname)
           end;  
           if ~(isempty(findstr(blkname,'Demux')))
               delete_block(blkname)
           end;    
       end;
   end;
  
   x0 = 40; y0 = 40;                                               % Specify upper corner of the diagram
 
   add_block('common_lib/Approved Simulink/SubSys Triggers/Function-Call Generator',[h '/Function-Call Generator'], 'Position',[x0+70 y0+30*N_out x0+120 y0+20+30*N_out] ,'ShowName','Off', 'sample_time','-1');
   add_block('built-in/Demux',[h '/Demux'], 'Position',[x0+170 y0+10 x0+175 y0+10+60*N_out], 'Outputs',num2str(N_out), 'ShowName','Off', 'Backgroundcolor','Black');
   add_line(h,'Function-Call Generator/1','Demux/1','AUTOROUTING','ON');
   add_line(h,'Init Relay/1','Init/1','AUTOROUTING','ON');
   add_line(h,'Demux/1','Init Relay/Trigger','AUTOROUTING','ON');
   
   for i=1:Number,
      yy=y0+(i)*60;
      if (i>N_out_old-1)
         add_block('built-in/Outport',[h '/Task ' num2str(i)], 'Position',[x0+270 yy+30 x0+290 yy+50], 'BackgroundColor','LightBlue');
      else
         set_param([h '/Task ' num2str(i)], 'Position',[x0+270 yy+30 x0+290 yy+50]);
      end;
      add_line(h,['Demux/' num2str(i+1)],['Task ' num2str(i) '/1'],'AUTOROUTING','ON')
   end;
       
   % And finally redraw the front of the block
   out_labels = {};
   out_labels(1) = {['port_label(''output'',1,''Init'');']};
   for i=2:N_out,
      out_labels(i) = {['port_label(''output'',' num2str(i) ',''Task ' num2str(i-1) ''');']};
   end;
   display = {'patch([0.3 0.3 0.7 0.7], [0.35 0.65 0.65 0.35], [255/255 127/255 255/255])',
              'disp(''Scheduler\nwith Init'');',
              '',
   char(out_labels)};
   set_param(h,'MaskDisplay',char(display));
end;