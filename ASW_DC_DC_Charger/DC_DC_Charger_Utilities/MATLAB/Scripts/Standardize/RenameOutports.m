% RenameOutports.m
%
%  Author:  J. Dunfee
%  Date:    02.22.2011
%
%   Description:    Script will rename the Outport name to the name of the  
%                   incoming signal and turn the showname property to on. If the signal name is
%                   blank the script will print out the name of the outport
%                   that has a blank signal coming into it.  Script runs
%                   recurrsively to all subsystems below the current
%                   subsystem that are not links.
%
%   Usage:          Open library and unlock then run script.  First
%                   time will rename outports to the input signal name if
%                   not an empty string and toggle the ShowName property of
%                   the outport.  This will allow you to see the Outport
%                   name if verification is required of name change.

% Add code to handle error id 'Simulink:SL_DupBlockName'


try
    outportList=find_system(gcs,'FindAll','on','FollowLinks','off','LookUnderMasks','all','BlockType','Outport');
    
    for i=1:length(outportList)
        showName=get(outportList(i),'ShowName');
        strName=strrep(strrep(char(get(outportList(i),'InputSignalNames')),'<',''),'>','');
        parent = get_param(outportList(i), 'Parent');
        portName    = get_param(outportList(i),'Name');
        
        if ~isempty(strName)
            if ~strcmp(portName, strName)
                try
                    disp(['Renaming Outport ''' parent '/' portName ''' to ''' strName '''']);
                    set(outportList(i),'Name',strName);
                catch err
                    copyBlock = [parent '/' strName];
                    blockType = get_param(copyBlock, 'BlockType');
                    if strcmp(blockType, 'Inport')
                        disp(['Renaming Inport ''' copyBlock ''' to ''' strName '_In''']);
                        set_param(copyBlock, 'Name', [strName '_In']);
                        set(outportList(i),'Name',strName);
                    elseif strcmp(blockType, 'BusCreator')
                        disp(['Renaming BusCreator ''' copyBlock ''' to ''' strName '_BC''']);
                        set_param(copyBlock, 'Name', [strName '_BC']);
                        set(outportList(i),'Name',strName);
                    else
                        disp(['Block already named ''' strName '''. Cannot rename outport ' parent '/' portName]);
                    end
                end
            end
        else
            disp(['*Unnamed signal to Outport ' parent '/' portName ]);
        end
        
        if(strcmp(showName,'on'))
            set(outportList(i),'ShowName','off');
        end
        
    end
    
catch ME  % Matlab Exception occured

   % Turn off all outport names if an error occured part way through
   % processing outports
   for i=1:max(size(outportList))
       b=get(outportList(i),'ShowName');
       if(strcmp(b,'on'))
           %disp(['Turning on port name ' get_param(outportList(i),'Name')]);
           set(outportList(i),'ShowName','off');
       end
   end
   
   rethrow(ME);
end


