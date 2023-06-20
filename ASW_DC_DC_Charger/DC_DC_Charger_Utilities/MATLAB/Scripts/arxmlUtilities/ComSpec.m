classdef ComSpec < handle
    %Unit this contains all the properties of an AUTOSAR unit
    
    properties
        handleOutOfRange
        usesEndToEndProt
        initValue
        refElement
    end
    
    methods
        %% construtor 
        function obj = ComSpec(refElement)
            %Constructor of class
            obj.refElement = refElement;
        end
        
        %% getter setters
        
       function set.handleOutOfRange(obj,string)
            %setter for property handleOutOfRange
            if(~isempty(string))
                obj.handleOutOfRange = string;
            else
                disp(['Warning: trying to assign empty string to propery "handleOutOfRange" of object: ',obj.name])
            end
        end
        
        function val = get.handleOutOfRange(obj)
            %getter for property handleOutOfRange
            if(~isempty(obj.handleOutOfRange))
                val = obj.handleOutOfRange;
            else
                val = obj.handleOutOfRange;
            end
        end
        
        function set.usesEndToEndProt(obj,string)
            %setter for property usesEndToEndProt
            if(~isempty(string))
                obj.usesEndToEndProt = string;
            else
                %disp(['Warning: trying to assign empty string to propery "usesEndToEndProt" of object: ',obj.name])
            end
        end
 
        function val = get.usesEndToEndProt(obj)
            %getter for property usesEndToEndProt
            if(~isempty(obj.usesEndToEndProt))
                val = obj.usesEndToEndProt;
            else
                val = obj.usesEndToEndProt;
            end
        end
        
        function set.initValue(obj,string)
            %setter for property initValue
            if(~isempty(string))
                obj.initValue = string;
            else
                disp(['Warning: trying to assign empty string to propery "initValue" of object: ',obj.name])
            end
        end
 
        function val = get.initValue(obj)
            %getter for property initValue
            if(~isempty(obj.initValue))
                val = obj.initValue;
            else
                val = obj.initValue;
            end
        end
        
        function set.refElement(obj,string)
            %setter for property refElement
            if(~isempty(string))
                obj.refElement = string;
            else
                disp(['Warning: trying to assign empty string to propery "refElement" of object: ',obj.refElement])
            end
        end
 
        function val = get.refElement(obj)
            %getter for property initValue
            if(~isempty(obj.refElement))
                val = obj.refElement;
            else
                val = obj.refElement;
            end
        end
        
        %%  validate block
        function err = validate(obj)
           %checks that all the poperties of the class are correct

            %check that handleOutOfRange is assigned 
            if(isempty(obj.handleOutOfRange))
                 disp(['Warning: ',obj.refElement,' does not have property "handleOutOfRange" defined']);
                err = 1;
            else
                 if(~strcmp(obj.handleOutOfRange,'NONE'))
                     disp(['Warning: ',obj.refElement,' property "handleOutOfRange" is defined incorrectly as ',obj.handleOutOfRange,' it should be set to NONE']);
                 end
            end

            %check that usesEndToEndProt is assigned
            if(isempty(obj.usesEndToEndProt))
                disp(['Warning: ',obj.refElement,' does not have property "usesEndToEndProt" defined']);
                err = 1;
            else
                if(~strcmp(obj.usesEndToEndProt,'false'))
                     disp(['Warning: ',obj.refElement,' property "usesEndToEndProt" is defined incorrectly as ',obj.usesEndToEndProt,' it should be set to false']);
                end
            end
            
            %% validate children
            %check that inital value is defined
            if(isempty(obj.initValue))
                disp(['Warning: ',obj.refElement,' does not have a initValue defined']);
                err = 1;
            else
                %validate com spec
                obj.initValue.validate;
            end
            
        end
    end
end

