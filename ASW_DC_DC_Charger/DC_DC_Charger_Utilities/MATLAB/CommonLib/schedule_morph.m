%--------------------------------------------------------------------------
% Filename: schedule_morph.m
%
% Description: Performs self-modification on Simulink scheduler block.
% Diagram is built to create appropriate trigger signals based on mask
% arguments and number of desired triggers.
%
% Author: L J Brackney   NgEK, Inc.
% Date:   7/15/2005
%
% Arguments
%   NTriggers - Number of subsystems to trigger
%   DType:
%       1 - Boolean output suitable for triggering enabled subsystems
%       2 - Fcn_call output suitable for triggering fcn_call subsystems
%   Style:
%       1 - Round-robin: one task is executed each frame
%       2 - Sequenced: all tasks are executed each frame in order
%   State:
%       0 - Do not display scheduler state (current task number)
%       1 - Display scheduler state (current task number)
%--------------------------------------------------------------------------

h = gcb;                          % Shorthand for block handle
N_out = Number;

% Get list of blocks and lines in scheduler
lb = find_system(h, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'on', 'type', 'block');
ll = find_system(h, 'SearchDepth', 1, 'FollowLinks', 'on', 'FindAll', 'on', 'LookUnderMasks','on', 'type', 'line');

% Determine if mask has changed since last update
MaskChanged = false;

% Detect if Style has changed
FoundFcnTrigger = false;
FoundState      = false;
FoundDemux      = false;
for i=1:length(lb),
     blkname = lb{i};  
     if ~(isempty(findstr(blkname,'FCNTrigger')))
        FoundFcnTrigger = true; 
     end;
     if ~(isempty(findstr(blkname,'State')))  
        FoundState = true;
     end; 
     if ~(isempty(findstr(blkname,'Demux')))
        FoundDemux = true; 
     end;
end;

if (State==1) && ~FoundState
    MaskChanged = true;                         % State output was selected but is not present
elseif (State==0) && FoundState
    MaskChanged = true;                         % State output wasn't selected but is present
end;

if (Style==1)
   for i=1:length(lb),
        blkname = char(lb(i));    
        if ~(isempty(findstr(blkname,'Terminator'))) || ~(isempty(findstr(blkname,'Demux')))
            MaskChanged = true;                 % Style is 1 but block was last built for Style 2
        end;
   end;
   if (DType==1) && FoundFcnTrigger
       MaskChanged = true;                      % Type is Boolean but block was last built for fcn_call
   end;
   if (DType==1) && ~FoundDemux
      MaskChanged = true;                       % Type is Boolean but block was last built for fcn_call
   end;
   if (DType==2) && ~FoundFcnTrigger            % Type is fcn_call but block was last built for boolean
      MaskChanged = true;
   end;
else
   for i=1:length(lb),
        blkname = char(lb(i));    
        if ~(isempty(findstr(blkname,'Switch'))) 
            MaskChanged = true;                 % Style is 2 but block was last built for Style 1
        end;
   end;
   if (DType==1) && FoundDemux
      MaskChanged = true;                       % Type is Boolean but block was last built for fcn_call
   end;
   if (DType==2) && ~FoundDemux
      MaskChanged = true;                       % Type is fcn_call but block was last built for Boolean
   end;
end;

% Detect if number of outputs has changed
x         = get_param(h, 'Ports');
N_out_old = x(2);
if FoundState
   Old_Num_Tasks = N_out_old - 1;
else
   Old_Num_Tasks = N_out_old;
end;
if ~(N_out==Old_Num_Tasks)
   MaskChanged = true;
end;
    
if MaskChanged                                     % Only rebuild diagram if mask has changed
   while ~(isempty(ll)),                           % Remove any lines
         delete_line(ll(1));
         ll = find_system(h, 'SearchDepth', 1, 'FollowLinks', 'on', 'FindAll', 'on', 'LookUnderMasks','on', 'type', 'line');
   end;

   if ~(isempty(lb))                               % Remove the old blocks
       for i=1:length(lb),
           blkname = char(lb(i));
           if ~(isempty(findstr(blkname,'Task')))
              if (str2num(get_param(blkname,'Port')) > N_out)
                 delete_block(blkname)
              end;
           end;
           if ~(isempty(findstr(blkname,'State')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Sum')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Switch')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Compare')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'TRUE')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Number')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'FALSE')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'FCNTrigger')))
              delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Constant')))
               delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Terminator')))
               delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Mux')))
               delete_block(blkname)
           end;
           if ~(isempty(findstr(blkname,'Demux')))
               delete_block(blkname)
           end;    
           if ~(isempty(findstr(blkname,'Function-Call Generator')))
               delete_block(blkname)
           end;  
           if ~(isempty(findstr(blkname,'Counter')))
               delete_block(blkname)
           end;
       end;
   end;
  
   x0 = 40; y0 = 40;                                               % Specify upper corner of the diagram
 
   if (Style==1)                                                   % Add blocks and lines for Style 1
      add_block('common_lib/OS/schedule counter',[h '/Counter'],'Position',[x0+75 y0+(N_out-1)*75-40 x0+175 y0+(N_out-1)*75+40],'BackgroundColor','Cyan','ShowName','Off');
      for i=1:N_out,
          yy=y0+(i-1)*120;
          if (i>Old_Num_Tasks)
             add_block('built-in/Outport',[h '/Task ' num2str(i)], 'Position',[x0+470 yy+30 x0+490 yy+50], 'BackgroundColor','LightBlue');
          else
             set_param([h '/Task ' num2str(i)], 'Position',[x0+470 yy+30 x0+490 yy+50]);
          end;
          add_block('built-in/Switch',[h '/Switch' num2str(i)],  'Position',[x0+330 yy-10 x0+350 yy+90], 'Criteria','u2 ~= 0','ShowName','Off');
          add_block('built-in/Relational Operator',[h '/Compare' num2str(i)], 'Position',[x0+280 yy+30 x0+300 yy+50],'Operator','==','ShowName','Off');
          add_block('built-in/Constant',[h '/TRUE' num2str(i)], 'Position',[x0+210 yy-5 x0+250 yy+15], 'BackgroundColor','Yellow', 'Value','TRUE','ShowName','Off');
          add_block('built-in/Constant',[h '/Number' num2str(i)], 'Position',[x0+210 yy+35 x0+250 yy+55], 'BackgroundColor','Yellow', 'Value',['int8(' num2str(i) ')'],'ShowName','Off');
          add_block('built-in/Constant',[h '/FALSE' num2str(i)], 'Position',[x0+210 yy+65 x0+250 yy+85], 'BackgroundColor','Yellow', 'Value','FALSE','ShowName','Off');
          if (DType==2)
             add_block('common_lib/OS/fcn_call generator',[h '/FCNTrigger' num2str(i)], 'Position',[x0+370 yy+60 x0+430 yy+90], 'BackgroundColor','Cyan','ShowName','Off');
          end;  
          add_line(h, ['Compare' num2str(i) '/1' ],['Switch' num2str(i) '/2']);
          add_line(h, ['TRUE' num2str(i) '/1' ],['Switch' num2str(i) '/1']);
          add_line(h, ['Number' num2str(i) '/1' ],['Compare' num2str(i) '/2']);
          add_line(h, ['FALSE' num2str(i) '/1' ],['Switch' num2str(i) '/3']);
          add_line(h, ['Counter/1' ],['Compare' num2str(i) '/1'],'AUTOROUTING','ON');
          if (DType==1)
             add_line(h, ['Switch' num2str(i) '/1' ],['Task ' num2str(i) '/1']);
          else
             add_line(h, ['Switch' num2str(i) '/1' ],['FCNTrigger' num2str(i) '/Enable'],'AUTOROUTING','ON'); 
             add_line(h, ['FCNTrigger' num2str(i) '/1' ],['Task ' num2str(i) '/1'],'AUTOROUTING','ON'); 
          end;
      end;
      if (State==1)                                                % Wire up state port if requested
         add_block('built-in/Outport',[h '/State'], 'Position',[x0+470 y0+N_out*120+30 x0+490 y0+N_out*120+50], 'BackgroundColor','LightBlue');
         add_line(h, ['Counter/1' ],['State/1'],'AUTOROUTING','ON');
      end;   
   else                                                            % Add blocks and lines for Style 2  
      if (State==1)                                                % Add state port if requested
         add_block('built-in/Mux',[h '/Mux'], 'Position',[x0+400 y0+N_out*120-70 x0+405 y0+N_out*120+145], 'BackgroundColor','Black', 'ShowName','Off', 'Inputs',num2str(N_out));
      end;
      if (DType ==1)
         add_block('built-in/Constant',[h '/Constant'],'Position',[x0+50 y0+45 x0+100 y0+65],'Value','int8(0)','BackgroundColor','Yellow','ShowName','Off');
         add_block('built-in/Terminator',[h '/Terminator'],'Position',[x0+270 y0+(N_out-1)*120+55 x0+290 y0+(N_out-1)*120+75],'ShowName','Off');
         for i=1:N_out,
             yy=y0+(i-1)*120;
             if (i>Old_Num_Tasks)
                add_block('built-in/Outport',[h '/Task ' num2str(i)], 'Position',[x0+470 yy+30 x0+490 yy+50], 'BackgroundColor','LightBlue');
             else
                set_param([h '/Task ' num2str(i)], 'Position',[x0+470 yy+30 x0+490 yy+50]);
             end;
             add_block('common_lib/OS/sequence generator',[h '/FCNTrigger' num2str(i)], 'Position',[x0+170 yy+25 x0+230 yy+75], 'BackgroundColor','Cyan','ShowName','Off');
             add_line(h, ['FCNTrigger' num2str(i) '/1' ],['Task ' num2str(i) '/1'],'AUTOROUTING','ON'); 
         end;
         if (State==1)                                                % Add state port if requested
            add_block('built-in/Outport',[h '/State'], 'Position',[x0+470 y0+N_out*120+30 x0+490 y0+N_out*120+50], 'BackgroundColor','LightBlue');
            add_block('built-in/Sum',[h '/Sum'], 'Position',[x0+430 y0+N_out*120+30 x0+450 y0+N_out*120+50], 'IconShape','Round', 'ListOfSigns','1', 'ShowName','Off');
            add_line(h, 'Sum/1', 'State/1');
            add_line(h, 'Mux/1', 'Sum/1');
         end;    
         add_line(h,'Constant/1','FCNTrigger1/1');
         for i=1:N_out-1,
             add_line(h, ['FCNTrigger' num2str(i) '/2' ],['FCNTrigger' num2str(i+1) '/1' ],'AUTOROUTING','ON');
             if (State==1)
                add_line(h, ['FCNTrigger' num2str(i) '/2' ],['Mux/' num2str(i) ],'AUTOROUTING','ON');
             end;
         end;
         add_line(h,['FCNTrigger' num2str(N_out) '/2' ],'Terminator/1','AUTOROUTING','ON');
         if (State==1)
            add_line(h, ['FCNTrigger' num2str(N_out) '/2' ],['Mux/' num2str(N_out) ],'AUTOROUTING','ON');
         end;
      else
         add_block('common_lib/Approved Simulink/SubSys Triggers/Function-Call Generator',[h '/Function-Call Generator'], 'Position',[x0+70 y0+30*N_out x0+120 y0+20+30*N_out] ,'ShowName','Off', 'sample_time','-1');
         add_block('built-in/Demux',[h '/Demux'], 'Position',[x0+170 y0+10 x0+175 y0+10+60*N_out], 'Outputs',num2str(N_out), 'ShowName','Off', 'Backgroundcolor','Black');
         add_line(h,'Function-Call Generator/1','Demux/1','AUTOROUTING','ON');
         for i=1:N_out,
            yy=y0+(i-1)*60;
            if (i>Old_Num_Tasks)
               add_block('built-in/Outport',[h '/Task ' num2str(i)], 'Position',[x0+270 yy+30 x0+290 yy+50], 'BackgroundColor','LightBlue');
            else
               set_param([h '/Task ' num2str(i)], 'Position',[x0+270 yy+30 x0+290 yy+50]);
            end;
            add_line(h,['Demux/' num2str(i)],['Task ' num2str(i) '/1'],'AUTOROUTING','ON')
         end;
      end;
   end;
        
        
   % And finally redraw the front of the block
   out_labels = {};
   for i=1:N_out,
      out_labels(i) = {['port_label(''output'',' num2str(i) ',''Task ' num2str(i) ''');']};
   end;
   if (State==1)
       out_labels(N_out+1) = {['port_label(''output'',' num2str(N_out+1) ',''State'');']};
   end;
   display = {'patch([0.3 0.3 0.7 0.7], [0.35 0.65 0.65 0.35], [255/255 127/255 255/255])',
              'disp(''Scheduler'');',
              '',
   char(out_labels)};
   set_param(h,'MaskDisplay',char(display));
end;