classdef ArxmlReader < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        arxmlName
        SWCName
        InternalBehavior
        PPorts
        RPorts
        Constants
        SRInterfaces
        CSInterfaces
        MSInterfaces
        AppDataTypes
        AppDataConsts
        CompuMethods
        Units
        ImpDataTypes
        BaseTypes
        ModeDeclarationGroups
        DataTypeMappingSets
        SWImp
               
    end
    
    methods
        function obj = ArxmlReader(fileName)
            
            %extract path and name from fileName
            getFileDetails(obj,fileName);

            %Read in the ARXML file
            RootNode = xmlread(fileName);
            
            %extract the SWC name
            getSWCName(obj,RootNode);
            
            %get the internal behavor details
            getInternalBehavior(obj,RootNode);
            
            %get P-Ports details
            getPPorts(obj,RootNode);
            
            %get R-Ports details
            getRPorts(obj,RootNode);
            
            %get constant definitons
            getConstants(obj,RootNode);
            
            %get the S-R interfaces
            getSRInterfaces(obj,RootNode);
            
            %get the C-S interfaces
            %getCSInterfaces(obj, RootNode);
            
            %get the M-S interfaces
            getMSInterfaces(obj,RootNode);
            
            %find the application data types
            getAppDataTypes(obj,RootNode);
            
            %find the data constraints
            getAppDataConstraints(obj,RootNode)
            
            %get the compu methods
            getCompuMethods(obj,RootNode);
            
            %get the units
            getUnits(obj,RootNode);
            
            %get implmentaiton data types
            getImpDataTypes(obj,RootNode);
            
            %get the base types
            getBaseDataType(obj,RootNode);
            
            %get mode decleration groups
            getModeDeclerationGroups(obj,RootNode);
            
            %get the data type mapping sets
            getDataTypeMappingSets(obj,RootNode);
            
            %get the SW implementation details
            getSWImp(obj,RootNode);
            
        end

    end
    
    methods(Access = private)
        
        function getFileDetails(obj,string)
            
            %find seperator
            idx = strfind(string,'\');
            
            %get path to object
            path = string(1:idx(end));
            
            %get name of object
            name = string(idx(end)+1:end);
            
            %store value
            obj.arxmlName = name;
            
        end
        
        
        function getSWCName(obj,node)
            
            %find the SW compont node in the ARXML
            thisNode = node.getElementsByTagName('APPLICATION-SW-COMPONENT-TYPE');
            
            %get the short names of this node
            if(thisNode.getLength>0)
                names = obj.getNodeTextContent(thisNode.item(0),'SHORT-NAME');
                
                %store the name in the properties
                obj.SWCName = names{1};
            else
                obj.SWCName = [];
            end
            
        end
        
        function getInternalBehavior(obj,thisNode)
  
            %get the node
            InternalBehaviorNode = thisNode.getElementsByTagName('INTERNAL-BEHAVIORS');
            
            for ii = 0:InternalBehaviorNode.getLength-1
                %get the short names
                name = obj.getNodeTextContent(InternalBehaviorNode.item(ii),'SHORT-NAME');
                
                %store the name of the internal behavior
                obj.InternalBehavior{ii+1,1}.Name = name{1};
                
                %find datatype mapping refs
                DTMSRefsNode = InternalBehaviorNode.item(ii).getElementsByTagName('DATA-TYPE-MAPPING-REF');
                for jj = 0:DTMSRefsNode.getLength-1
                    obj.InternalBehavior{ii+1,1}.DTMSRefs{jj+1,1}.DataElementRef = char(DTMSRefsNode.item(jj).getTextContent);
                end
               
                %find timing events
                TimingEventsNode = InternalBehaviorNode.item(ii).getElementsByTagName('TIMING-EVENT');
                for jj = 0:TimingEventsNode.getLength-1
                    obj.InternalBehavior{ii+1,1}.TimingEvents{jj+1,1}.Name = obj.getNodeTextContent(TimingEventsNode.item(jj),'SHORT-NAME');
                    
                    %find the disabled mode ref node
                    DisableModeRefsNode = TimingEventsNode.item(jj).getElementsByTagName('DISABLED-MODE-IREF');
                    for kk = 0:DisableModeRefsNode.getLength-1
                        %extract the name of the disabling mode ref
                        obj.InternalBehavior{ii+1,1}.TimingEvents{jj+1,1}.DisabledModeRefs{kk+1,1}.TargetModeDisableRef = obj.getNodeTextContent(DisableModeRefsNode.item(kk),'TARGET-MODE-DECLARATION-REF');
                    end
                    
                    %get runnable reference and period
                    obj.InternalBehavior{ii+1,1}.TimingEvents{jj+1,1}.RunnableNames{1} = obj.getNodeTextContent(TimingEventsNode.item(ii),'START-ON-EVENT-REF');
                    obj.InternalBehavior{ii+1,1}.TimingEvents{jj+1,1}.Period = obj.getNodeTextContent(TimingEventsNode.item(ii),'PERIOD');
                    
                end
                
                %find init events
                InitEventsNode = InternalBehaviorNode.item(ii).getElementsByTagName('INIT-EVENT');
                for jj = 0:InitEventsNode.getLength-1
                    obj.InternalBehavior{ii+1,1}.InitEvents{jj+1}.Name = obj.getNodeTextContent(InitEventsNode.item(jj),'SHORT-NAME');
                    obj.InternalBehavior{ii+1,1}.InitEvents{jj+1}.RunnableNames{1} = obj.getNodeTextContent(InitEventsNode.item(0),'START-ON-EVENT-REF');
                end
                
                
                %find runnables node and extract the info
                RunnablesNode = InternalBehaviorNode.item(ii).getElementsByTagName('RUNNABLE-ENTITY');
                for jj = 0:RunnablesNode.getLength-1
                    names = obj.getNodeTextContent(RunnablesNode.item(jj),'SHORT-NAME');
                    if(ischar(names))
                        obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.Name = names;
                    else
                        obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.Name = names{1};
                    end
                    
                    obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.MinStartInterval = obj.getNodeTextContent(RunnablesNode.item(jj),'MINIMUM-START-INTERVAL');
                    obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.CanBeInvokedConcurenly = obj.getNodeTextContent(RunnablesNode.item(jj),'CAN-BE-INVOKED-CONCURRENTLY');
                    
                    %find data read access node
                    DataReadAccessNode = RunnablesNode.item(jj).getElementsByTagName('DATA-READ-ACCESSS');
                    
                    if(DataReadAccessNode.getLength>0)
                        
                        VariableAccessNode = DataReadAccessNode.item(0).getElementsByTagName('VARIABLE-ACCESS');
                        for kk =0:VariableAccessNode.getLength-1
                            obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.PortReadAccess{kk+1,1}.PortRef = obj.getNodeTextContent(VariableAccessNode.item(kk),'PORT-PROTOTYPE-REF');
                            
                            %get the elements
                            TargetDataPrototypeNode = VariableAccessNode.item(kk).getElementsByTagName('TARGET-DATA-PROTOTYPE-REF');
                            for mm =0:TargetDataPrototypeNode.getLength-1
                                obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.PortReadAccess{kk+1,1}.ElementReadAccess{mm+1,1}.TargetDataRef = obj.getNodeTextContent(VariableAccessNode.item(kk),'TARGET-DATA-PROTOTYPE-REF');
                            end
                            
                            
                        end
                    else
                        obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.PortReadAccess = [];
                        
                    end
                    
                    
                    
                    %find data write access node
                    DataWriteAccessNode = RunnablesNode.item(jj).getElementsByTagName('DATA-WRITE-ACCESSS');
                    
                    if(DataWriteAccessNode.getLength>0)
                        
                        VariableAccessNode = DataWriteAccessNode.item(0).getElementsByTagName('VARIABLE-ACCESS');
                        for kk =0:VariableAccessNode.getLength-1
                            obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.PortWriteAccess{kk+1,1}.PortRef = obj.getNodeTextContent(VariableAccessNode.item(kk),'PORT-PROTOTYPE-REF');
                            
                            %get the elements
                            TargetDataPrototypeNode = VariableAccessNode.item(kk).getElementsByTagName('TARGET-DATA-PROTOTYPE-REF');
                            for mm =0:TargetDataPrototypeNode.getLength-1
                                obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.PortWriteAccess{kk+1,1}.ElementReadAccess{mm+1,1}.TargetDataRef = obj.getNodeTextContent(VariableAccessNode.item(kk),'TARGET-DATA-PROTOTYPE-REF');
                            end
                        end
                        
                    else
                        obj.InternalBehavior{ii+1,1}.Runnables{jj+1}.PortWriteAccess = [];
                    end
                    
                end
                
                obj.InternalBehavior{ii+1,1}.SupportsMultipleInst = obj.getNodeTextContent(thisNode,'SUPPORTS-MULTIPLE-INSTANTIATION');
            end
        end
        
        
        function getPPorts(obj,thisNode)
            
            %find P-Port node and retrieve details
            PPortNode = thisNode.getElementsByTagName('P-PORT-PROTOTYPE');
            for ii = 0:PPortNode.getLength-1
                obj.PPorts{ii+1,1}.Name = obj.getNodeTextContent(PPortNode.item(ii),'SHORT-NAME');
                obj.PPorts{ii+1,1}.InterfaceRef = obj.getNodeTextContent(PPortNode.item(ii),'PROVIDED-INTERFACE-TREF');
                
                %find com spec node and retrieve details
                comSpecNode = PPortNode.item(ii).getElementsByTagName('NONQUEUED-SENDER-COM-SPEC');
                for jj = 0:comSpecNode.getLength-1
                    obj.PPorts{ii+1,1}.ComSpecs{jj+1,1}.DataElementRef = obj.getNodeTextContent(comSpecNode.item(jj),'DATA-ELEMENT-REF');
                    obj.PPorts{ii+1,1}.ComSpecs{jj+1,1}.HandleOutOfRange = obj.getNodeTextContent(comSpecNode.item(jj),'HANDLE-OUT-OF-RANGE');
                    obj.PPorts{ii+1,1}.ComSpecs{jj+1,1}.UsesEndToEndProt = obj.getNodeTextContent(comSpecNode.item(jj),'USES-END-TO-END-PROTECTION');
                    obj.PPorts{ii+1,1}.ComSpecs{jj+1,1}.InitalValueConstRef = obj.getNodeTextContent(comSpecNode.item(jj),'CONSTANT-REF');
                    
                end
            end
        end
        
        function getRPorts(obj,thisNode)
            
            RPortNode = thisNode.getElementsByTagName('R-PORT-PROTOTYPE');
            for ii = 0:RPortNode.getLength-1
                obj.RPorts{ii+1,1}.Name = obj.getNodeTextContent(RPortNode.item(ii),'SHORT-NAME');
                obj.RPorts{ii+1,1}.InterfaceRef = obj.getNodeTextContent(RPortNode.item(ii),'REQUIRED-INTERFACE-TREF');
                
                %find com spec node
                comSpecNode = RPortNode.item(ii).getElementsByTagName('NONQUEUED-SENDER-COM-SPEC');
                for jj = 0:comSpecNode.getLength-1
                    obj.RPorts{ii+1,1}.ComSpecs{jj+1,1}.DataElementRef = obj.getNodeTextContent(comSpecNode.item(jj),'DATA-ELEMENT-REF');
                    obj.RPorts{ii+1,1}.ComSpecs{jj+1,1}.HandleOutOfRange = obj.getNodeTextContent(comSpecNode.item(jj),'HANDLE-OUT-OF-RANGE');
                    obj.RPorts{ii+1,1}.ComSpecs{jj+1,1}.UsesEndToEndProt = obj.getNodeTextContent(comSpecNode.item(jj),'USES-END-TO-END-PROTECTION');
                    obj.RPorts{ii+1,1}.ComSpecs{jj+1,1}.AliveTimeOut = obj.getNodeTextContent(comSpecNode.item(jj),'ALIVE-TIMEOUT');
                    obj.RPorts{ii+1,1}.ComSpecs{jj+1,1}.EnableUpdate = obj.getNodeTextContent(comSpecNode.item(jj),'ENABLE-UPDATE');
                    obj.RPorts{ii+1,1}.ComSpecs{jj+1,1}.HandleDataStatus = obj.getNodeTextContent(comSpecNode.item(jj),'HANDLE-DATA-STATUS');
                    obj.RPorts{ii+1,1}.ComSpecs{jj+1,1}.HandleNeverRecieved = obj.getNodeTextContent(comSpecNode.item(jj),'HANDLE-NEVER-RECEIVED');
                    obj.RPorts{ii+1,1}.ComSpecs{jj+1,1}.HandleTimeout = obj.getNodeTextContent(comSpecNode.item(jj),'HANDLE-TIMEOUT-TYPE');
                    obj.RPorts{ii+1,1}.ComSpecs{jj+1,1}.InitalValueConstRef = obj.getNodeTextContent(comSpecNode.item(jj),'CONSTANT-REF');
                    
                end
            end
        end
        
        function getConstants(obj, thisNode)
            %find the constants node and extract the properties
            ConstNode = thisNode.getElementsByTagName('CONSTANT-SPECIFICATION');
            for ii = 0:ConstNode.getLength-1
                obj.Constants{ii+1,1}.Name = obj.getNodeTextContent(ConstNode.item(ii),'SHORT-NAME');
                obj.Constants{ii+1,1}.Category = obj.getNodeTextContent(ConstNode.item(ii),'CATEGORY');
                obj.Constants{ii+1,1}.ValuePhys = obj.getNodeTextContent(ConstNode.item(ii),'V');
                obj.Constants{ii+1,1}.UnitRef = obj.getNodeTextContent(ConstNode.item(ii),'UNIT-REF');
            end
        end
        
        function getSRInterfaces(obj, thisNode)
            %find the sender-reciever node and extract the details
            SRNode = thisNode.getElementsByTagName('SENDER-RECEIVER-INTERFACE');
            for ii = 0:SRNode.getLength-1
                names = obj.getNodeTextContent(SRNode.item(ii),'SHORT-NAME');
                obj.SRInterfaces{ii+1,1}.Name = names{1};
                obj.SRInterfaces{ii+1,1}.isService = obj.getNodeTextContent(SRNode.item(ii),'IS-SERVICE');
                obj.SRInterfaces{ii+1,1}.ServiceKind = obj.getNodeTextContent(SRNode.item(ii),'SERVICE-KIND');
                
                %get data elements
                SRNodeElemetnsNode = SRNode.item(ii).getElementsByTagName('VARIABLE-DATA-PROTOTYPE');
                for jj = 0:SRNodeElemetnsNode.getLength-1
                    obj.SRInterfaces{ii+1,1}.Elements{jj+1,1}.Name = obj.getNodeTextContent(SRNodeElemetnsNode.item(jj),'SHORT-NAME');
                    obj.SRInterfaces{ii+1,1}.Elements{jj+1,1}.CalAccess = obj.getNodeTextContent(SRNodeElemetnsNode.item(jj),'SW-CALIBRATION-ACCESS');
                    obj.SRInterfaces{ii+1,1}.Elements{jj+1,1}.DataTypeRef = obj.getNodeTextContent(SRNodeElemetnsNode.item(jj),'TYPE-TREF');
                    obj.SRInterfaces{ii+1,1}.Elements{jj+1,1}.InitValueRef = obj.getNodeTextContent(SRNodeElemetnsNode.item(jj),'CONSTANT-REF');
                    obj.SRInterfaces{ii+1,1}.Elements{jj+1,1}.SWImpPolicy = obj.getNodeTextContent(SRNodeElemetnsNode.item(jj),'SW-IMPL-POLICY');
                end
            end
        end
        
        function getMSInterfaces(obj, thisNode)           
            %find mode switch node and extract the details
            MSNode = thisNode.getElementsByTagName('MODE-SWITCH-INTERFACE');
            for ii = 0:MSNode.getLength-1
                names = obj.getNodeTextContent(MSNode.item(ii),'SHORT-NAME');
                obj.MSInterfaces{ii+1,1}.Name = names{1};
                obj.MSInterfaces{ii+1,1}.Introduction = obj.getNodeTextContent(MSNode.item(ii),'L-1');
                obj.MSInterfaces{ii+1,1}.isService = obj.getNodeTextContent(MSNode.item(ii),'IS-SERVICE');
                obj.MSInterfaces{ii+1,1}.ServiceKind = obj.getNodeTextContent(MSNode.item(ii),'SERVICE-KIND');
                obj.MSInterfaces{ii+1,1}.Elements = [];
                
                %get data elements
                ModeGroupNode = MSNode.item(ii).getElementsByTagName('MODE-GROUP');
                for jj = 0:ModeGroupNode.getLength-1
                    obj.MSInterfaces{ii+1,1}.ModeGroups{jj+1,1}.Name = obj.getNodeTextContent(ModeGroupNode.item(jj),'SHORT-NAME');
                    obj.MSInterfaces{ii+1,1}.ModeGroups{jj+1,1}.CalAccess = obj.getNodeTextContent(ModeGroupNode.item(jj),'SW-CALIBRATION-ACCESS');
                    obj.MSInterfaces{ii+1,1}.ModeGroups{jj+1,1}.DataTypeRef = obj.getNodeTextContent(ModeGroupNode.item(jj),'TYPE-TREF');
                end
            end
        end
        
        function getAppDataTypes(obj,thisNode)
            %find the app data type node and extract the details
            appDataTypeNode = thisNode.getElementsByTagName('APPLICATION-PRIMITIVE-DATA-TYPE');
            for ii = 0:appDataTypeNode.getLength-1
                obj.AppDataTypes{ii+1,1}.Name = obj.getNodeTextContent(appDataTypeNode.item(ii),'SHORT-NAME');
                obj.AppDataTypes{ii+1,1}.Description = obj.getNodeTextContent(appDataTypeNode.item(ii),'L-2');
                obj.AppDataTypes{ii+1,1}.Catagory = obj.getNodeTextContent(appDataTypeNode.item(ii),'CATEGORY');
                obj.AppDataTypes{ii+1,1}.CompuMethod = obj.getNodeTextContent(appDataTypeNode.item(ii),'COMPU-METHOD-REF');
                obj.AppDataTypes{ii+1,1}.DataConstraint = obj.getNodeTextContent(appDataTypeNode.item(ii),'DATA-CONSTR-REF');
                obj.AppDataTypes{ii+1,1}.UnitRef = obj.getNodeTextContent(appDataTypeNode.item(ii),'UNIT-REF');
            end
        end
        
        function getAppDataConstraints(obj,thisNode)
            %find the data contraint node and extract the details
            dataContstraintNode = thisNode.getElementsByTagName('DATA-CONSTR');
            for ii = 0:dataContstraintNode.getLength-1
                obj.AppDataConsts{ii+1,1}.Name = obj.getNodeTextContent(dataContstraintNode.item(ii),'SHORT-NAME');
                
                PhysicalConstraintNode = dataContstraintNode.item(ii).getElementsByTagName('PHYS-CONSTRS');
                obj.AppDataConsts{ii+1,1}.PhysConstLowLim = [];
                obj.AppDataConsts{ii+1,1}.PhysConstUpLim = [];
                
                for jj = 0:PhysicalConstraintNode.getLength-1
                    obj.AppDataConsts{ii+1,1}.PhysConstLowLim = obj.getNodeTextContent(PhysicalConstraintNode.item(0),'LOWER-LIMIT');
                    obj.AppDataConsts{ii+1,1}.PhysConstUpLim = obj.getNodeTextContent(PhysicalConstraintNode.item(0),'UPPER-LIMIT');
                end
                
            end
        end
        
        function getCompuMethods(obj,thisNode)
            %find the compu methods and extract the details
            compuMethodNode = thisNode.getElementsByTagName('COMPU-METHOD');
            for ii = 0:compuMethodNode.getLength-1
                obj.CompuMethods{ii+1,1}.Name = obj.getNodeTextContent(compuMethodNode.item(ii),'SHORT-NAME');
                obj.CompuMethods{ii+1,1}.Catagory = obj.getNodeTextContent(compuMethodNode.item(ii),'CATEGORY');
                obj.CompuMethods{ii+1,1}.UnitRef = obj.getNodeTextContent(compuMethodNode.item(ii),'UNIT-REF');
                num = obj.getNodeTextContent(compuMethodNode.item(ii),'COMPU-NUMERATOR');
                den = obj.getNodeTextContent(compuMethodNode.item(ii),'COMPU-DENOMINATOR');
                
                
                %find compu scale and offset
                if(~isempty(num)&~isempty(den))    
                    %convert to numbers
                    num = str2num(num);
                    den = str2num(den);
                    
                    %calculate parameters
                    obj.CompuMethods{ii+1,1}.Offset = num(1)/den;
                    obj.CompuMethods{ii+1,1}.Scale = num(2)/den;
                else
                    obj.CompuMethods{ii+1,1}.Scale = [];
                    obj.CompuMethods{ii+1,1}.Offset = [];
                end
                
                %find textable node
                
                
                %find 
                

                %TODO: need to add storage for textable data  
            end
        end
        
        function getUnits(obj,thisNode)
            %find the units node and extract the details
            unitsNode = thisNode.getElementsByTagName('UNIT');
            for ii = 0:unitsNode.getLength-1
                obj.Units{ii+1,1}.Name = obj.getNodeTextContent(unitsNode.item(ii),'SHORT-NAME');
                obj.Units{ii+1,1}.DisplayName = obj.getNodeTextContent(unitsNode.item(ii),'DISPLAY-NAME');
                obj.Units{ii+1,1}.FactorToSI = obj.getNodeTextContent(unitsNode.item(ii),'FACTOR-SI-TO-UNIT');
                obj.Units{ii+1,1}.OffsetToSI = obj.getNodeTextContent(unitsNode.item(ii),'OFFSET-SI-TO-UNIT'); %check this
                obj.Units{ii+1,1}.PhysicalDimRef = obj.getNodeTextContent(unitsNode.item(ii),'PHYSICAL-DIMENSION-REF');
            end
        end
        
        function getImpDataTypes(obj,thisNode)
            %find implementation datatypes and extract the details
            ImpDataTypeNode = thisNode.getElementsByTagName('IMPLEMENTATION-DATA-TYPE');
            for ii = 0:ImpDataTypeNode.getLength-1
                obj.ImpDataTypes{ii+1,1}.Name = obj.getNodeTextContent(ImpDataTypeNode.item(ii),'SHORT-NAME');
                obj.ImpDataTypes{ii+1,1}.Category = obj.getNodeTextContent(ImpDataTypeNode.item(ii),'CATEGORY');
                obj.ImpDataTypes{ii+1,1}.BaseTypeRef = obj.getNodeTextContent(ImpDataTypeNode.item(ii),'BASE-TYPE-REF');
                obj.ImpDataTypes{ii+1,1}.TypeEmitter = obj.getNodeTextContent(ImpDataTypeNode.item(ii),'TYPE-EMITTER');
                obj.ImpDataTypes{ii+1,1}.ImpDataTypeRef = obj.getNodeTextContent(ImpDataTypeNode.item(ii),'IMPLEMENTATION-DATA-TYPE-REF');
            end
        end
        
        function getBaseDataType(obj,thisNode)
            %get base types and extract the details
            BaseTypeNode = thisNode.getElementsByTagName('SW-BASE-TYPE');
            for ii = 0:BaseTypeNode.getLength-1
                obj.BaseTypes{ii+1,1}.Name = obj.getNodeTextContent(BaseTypeNode.item(ii),'SHORT-NAME');
                obj.BaseTypes{ii+1,1}.Category = obj.getNodeTextContent(BaseTypeNode.item(ii),'CATEGORY');
                obj.BaseTypes{ii+1,1}.BaseTypeSize = obj.getNodeTextContent(BaseTypeNode.item(ii),'BASE-TYPE-SIZE');
                obj.BaseTypes{ii+1,1}.ServiceKind = obj.getNodeTextContent(BaseTypeNode.item(ii),'BASE-TYPE-ENCODING');
            end
        end
        
        function getModeDeclerationGroups(obj,thisNode)
            %find mode decleration group section and get details
            MDCNode = thisNode.getElementsByTagName('MODE-DECLARATION-GROUP');
            for ii = 0:MDCNode.getLength-1
                obj.ModeDeclarationGroups{ii+1,1}.Name = obj.getNodeTextContent(MDCNode.item(ii),'SHORT-NAME');
                obj.ModeDeclarationGroups{ii+1,1}.Category = obj.getNodeTextContent(MDCNode.item(ii),'CATEGORY');
                obj.ModeDeclarationGroups{ii+1,1}.InitialMode = obj.getNodeTextContent(MDCNode.item(ii),'INITIAL-MODE-REF');
                
                ModesNode = MDCNode.item(ii).getElementsByTagName('MODE-DECLARATION');
                for jj = 0:ModesNode.getLength-1
                    obj.ModeDeclarationGroups{ii+1,1}.Modes{jj+1,1}.Name = obj.getNodeTextContent(ModesNode.item(ii),'SHORT-NAME');
                    obj.ModeDeclarationGroups{ii+1,1}.Modes{jj+1,1}.Value = obj.getNodeTextContent(ModesNode.item(ii),'VALUE');
                end
            end
        end
        
        function getDataTypeMappingSets(obj,thisNode)
            %get the data type mapping set node and extract the details
            DTMSNode = thisNode.getElementsByTagName('DATA-TYPE-MAPPING-SET');
            for ii = 0:DTMSNode.getLength-1
                obj.DataTypeMappingSets{ii+1,1}.Name = obj.getNodeTextContent(DTMSNode.item(ii),'SHORT-NAME');
                obj.DataTypeMappingSets{ii+1,1}.AppDataRef = obj.getNodeTextContent(DTMSNode.item(ii),'APPLICATION-DATA-TYPE-REF');
                obj.DataTypeMappingSets{ii+1,1}.ImpDataRef = obj.getNodeTextContent(DTMSNode.item(ii),'IMPLEMENTATION-DATA-TYPE-REF');
            end
        end
        
        function getSWImp(obj,thisNode)
            SWImpNode = thisNode.getElementsByTagName('SWC-IMPLEMENTATION');
            for ii = 0:SWImpNode.getLength-1
                names = obj.getNodeTextContent(SWImpNode.item(ii),'SHORT-NAME');
                obj.SWImp{ii+1,1}.Name = names{1};
                obj.SWImp{ii+1,1}.ProgLanguage = obj.getNodeTextContent(SWImpNode.item(ii),'PROGRAMMING-LANGUAGE');
                obj.SWImp{ii+1,1}.SWVersion = obj.getNodeTextContent(SWImpNode.item(ii),'SW-VERSION');
                obj.SWImp{ii+1,1}.IBRef = obj.getNodeTextContent(SWImpNode.item(ii),'BEHAVIOR-REF'); %check this
            end
        end
        
    end
    
    methods (Static, Access = private)
        function thisText = getNodeTextContent(thisNode,sting)
            
            %init thisText
            thisText = [];
            
            %find the node for the subproperty
            subNode = thisNode.getElementsByTagName(sting);
            
            %get node length
            lengthNode = subNode.getLength;
            
            %get the text content of the node
            try                
                if(lengthNode>1)
                    %loop through the node and extract the text
                    for ii=0:subNode.getLength-1
                        thisText{ii+1,1} = char(subNode.item(ii).getTextContent);
                    end
                else
                    %get single value
                    thisText = char(subNode.item(0).getTextContent);
                end
                
            catch
                %display message if property cannot be found
                %disp(['cannot find property: ',sting]);            
            end
        end
        
        function [path, name] = extractObjectInfo(string)
            
            %find seperator
            idx = strfind(string,'/');
            
            %get path to object
            path = string(1:idx(end));
            
            %get name of object
            name = string(idx(end)+1:end);
        end
        
        
        
    end
    
end

