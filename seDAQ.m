


classdef seDAQ < handle

    % returns DAQ object/struct containing information to send out event codes
    % to data acquisition device.
    %


    properties
        
        isPresent   = false;       % whether the DAQ device is present or not

        deviceNum   = NaN;         % number-pointer to DAQ device
        lastCode    = NaN;         % value of last eventCode that was successfully sent out

    end % properties

    
    properties(Hidden = true, Constant = true)
        
        RESP                = 'resp';       % 
        EVENT               = 'event';
 
        EVENT_PORT          = 0;            % value to send eventCode out of event port
        RESP_PORT           = 1;            % value to send eventCode out of response port
        
        CONFIG_OUTPUT       = 0;            % value to designate if port as output
        CONFIG_INPUT        = 1;            % value to designate if port as input

        RESET_EVENTCODE     = 0;            % arbitrary number for resets
        TIME_DELAY          = 0.010;        % (secs) time duration to leave event codes on after sending them out 
        EVENT_CODE_LIMIT    = 255;          % max event code
            
    end 
    
    properties(Hidden = true)
        pcIO;                               % input/output (IO) object to send event codes on PCs
        BIOSEMI         = 'Biosemi';
        BRAINPRODUCTS   = 'BrainProducts';
    end
    
  
    methods

        function obj = seDAQ()
            if ismac
                
                obj.deviceNum  = DaqDeviceIndex();
                obj.isPresent = ~isempty(obj.deviceNum);
                
                if(obj.isPresent)
                    configPorts(obj);            % Basic DAQ-device Setup %
                end
                
            elseif ispc
                buttonname=questdlg('Please select data acquisition system:','DAQ?',obj.BIOSEMI, obj.BRAINPRODUCTS, obj.BIOSEMI);
                
                switch buttonname
                    case obj.BIOSEMI
                        obj.deviceNum = hex2dec('2050');                
                    case obj.BRAINPRODUCTS
                        obj.deviceNum = hex2dec('2030');
                end
                
                obj.pcIO      = io64();
                obj.isPresent = ~io64(obj.pcIO);
                
            end 
        end % daq constructor method
        
        function configPorts(obj)
            
            display(sprintf('Configuring ports %d and %d as output ports', obj.EVENT_PORT, obj.RESP_PORT));
            
            DaqDConfigPort(obj.deviceNum, obj.EVENT_PORT, obj.CONFIG_OUTPUT); % configure as output port
            DaqDConfigPort(obj.deviceNum, obj.RESP_PORT,  obj.CONFIG_OUTPUT); % configure as output port
            
        end % configPorts method


        function sendEventCode(obj, eventCode)
            % SENDEVENTCODE     Sends event/response eventCode out to DAQ device.
            % CODE must be an integer 1-254
            
            if(obj.isPresent && (0 < eventCode < obj.EVENT_CODE_LIMIT))
                if ismac
                    DaqDOut(obj.deviceNum, obj.EVENT_PORT,  eventCode);                                     % Send event code
                    WaitSecs(obj.TIME_DELAY);
                    DaqDOut(obj.deviceNum, obj.EVENT_PORT, obj.RESET_EVENTCODE);                                 % Clear event code
                    WaitSecs(obj.TIME_DELAY);
                elseif ispc
                    io64(obj.pcIO, obj.deviceNum, eventCode);
                    WaitSecs(obj.TIME_DELAY);
                    io64(obj.pcIO, obj.deviceNum, obj.RESET_EVENTCODE);
                    WaitSecs(obj.TIME_DELAY);
                end
            elseif(~obj.isPresent)
                fprintf('Error:\tDAQ device not present\n\tEvent code %03d not sent\n',eventCode);
            elseif(~(0 < eventCode <= obj.EVENT_CODE_LIMIT))
                fprintf('Warning:\tEvent code exceeds limit (%d)\n\t\tEvent code %03d not sent\n', obj.EVENT_CODE_LIMIT, eventCode);
            end

        end
        
    end % methods

end        
        
        
%         function value = resetPorts(obj)
% 
%             if(obj.isPresent)
% 
%                 display('Resetting response and event ports')
%                 
%                 DaqDOut(obj.deviceNum, obj.RESP_PORT,  obj.RESET_EVENTCODE);
%                 DaqDOut(obj.deviceNum, obj.EVENT_PORT, obj.RESET_EVENTCODE);
%                 
%                 
%             else
%                 value = 'DAQ device not present';
%                 display(value);
%             end
% 
%         end
%         
%         function value = sendResponseCode(obj, eventCode)
%             % SENDEVENTCODE     Sends stimulus/response eventCode out to DAQ device.
%             % PORT_WD must be either 'resp' or 'event'
%             % CODE must be an integer 0-255
%             
%             if(obj.isPresent)
%                 
%                 value = DaqDOut(obj.deviceNum, obj.RESP_PORT,  eventCode);
%                 
%             else
%                 value = 'DAQ device not present';
%                 fprintf('%s\n', value);
%             end
%             
%         end
%
%         function value = sendCode(obj, port_wd, eventCode)
%             % SENDEVENTCODE     Sends event/response eventCode out to DAQ device.
%             % PORT_WD must be either 'resp' or 'event'
%             % CODE must be an integer 0-255
% 
%             if(obj.isPresent)
% 
%                 switch port_wd
% 
%                     case obj.RESP
% 
%                         value = DaqDOut(obj.deviceNum, obj.RESP_PORT,   eventCode);
% 
%                     case obj.EVENT
% 
%                         value = DaqDOut(obj.deviceNum, obj.EVENT_PORT,  eventCode);
% 
%                     otherwise
%                         error('Wrong port specified');
%                 end
% 
%             else
%                 value = 'Error: DAQ device not present';
%                 fprintf('%s\n      Event code %03d not sent\n', value,eventCode);
%             end
% 
%         end
%         
        
        

