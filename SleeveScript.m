% 1. Connection to the device

% Variables to set up the device.
isUSB = 0;
Port   = '/dev/cu.NeuraSens-Mv2'; %if windows COMX -> connect to the master sleeve!

% The communicatio speed, baudrate, will change depending on the
% communcation protocol. If the communication is by USB, the baudrate will
% be 2000000. If is by bluetooth, the speed will be 115200.
if isUSB
    baudRate = 2000000;
else % bluetooth
    baudRate = 115200;
end
    
% Here we are creating a seral object to connect with the device using the
obj.EMGSerial = serialport(Port, baudRate); 

% The data that ArmIO will transmit to matlab will be in the 16-bit integer
obj.dataType  = 'int16';

%% Incoming buffer size
% The size of the incoming data of the device will be store in
% obj.EMGSerial.NumBytesAvailable. We can use this variable to monitor how
% much data Matlab have stored in the buffer from the device.

% If there is not data available in the buffer, this will return a 0

obj.EMGSerial.NumBytesAvailable

%% 1. Start EMG acquisition - Start before any recording
% Pause in the case there was any prior communication
write(obj.EMGSerial, 'p', 'char');
pause(1)
obj.EMGSerial.flush;  % Flush any prior data
write(obj.EMGSerial, 's', 'char');  % Start acquisition on the device
write(obj.EMGSerial, 'm0', 'char'); % Start tranmission - 0 - disable

%% 4. Start transmission
write(obj.EMGSerial, 'm1', 'char'); % Start tranmission - 1 - enable

%% 4. Stop Collect the data and plot
% Stop tranmission
write(obj.EMGSerial, 'm0', 'char');
pause(1)

TotalData = [];
CorruptBlocks = 0;
while obj.EMGSerial.NumBytesAvailable > 0
    % Check if block starts with the correct handshake
    HandSequence = [1,2,3];
    sequence = read(obj.EMGSerial, 3, obj.dataType);
    status = 1;

    if sum(sequence) > 0 
    if sequence(1) == HandSequence(1) && sequence(2) == HandSequence(2) && sequence(3) == HandSequence(3)
        status = 1;
        fprintf('Correct handshake\n')
    % If the sequence is wrong 
    else
        isChecking = true;
        % If not check when the next sequence of data block starts
            while isChecking
                sequence(3) = sequence(2) ;
                sequence(2) = sequence(1);
                sequence(1) = read(obj.EMGSerial, 1, obj.dataType);
                if sequence(1) == HandSequence(3) && sequence(2) == HandSequence(2) && sequence(3) == HandSequence(1)
                    isChecking = false;
                    CorruptBlocks = CorruptBlocks + 1;
                    status = 1;
                    fprintf('wrong handshake\n')
                end
            end
    end

    % Collect block of data
    nChannels = 60;
    acqBufferSize  = 40;
    new_data = zeros(nChannels, acqBufferSize);
    % Read the EMG data available from the serial port
        for i = 1: nChannels
            new_data(i,:) = read(obj.EMGSerial, acqBufferSize, obj.dataType);
        end
    end
    new_data = fliplr(new_data); % Check data
    
    TotalData = [TotalData; new_data'];
end

%% plot data
PlotChs(TotalData', 1:60,1000)








%% 2. Start recording - 
% Start recording in master and slave
write(obj.EMGSerial, 'z', 'char');
% Activate clock
write(obj.EMGSerial, 'f1', 'char');


%% 3. Stop recording - 
% Activate clock
write(obj.EMGSerial, 'f0', 'char');
% stop recording in master and slave
obj.SendCommand('q');

%% Disconnect
obj.EMGSerial.delete;
clear all