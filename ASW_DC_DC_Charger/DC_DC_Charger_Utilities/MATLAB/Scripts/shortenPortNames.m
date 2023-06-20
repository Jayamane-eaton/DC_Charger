function shortenPortNames
% shortenPortNames Remove duplicated strings from port names when creating
% a Simulink model from an SwC ARXML

H = gcs;
ports = find_system(H, 'LookUnderMasks', 'on', 'BlockType', 'Inport');
ports = cat(1,ports,find_system(H, 'LookUnderMasks', 'on',  'BlockType', 'Outport'));
for ii = 1:length(ports)
    portName = get_param(ports{ii},'Name');
    tokens = strsplit(portName,'_');
    tokensLength = length(tokens);
    jj = 0;
    while jj < tokensLength
        jj = jj + 1;
        if length(tokens{jj}) > 1 % Only remove substrings larger than 1 to avoid removing P_ and R_ from the port name
            if length(find(not(cellfun('isempty',strfind(tokens,tokens{jj}))))) > 1 % Check for repeated substring
                tokens(jj) = []; % Remove repeated substring from cell array
                tokensLength = tokensLength - 1;
                jj = jj - 1;
            end
        end
    end
    set_param(ports{ii},'Name',strjoin(tokens,'_')); % Concatenate remaining substrings
end