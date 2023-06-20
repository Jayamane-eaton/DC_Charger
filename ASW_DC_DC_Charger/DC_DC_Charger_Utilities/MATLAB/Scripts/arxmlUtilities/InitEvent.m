classdef InitEvent < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        runnables

    end
    
    methods
        %% construtor
        function obj = InitEvent(package,name)
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

