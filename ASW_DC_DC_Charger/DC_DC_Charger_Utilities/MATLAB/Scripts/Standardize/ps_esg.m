function [] = ps_esg
%
%  ps_esg.m
%
%  Make fonts and colors for Subsystems match Eaton Style Guide format
%
%  Usage:  ps_esg
%
%  Jeff Dunfee
%

% Version Control System Header Information (automatically updated)
% -----------------------------------------------------------------
% $RCSFile: ps_esg.m,v $
% $Revision: 1.0 $
% $Author: J.Dunfee $
% $Date: 2008/12/10 $
% -----------------------------------------------------------------

h = gcs;

%get version release
vr = regexp(version('-release'),'\d+','match');
vrnum = str2num(vr{1});

% If no blocks are selected, then do on all subsystems in diagram
lst = find_system(h, 'Selected', 'on');
Nsel = length(lst);
if Nsel == 0
    sel = 'off';
else
    sel = 'on';
end

%find subsystems that are not linked
lst = find_system(h,'Selected',sel,'BlockType','SubSystem','ReferenceBlock','');
n = length(lst);

%find ports that use bus object assertion.
%find_system(gcs,'BlockType','Inport','UsebusObject','on')

if n > 0
    for i = 1:n  % the 1st element of the lst is the selected diagram itself
           %blkname=regexp(lst{i},'/','split');       
           %disp(blkname{length(blkname)});
           set_param(lst{i}, 'FontName', 'Arial')
           set_param(lst{i}, 'FontSize', '12')
           set_param(lst{i}, 'FontWeight', 'normal')
           %apply style guide custom color red=115/255; green=166/255; blue=196/255;
           set_param(lst{i}, 'ForegroundColor', 'black' )
           set_param(lst{i}, 'BackgroundColor', '[0.451, 0.651, 0.7686]')
           if vrnum >= 2008
               %Turned off for now because this does not work on ports using bus objects without bus
               %objects loaded into the workspace.  Leaving out to prevent
               %nuissance errors.
              %set_param(lst{i}, 'ShowPortLabels','FromPortIcon')
           else
              set_param(lst{i}, 'ShowPortLabels','on')
           end
     end
end
