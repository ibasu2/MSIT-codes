 function [eyeTrackerhHandle,visEnviro,MSITOpts,ttlStruct] = MSITOpenTask(MSITOpts)
%function setups all of the psychtoolbox things needed to run the task, the
%eye tracker, etc. Pretty generic but could vary some by task
%
%written by Seth Konig 10/9/2020 based on cogedOpenTask

% set the correct modes, NOT based on user input
ListenChar(2);

%% Initialize screen & audio settings
visEnviro = hdLabSetupScreen();
Screen('TextSize',visEnviro.screen.window, MSITOpts.textParams.textSize);


%% Setup Audio
%setup audio handle
visEnviro.soundParams = [];
[visEnviro.soundParams.audioOutHandle,visEnviro.soundParams.speakerFrequency] = setupOutputAudioHandle();

%make reward sounds
[visEnviro.soundParams.sf,visEnviro.soundParams.rwdSound,visEnviro.soundParams.norwdSound] = makeAudioFeedback(visEnviro.soundParams.speakerFrequency);


%% Initialize keyboard functions
MSITOpts.KB = hdLabSetupKeyboard();%initiate keyboard short cuts

%% Setup Random Seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
rng('shuffle');


%% Initialize Eye Tracker
% Connection with Eyelink if using eye tracking
try
    if ~strcmpi(MSITOpts.eyeParams.eyeTrackingMode,'none')
        [eyeTrackerhHandle,~,MSITOpts.eyeParams.eyeTracked] = setupHDLabEyeLink(....
            visEnviro.screen.window,MSITOpts.fileParams.createEDFFile,MSITOpts.fileParams.fileBaseName(1:4));
    else
        eyeTrackerhHandle = [];
    end
    
    %check if eye tracker connected afterwards
    if Eyelink('IsConnected')
        MSITOpts.eyeParams.eyeTrackerConnected = true;
    else
        MSITOpts.eyeParams.eyeTrackerConnected = false;
    end
catch
    %check if you wanted to really try to connect to the eye tracker
    if ~strcmpi(MSITOpts.eyeParams.eyeTrackingMode,'none')
        disp('Trouble connecting with the eye tracker')
        text = ['Eye tracker failed to connection despite you trying to connect to it! \n'....
            'Press Space to continue without the eye tracker, and \n'...
            'Press Q to quit!'];
        DrawFormattedText(visEnviro.screen.window, text,'center', 'center');
        DrawFormattedText(visEnviro.screen.window, text,'center', 'center');
        Screen('Flip',visEnviro.screen.window);
        
        waitForKeyPress = true;
        while waitForKeyPress
            [~, ~, keyCode] = KbCheck;
            if keyCode(MSITOpts.KB.space)
                waitForKeyPress = false;
                eyeTrackerhHandle = [];
                MSITOpts.eyeParams.eyeTrackerConnected = false;
            elseif keyCode(MSITOpts.KB.quitKey)
                waitForKeyPress = false;
                error('Failed to connect to the eye tracker!')
            end
            WaitSecs(0.001); %so doesn't loop too fast
        end
        
        %clear screen and give program a momenet to reset
        Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
        Screen('Flip',visEnviro.screen.window);
        WaitSecs(0.5);
        
    else
        eyeTrackerhHandle = [];
        MSITOpts.eyeParams.eyeTrackerConnected = false;
    end
end

%% Initialize Response Pad
if strcmpi(MSITOpts.responseMode.type,'responsePad')
    if strcmpi(visEnviro.rig.responsePadType,'RB-740')
        hCedrus = CedrusResponseBox('Open', visEnviro.rig.responsePadPort);
        devinfo = CedrusResponseBox('GetDeviceInfo',hCedrus);
        
        % Flush the box for a start: do on start of every new trial
        status = CedrusResponseBox('FlushEvents', hCedrus); %'status', which will return the current status of all buttons
        if ~all(status(:) == 0)
            error('Why are some keys pressed?')
        end
        
        %set current mode to ReflectiveSinglePulse, only triggers when key is pressed but not release
        CedrusResponseBox('SetConnectorMode', hCedrus, 'ReflectiveSinglePulse');
        WaitSecs(1);
        
        MSITOpts.responseMode.type = 'RB-740'; %overwrite to be more specific
        MSITOpts.responseMode.responsePadHandle = hCedrus;
        MSITOpts.responseMode.responsePadInfo = devinfo;
        MSITOpts.responseMode.connected = true;
    else
        error('Code for this has not been written')
    end
elseif ~strcmpi(MSITOpts.responseMode.type,'keyBoard')
    error('Code for this has not been written')
end

%% Initialize TTL Port
ttlStruct = hdLabSetupTTLDevice(visEnviro.rig);
markEvent('taskStart',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);

end