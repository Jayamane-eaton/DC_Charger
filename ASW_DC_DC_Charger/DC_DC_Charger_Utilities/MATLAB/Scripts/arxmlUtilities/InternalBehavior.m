classdef InternalBehavior < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        supportsMultipleInst
        dataTypeMappingSets
        timingEvents
        initEvents
    end
    
    methods
        %% construtor
        function obj = InternalBehavior(package,name)
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
        
        function set.supportsMultipleInst(obj,string)
            %setter for property supportsMultipleInst
            if(~isempty(string))
                obj.supportsMultipleInst = string;
            else
                disp(['Warning: trying to assign empty string to propery "supportsMultipleInst" of object: ',obj.name])
            end
        end
        
        function val = get.supportsMultipleInst(obj)
            %getter for property supportsMultipleInst
            if(~isempty(obj.supportsMultipleInst))
                val = obj.supportsMultipleInst;
            else
                val = obj.supportsMultipleInst;
            end
        end
        
        function set.dataTypeMappingSets(obj,string)
            %setter for property dataTypeMappingSets
            if(~isempty(string))
                obj.dataTypeMappingSets = string;
            else
                disp(['Warning: trying to assign empty string to propery "dataTypeMappingSets" of object: ',obj.name])
            end
        end
        
        function val = get.dataTypeMappingSets(obj)
            %getter for property dataTypeMappingSets
            if(~isempty(obj.dataTypeMappingSets))
                val = obj.dataTypeMappingSets;
            else
                val = obj.dataTypeMappingSets;
            end
        end
        
        function set.timingEvents(obj,string)
            %setter for property timingEvents
            if(~isempty(string))
                obj.timingEvents = string;
            else
                disp(['Warning: trying to assign empty string to propery "timingEvents" of object: ',obj.name])
            end
        end
        
        function val = get.timingEvents(obj)
            %getter for property timingEvents
            if(~isempty(obj.timingEvents))
                val = obj.timingEvents;
            else
                val = obj.timingEvents;
            end
        end
        
        function set.initEvents(obj,string)
            %setter for property initEvents
            if(~isempty(string))
                obj.initEvents = string;
            else
                disp(['Warning: trying to assign empty string to propery "initEvents" of object: ',obj.name])
            end
        end
        
        function val = get.initEvents(obj)
            %getter for property initEvents
            if(~isempty(obj.initEvents))
                val = obj.initEvents;
            else
                val = obj.initEvents;
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
            
            %check supportsMultipleInst
            if(isempty(obj.supportsMultipleInst))
                disp(['Warning: ',obj.name,' does not have a supportsMultipleInst defined']);
                err = 1;
            else
                if(strcmp(obj.supportsMultipleInst,'true'))
                   disp(['Warning: ',obj.name,' has supportsMultipleInst defined as true']); 
                end
            end
            
            %% validate children
            %check that data type mapping set is defined
            if(isempty(obj.dataTypeMappingSets))
                disp(['Warning: ',obj.name,' does not have a dataTypeMappingSets defined']);
                err = 1;
            else
                %validate data constraint
                for(ii = 1:length(obj.dataTypeMappingSets))
                    obj.dataTypeMappingSets{ii}.validate;
                end
            end
            
            %check that timingEvents is defined
            if(isempty(obj.timingEvents))
                disp(['Warning: ',obj.name,' does not have a timingEvents defined']);
                err = 1;
            else
                %validate data constraint
                for(ii=1:length(obj.timingEvents))
                    obj.timingEvents{ii}.validate;
                end
                
            end
            
            %check that initEvents is defined
            if(isempty(obj.initEvents))
                disp(['Warning: ',obj.name,' does not have a initEvents defined']);
                err = 1;
            else
                %validate data constraint
                for(ii=1:length(obj.initEvents))
                    obj.initEvents{ii}.validate;
                end
                
            end
            
            
        end
    end
end

