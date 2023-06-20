classdef Interface < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        isService
        serviceKind
        dataElements
    end
    
    methods
        %% construtor 
        function obj = Interface(package,name)
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
        
         function set.isService(obj,string)
            %setter for property isService
            if(~isempty(string))
                obj.isService = string;
            else
                disp(['Warning: trying to assign empty string to propery "isService" of object: ',obj.name])
            end
        end
        
        function val = get.isService(obj)
            %getter for property isService
            if(~isempty(obj.isService))
                val = obj.isService;
            else
                val = obj.isService;
            end
        end

       function set.dataElements(obj,string)
            %setter for property dataElements
            if(~isempty(string))
                obj.dataElements = string;
            else
                disp(['Warning: trying to assign empty string to propery "dataElements" of object: ',obj.name])
            end
        end
        
        function val = get.dataElements(obj)
            %getter for property typeEmitter
            if(~isempty(obj.dataElements))
                val = obj.dataElements;
            else
                val = obj.dataElements;
            end
        end
        
        function set.serviceKind(obj,string)
            %setter for property serviceKind
            if(~isempty(string))
                obj.serviceKind = string;
            else
                %disp(['Warning: trying to assign empty string to propery "serviceKind" of object: ',obj.name])
            end
        end
        
        function val = get.serviceKind(obj)
            %getter for property serviceKind
            if(~isempty(obj.serviceKind))
                val = obj.serviceKind;
            else
                val = obj.serviceKind;
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
            
            %check that package is correct
            if(~strcmp(obj.package,'/Interfaces/SenderReceiverInterfaces/') &&  ~strcmp(obj.package,'/Interfaces/ClientServerInterfaces/') && ~strcmp(obj.package,'/Interfaces/ModeSwitchInterfaces/'))
                disp(['Warning: ',obj.name,' is located in the wrong package: ',obj.package]);
                err = 1;
            end
            
            %TODO: verify this works with client server and mode switch interfaces
            
            %check that catagory exists and that corresponding properties are defined 
            if(isempty(obj.isService))
                disp(['Warning: ',obj.name,' does not have property "isService" defined']);
                err = 1;
            else
                if(strcmp(obj.isService,'true'))
                    if(isempty(obj.serviceKind))
                        disp(['Warning: ',obj.name,' has "isService" set to true but serviceKind is undefined']);
                        err = 1;
                    end
                end
            end
               
                        
            %% validate children
            %check that dataElements set is defined
            if(isempty(obj.dataElements))
                disp(['Warning: ',obj.name,' does not have a element defined']);
                err = 1;
            elseif(length(obj.dataElements)>1)
                disp(['Warning: ',obj.name,' has more that one element defined']);
                for(ii = 1:length(obj.dataElements))
                    %validate data constraint
                    obj.dataElements{ii}.validate;
                end
            else
                for(ii = 1:length(obj.dataElements))
                    %validate data constraint
                    obj.dataElements{ii}.validate;
                end
            end
            
            

        end
        
    end
end

