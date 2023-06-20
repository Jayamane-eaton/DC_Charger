classdef TimingEvent < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        period
        disabledModeRefs
        runnables

    end
    
    methods
        %% construtor
        function obj = TimingEvent(package,name)
            %Constructor of class
            obj.package = package;
            obj.name = name;
            
        end
        
        %% getter setters
        function set.package(obj,string)
            %setter for property package
            if(~isempty(string))
                obj.package = string;
            else
                disp(['Warning: trying to assign empty string to propery "package" of object: ',obj.name])
            end
        end
        
        
        function val = get.package(obj)
            %getter for property package
            if(~isempty(obj.name))
                val = obj.package;
            else
                val = obj.package;
            end
        end
        
        function set.name(obj,string)
            %setter for property name
            if(~isempty(string))
                obj.name = string;
            else
                disp(['Warning: trying to assign empty string to propery "name" of object: ',obj.name])
            end
        end
        
        function val = get.name(obj)
            %getter
            if(~isempty(obj.name))
                val = obj.name;
            else
                val = obj.name;
            end
        end
        
        function set.period(obj,string)
            %setter for property period
            if(~isempty(string))
                obj.period = string;
            else
                disp(['Warning: trying to assign empty string to propery "period" of object: ',obj.name])
            end
        end
        
        function val = get.period(obj)
            %getter for property period
            if(~isempty(obj.period))
                val = obj.period;
            else
                val = obj.period;
            end
        end
        
        function set.disabledModeRefs(obj,string)
            %setter for property disabledModeRefs
            if(~isempty(string))
                obj.disabledModeRefs = string;
            else
                disp(['Warning: trying to assign empty string to propery "disabledModeRefs" of object: ',obj.name])
            end
        end
        
        function val = get.disabledModeRefs(obj)
            %getter for property disabledModeRefs
            if(~isempty(obj.disabledModeRefs))
                val = obj.disabledModeRefs;
            else
                val = obj.disabledModeRefs;
            end
        end
        
        function set.runnables(obj,string)
            %setter for property runnables
            if(~isempty(string))
                obj.runnables = string;
            else
                disp(['Warning: trying to assign empty string to propery "runnables" of object: ',obj.name])
            end
        end
        
        function val = get.runnables(obj)
            %getter for property runnables
            if(~isempty(obj.runnables))
                val = obj.runnables;
            else
                val = obj.runnables;
            end
        end
        

        %%  validate block
        function err = validate(obj)
            %checks that all the poperties of the class are correct
            
            %disp(['Validating: ',obj.name])
            err = 0;
            
            %check that package is assigned
            if(isempty(obj.package))
                disp(['Warning: ',obj.package,' does not have a package defined']);
                err = 1;
            end
            
            %check that name is assigned
            if(isempty(obj.name))
                disp(['Warning: ',obj.name,' does not have a name defined']);
                err = 1;
            end
            
            %check period
            if(isempty(obj.period))
                disp(['Warning: ',obj.name,' does not have a period defined']);
                err = 1;
            end
            
            %check that data type mapping set is defined
            if(isempty(obj.disabledModeRefs))
                disp(['Warning: ',obj.name,' does not have a disabledModeRefs defined']);
                err = 1;
            else
                
                requiredModeRefs = {'/AUTOSAR/EcuM/ModeDeclarationGroups/EcuM_Mode/STARTUP';...
                    '/AUTOSAR/EcuM/ModeDeclarationGroups/EcuM_Mode/POST_RUN';...
                    '/AUTOSAR/EcuM/ModeDeclarationGroups/EcuM_Mode/SLEEP';...
                    '/AUTOSAR/EcuM/ModeDeclarationGroups/EcuM_Mode/WAKE_SLEEP';...
                    '/AUTOSAR/EcuM/ModeDeclarationGroups/EcuM_Mode/SHUTDOWN'};
                
                for(jj = 1:length(requiredModeRefs))
                    foundModeRef = false;
                    
                    %validate data constraint
                    for(ii=1:length(obj.disabledModeRefs))
                        if(strcmp(obj.disabledModeRefs{ii}.TargetModeDisableRef,requiredModeRefs{jj}))
                            foundModeRef = true;
                        end
                    end
                    
                    %if mode ref is not found then Warning should be thrown
                    if(foundModeRef==false)
                        disp(['Warning: ',obj.name,' missing disabling mode ref ',requiredModeRefs{jj}]);
                    end
                    
                end
            end
            
            %% validate children

            
            %check that runnables is defined
            if(isempty(obj.runnables))
                disp(['Warning: ',obj.name,' does not have a runnables defined']);
                err = 1;
            else
                %validate data constraint
                for(ii=1:length(obj.runnables))
                    obj.runnables{ii}.validate;
                end
                
            end
            

            
            
        end
    end
end

