classdef SWImp < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        package
        name
        progLanguage
        SWVersion     
    end
    
    methods
        %% construtor
        function obj = SWImp(package,name)
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
        
        function set.progLanguage(obj,string)
            %setter for property progLanguage
            if(~isempty(string))
                obj.progLanguage = string;
            else
                disp(['Warning: trying to assign empty string to propery "progLanguage" of object: ',obj.name])
            end
        end
        
        function val = get.progLanguage(obj)
            %getter for property progLanguage
            if(~isempty(obj.progLanguage))
                val = obj.progLanguage;
            else
                val = obj.progLanguage;
            end
        end
        
        function set.SWVersion(obj,string)
            %setter for property SWVersion
            if(~isempty(string))
                obj.SWVersion = string;
            else
                disp(['Warning: trying to assign empty string to propery "SWVersion" of object: ',obj.name])
            end
        end
        
        function val = get.SWVersion(obj)
            %getter for property SWVersion
            if(~isempty(obj.SWVersion))
                val = obj.SWVersion;
            else
                val = obj.SWVersion;
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
            
            %check that prog language is assigned
            if(isempty(obj.progLanguage))
                disp(['Warning: ',obj.name,' does not have a "progLanguage" defined']);
                err = 1;
            end
            
            %check that SWVersion is assigned
            if(isempty(obj.SWVersion))
                disp(['Warning: ',obj.name,' does not have a "SWVersion" defined']);
                err = 1;
            end
   
        end
    end
end

