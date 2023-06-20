saveVarsMat = load('export.mat');

fields = fieldnames(saveVarsMat);

for ii = 1:length(fields)
   calib_name = fields{ii};
   old_data = saveVarsMat.(calib_name);
   
   new_data = Simulink.Parameter;
   
   new_data.DataType = old_data.DataType;
   description = old_data.Description;
   description(double(description) < 32) = ''; % Clear ASCII characters that are not letters, numbers or symbols
   new_data.Description = description;
   new_data.Min = old_data.Min;
   new_data.Max = old_data.Max;
   new_data.Unit = old_data.Unit;
   new_data.Value = old_data.Value;
   new_data.CoderInfo.StorageClass = 'ExportedGlobal';
   
   eval([calib_name ' = new_data']);
end

clear saveVarsMat old_data new_data ii fields data description calib_name;
