function sessionVars = MSITRunTrial(MSITOpts,MSITTaskSpecs,sessionVars,visEnviro,eyeTrackerhHandle,ttlStruct,lslInlet)
%script runs trials of MSITTaskSpecs task, based on eMSIT tasks.
%Note the task looks for keyboard input during all trial periods, but pausing,
%recalibration, etc. only work during IBI/ISI periods.
%Quitting happens during same periods so no actions are going on.
%
%written by Seth Konig 2/24/21

%---Setup Screen and Text Stuff---%
%do string cat here so not time consuming later
pauseText = ['Paused \n \n Press "' char(MSITOpts.KB.unpauseKey) '" to resume task!'];

%set font size and style
Screen('TextSize',visEnviro.screen.window,MSITOpts.textParams.stimTextSize); %font size
Screen('TextStyle',visEnviro.screen.window,0); %font style i.e. normal text vs bold
Screen('TextFont',visEnviro.screen.window,MSITOpts.textParams.textFont); %font type
Screen('TextColor',visEnviro.screen.window,MSITOpts.textParams.textColor); %font color


%superstition but I think this helps, SDK
WaitSecs(0.1);
Screen(visEnviro.screen.window,'FillRect',0); %clear screen
Screen(visEnviro.screen.window,'Flip');

%check if using task-triggered stimulation
if MSITOpts.taskTriggeredStimParams.useTaskTriggeredStim
    if ~strcmpi(MSITOpts.taskTriggeredStimParams.stimPeriod,'stimulusOn')
        error('only stimulusOn task-triggered stimulation is setup right now!')
    end
end

%---Run Through Each Trial---%
sessionVars.trialNum = 0;
try
    while (sessionVars.trialNum < MSITOpts.trialParams.numTrials) && ~sessionVars.quitTask
        
        %---Initiate Block---%
        dataIndex = 1;
        sessionVars.trialNum = sessionVars.trialNum + 1;
        sessionVars.blockNum = floor(sessionVars.trialNum/100)+1;%psuedo block for tracking with TTL pulses
        % %Trial block numbering
        % if mod(sessionVars.trialNum,50)==0
        %     sessionVars.blockNum = sessionVars.trialNum/50;%psuedo block for tracking with TTL pulses
        % else
        %     sessionVars.blockNum = floor(sessionVars.trialNum/50)+1;%psuedo block for tracking with TTL pulses
        % end
        % if mod(sessionVars.trialNum,50)==1% && sessionVars.trialNum~=1
        %     breakText = 'Break!';
        %     % Screen(visEnviro.screen.window,'FillRect',0); %clear screen
        %     DrawFormattedText(visEnviro.screen.window,breakText,'center', 'center');
        % 
        %     waitForKeyPress = true;
        %     while waitForKeyPress
        %         [~, ~, keyCode] = KbCheck;
        %         if keyCode(MSITOpts.KB.space)
        %             waitForKeyPress = false;
        %         end
        %         WaitSecs(0.001);%so doesn't loop too fast
        %     end
        %     WaitSecs(0.5);
        % end
           
        %parameters for tracking time in event periods, placed here for debugging since explicit call makes debugging easier
        itiEventTime = NaN; %for tracking duration of Inter Block Interval (IBI)
        trialCueEventTime = NaN; %for tracking duration of Inter Block Interval (IBI)
        needToDrawPauseText = true;
        
        if MSITOpts.debugMode
            disp(['Initiating Trial number: ' num2str(sessionVars.trialNum)])
        end
        
        %trial start TTL pulses, send after initiate cuz that opens/closes eye tracker files
        [trialData, imageMatrix] = MSITInitiateTrial(MSITOpts,MSITTaskSpecs,sessionVars,lslInlet);
        trialData.trialStart = markEvent('trialStart',sessionVars.blockNum,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
        if ~MSITOpts.taskTriggeredStimParams.useTaskTriggeredStim
            %can't use any values over 127 when doing TTL triggered stimulation!
            % markEvent('blockNumber',sessionVars.blockNum,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
            % markEvent('trialNumber',sessionVars.trialNum,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
        end
        
        
        %---Inter Trial Interval (ITI)---%
        if MSITOpts.debugMode
            disp('IBI Period Start')
        end
        
        itiEventTime = GetSecs() - trialData.trialStart;%explicit call makes debuging much easier
        while itiEventTime < trialData.iti
            
            %get eye position
            if MSITOpts.eyeParams.eyeTrackerConnected
                trialData.eyeSamples(:,dataIndex) = sampleEye(MSITOpts.eyeParams.eyeTracked);
            end
            
            %check for keyboard input
            [sessionVars.pauseFlag, sessionVars.quitTask, sessionVars.recalibrate, ~] = ...
                checkKeyBoardInput(MSITOpts.KB,sessionVars.pauseFlag,sessionVars.quitTask,sessionVars.recalibrate);
            if sessionVars.pauseFlag && needToDrawPauseText
                % Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
                Screen(visEnviro.screen.window,'FillRect',0); %clear screen
                DrawFormattedText(visEnviro.screen.window,pauseText,'center', 'center');
                trialData.paused = markEvent('taskPaused',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,1);
                needToDrawPauseText = false;
            elseif ~sessionVars.pauseFlag && ~needToDrawPauseText
                % Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
                Screen(visEnviro.screen.window,'FillRect',0); %clear screen
                trialData.resume = markEvent('taskResume',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,1);
                needToDrawPauseText = true;
            elseif sessionVars.recalibrate
                trialData.recalibrating = markEvent('recalibrateStart',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                EyelinkDoTrackerSetup(eyeTrackerhHandle);
                trialData.doneCalibrating = markEvent('recalibrateEnd',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                sessionVars.recalibrate = false;
            elseif sessionVars.quitTask
                trialData.quit = markEvent('taskQuit',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                break;%exits while loop, break does not?
            end
            
            %update time and index
            WaitSecs(0.001);%so doesn't loop too fast
            dataIndex = dataIndex + 1;
            
            if sessionVars.pauseFlag
                itiEventTime = 0; %while paused continually reset ibi time
            else
                itiEventTime = GetSecs() - trialData.trialStart; %update time since event start
            end
        end
        trialData.itiEnd = GetSecs(); %no specific code to send but want to save
                
        %---Show Text/Choice Period---%
        %coded as central cue period
        if MSITOpts.debugMode
            disp('Show Text/Choice Period Start')
            disp(['ITI duration was ' num2str(itiEventTime)])
            disp(['Showing stimulus ' trialData.stimulus])
        end
        
        % %%---Display image: From lppEmotionRunTrial.m
        % sessionVars.completedTrials = sessionVars.completedTrials+1;
        % pictureTexture = Screen('MakeTexture',visEnviro.screen.window,imageMatrix);
        % Screen('DrawTexture',visEnviro.screen.window, pictureTexture);
        % trialData.displayStart = markEvent('conditional',50+trialData.imageType,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,1);
        % 
        % displayEventTime = GetSecs() - trialData.displayStart;%explicit call makes debuging much easier
        % while displayEventTime <  MSITOpts.timingParams.imageDuration
        % 
        %     %get eye position
        %     if MSITOpts.eyeParams.eyeTrackerConnected
        %         trialData.eyeSamples(:,dataIndex) = sampleEye(MSITOpts.eyeParams.eyeTracked);
        %     end
        % 
        %     %update time and index
        %     WaitSecs(0.001);%so doesn't loop too fast
        %     dataIndex = dataIndex + 1;
        % 
        %     displayEventTime = GetSecs() - trialData.displayStart; %update time since event start
        % end
        % 
        %%-----------------------------------------------%
        
        %%---Display image as background for MSIT stimulus: From lppEmotionRunTrial.m
        sessionVars.completedTrials = sessionVars.completedTrials+1; 
        pictureTexture = Screen('MakeTexture',visEnviro.screen.window,imageMatrix);

        %draw & show MSIT stimulus
        createAndFlipPhotoDiodeRect(visEnviro,1,1); %flip photodiode 
        % disp(num2str(GetSecs()));
        Screen('DrawTexture',visEnviro.screen.window, pictureTexture);
        drawMSITStimuli(visEnviro,MSITTaskSpecs,trialData.stimulus);
        trialData.numberOn = markEvent('choiceStart',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,1);
        % markEvent('conditional',58+trialData.isControl,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
        % disp(num2str(GetSecs()));
        
        %if response pad then reset RT timer
        if strcmpi(MSITOpts.responseMode.type,'RB-740')
            CedrusResponseBox('FlushEvents', MSITOpts.responseMode.responsePadHandle); %get rid of stale inputs
            CedrusResponseBox('ResetRTTimer', MSITOpts.responseMode.responsePadHandle);
        end
        
        choiceEventTime = GetSecs() - trialData.numberOn; %start event timer
        waitingToStim = true;
        while (choiceEventTime < MSITOpts.timingParams.maxResponseTime) && isnan(trialData.response)
            
            %get eye position
            if MSITOpts.eyeParams.eyeTrackerConnected
                trialData.eyeSamples(:,dataIndex) = sampleEye(MSITOpts.eyeParams.eyeTracked);
            end
            
            % check keyboard/response pad input
            if strcmpi(MSITOpts.responseMode.type,'keyBoard')
                [keyIsDown, keyInputTime, keyCode] = KbCheck();
                if keyIsDown
                    if keyCode(MSITOpts.KB.onekey)
                        trialData.rt = keyInputTime-trialData.numberOn;
                        trialData.response = 1;
                        trialData.responseTime = markEvent('userInput',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                    elseif keyCode(MSITOpts.KB.twokey)
                        trialData.rt = keyInputTime-trialData.numberOn;
                        trialData.response = 2;
                        trialData.responseTime = markEvent('userInput',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                    elseif keyCode(MSITOpts.KB.threekey)
                        trialData.rt = keyInputTime-trialData.numberOn;
                        trialData.response = 3;
                        trialData.responseTime = markEvent('userInput',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                    end
                end
            elseif strcmpi(MSITOpts.responseMode.type,'RB-740')
                evt = CedrusResponseBox('GetButtons', MSITOpts.responseMode.responsePadHandle);
                if ~isempty(evt) && evt.action == 1 %key pressed
                    if evt.button == visEnviro.rig.responsePad1
                        trialData.rt = evt.rawtime;
                        trialData.responseTime = markEvent('userInput',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                        trialData.response = 1;
                    elseif evt.button ==  visEnviro.rig.responsePad2
                        trialData.rt = evt.rawtime;
                        trialData.responseTime = markEvent('userInput',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                        trialData.response = 2;
                    elseif evt.button ==  visEnviro.rig.responsePad3
                        trialData.rt = evt.rawtime;
                        trialData.responseTime = markEvent('userInput',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                        trialData.response = 3;
                    end
                end
            else
                error('need code here!')
            end
            
            %check if subject is a cheater?, then make selection
            if any(contains(MSITOpts.cheaterMode.cheaterNames,MSITOpts.fileParams.subjID))
                %make a choice if eventTime exceeds cheater reaction time
                if choiceEventTime >= trialData.cheaterRT
                    if strcmpi(MSITOpts.cheaterMode.cheaterNames{trialData.cheaterID},'cheater') %best choice
                        trialData.response = trialData.correctResponse;
                    elseif strcmpi(MSITOpts.cheaterMode.cheaterNames{trialData.cheaterID},'naive') %random choice
                        trialData.response = randi(3);
                    elseif strcmpi(MSITOpts.cheaterMode.cheaterNames{trialData.cheaterID},'troll') %worst choice
                        badResponses = randperm(3);
                        badResponses(badResponses == trialData.correctResponse) = [];
                        trialData.response = badResponses(1);
                    end
                    trialData.responseTime = markEvent('userInput',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                    trialData.rt = trialData.responseTime-trialData.numberOn;
                end
            end
            
            %check for keyboard input but don't do anything until end of trial
            [sessionVars.pauseFlag, sessionVars.quitTask, sessionVars.recalibrate, ~] = ...
                checkKeyBoardInput(MSITOpts.KB,sessionVars.pauseFlag,sessionVars.quitTask,sessionVars.recalibrate);
            
            %check if we need to stimulate
            if MSITOpts.taskTriggeredStimParams.useTaskTriggeredStim && waitingToStim && trialData.stimOnThisTrial
                if strcmpi(MSITOpts.taskTriggeredStimParams.stimPeriod,'stimulusOn')
                    if choiceEventTime >= MSITOpts.taskTriggeredStimParams.postEventDelay
                        trialData.stimulationTime = markEvent('stim',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
                        waitingToStim = false;
                    end
                end
            end
            
            %update time and index
            WaitSecs(0.001);%so doesn't loop too fast
            dataIndex = dataIndex + 1;
            
            choiceEventTime = GetSecs() - trialData.numberOn; %update time since event start
        end
        
        
        
        %---Post Response Period---%
        %clear screen/make sure screen is clear
        Screen(visEnviro.screen.window,'FillRect',0);
        createAndFlipPhotoDiodeRect(visEnviro,1,1); %flip photodiode
        trialData.numberOff = markEvent('choiceEnd',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,1);
        
        %mark end of choice period
        if ~isnan(trialData.response) %made a choice
            %also send reward info
            if trialData.response == trialData.correctResponse %correct response if lure or nonTarget
                trialData.correctness = 1;
                % markEvent('reward',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
            else
                trialData.correctness = 0;
                % markEvent('unrewarded',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
            end
        else %no response
            trialData.timeoutTime = markEvent('eventTimeout',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,1);
        end
        
        
        
        %---Post-Trial Wait period---%
        %so all trial durations are the same
        bufferStartTime = GetSecs();
        bufferDuration = MSITOpts.timingParams.maxResponseTime-(bufferStartTime-trialData.numberOn);
        if bufferDuration > 0
            bufferEventTime = GetSecs() - bufferStartTime;%explicit call makes debuging much easier
            while bufferEventTime < bufferDuration
                
                %get eye position
                if MSITOpts.eyeParams.eyeTrackerConnected
                    trialData.eyeSamples(:,dataIndex) = sampleEye(MSITOpts.eyeParams.eyeTracked);
                end
                
                %update time and index
                WaitSecs(0.001);%so doesn't loop too fast
                dataIndex = dataIndex + 1;
                
                bufferEventTime = GetSecs() - bufferStartTime;%explicit call makes debuging much easier
            end
        end
        
        if MSITOpts.debugMode
            disp(['Buffer Duration was ' num2str(bufferDuration)])
            disp(['RT was ' num2str(trialData.rt)])
            disp(['Response was rewarded? ' num2str(trialData.correctness)])
        end
        
        
        
        %---Store performance results---%
        sessionVars.MSITPerformanceResults.accuracy(sessionVars.trialNum) = trialData.correctness;
        sessionVars.MSITPerformanceResults.accuracyType(sessionVars.trialNum) = trialData.isControl;
        sessionVars.MSITPerformanceResults.RT(sessionVars.trialNum) = trialData.rt;
        
        
        %---End Trial & Store Trial Data---%
        %remvoe excess NaNs
        if dataIndex < size(trialData.eyeSamples,2)
            trialData.eyeSamples(:,dataIndex:end) = [];
        end
        
        if MSITOpts.debugMode
            disp('Trial End')
            disp(' ') %to create new line
        end
        
        %close trial
        trialData.trialEnd = markEvent('trialEnd',sessionVars.trialNum,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,0);
        MSITCloseTrial(MSITOpts,visEnviro,trialData,sessionVars,lslInlet)
    end
    
catch ME
    disp(ME)
    disp('Unable to complete a trial!....trying to save existing data');
    
    sessionVars.quitTask = true;
    
    try  %to save data else close task
        MSITCloseTrial(MSITOpts,visEnviro,trialData,sessionVars,lslInlet)
        closeTask(ttlStruct);
        
        if MSITOpts.responseMode.connected && strcmpi(MSITOpts.responseMode.type,'RB-740')
            CedrusResponseBox('CloseAll');
        end
    catch ME2
        closeTask(ttlStruct);
        
        if MSITOpts.responseMode.connected && strcmpi(MSITOpts.responseMode.type,'RB-740')
            CedrusResponseBox('CloseAll');
        end
        rethrow(ME2)
    end
end

end



function [trialData, imageMatrix] = MSITInitiateTrial(MSITOpts,MSITTaskSpecs,sessionVars,lslInlet)

%----Setup Block Data---%
trialData = [];

%Significant Keyboard events
trialData.paused = NaN;
trialData.resume = NaN;
trialData.recalibrating = NaN;
trialData.doneCalibrating = NaN;
trialData.quit = NaN;

%block timing
trialData.iti = MSITOpts.timingParams.drawTime(MSITOpts.timingParams.iti);
trialData.trialStart = NaN; %same as isiStart
trialData.itiStart = NaN;
trialData.itiEnd = NaN;
trialData.numberOn = NaN;
trialData.numberOff = NaN;
trialData.trialEnd = NaN;
trialData.displayStart = NaN;%when image is turned on
trialData.displayEnd = NaN; %when image is turned off

% Choice vars
trialData.rt = NaN; %reaction time
trialData.response = NaN; %1 or 2 key
trialData.responseTime = NaN; %time of response
trialData.correctness = NaN; %whether subject was correct or not
trialData.timeoutTime = NaN;% if didn't respond time stored here

%Select Stimulus to show
trialData.stimulus = MSITTaskSpecs.stimuli.stimulus{sessionVars.trialNum};
trialData.isControl = MSITTaskSpecs.stimuli.isControl(sessionVars.trialNum); %control is congruent
trialData.correctResponse = MSITTaskSpecs.stimuli.correctResponse(sessionVars.trialNum); %which button press is right
trialData.targetPosition = MSITTaskSpecs.stimuli.targetPosition(sessionVars.trialNum); %oridinal position of target
trialData.flankers = MSITTaskSpecs.stimuli.flankers(sessionVars.trialNum); %flanker numbers

%where to show stimulus
trialData.stimulusXPosition = MSITTaskSpecs.stimuliLocation.xPosition;
trialData.stimulusYPosition = MSITTaskSpecs.stimuliLocation.yPosition;

%stimulation variables
trialData.stimOnThisTrial = MSITTaskSpecs.stimulationTrials(sessionVars.trialNum);
trialData.stimulationTime = NaN;%if/when we sent stim TTL

%---From lppEmotionRunTrial.m: get image name and load image---%
trialData.trialNum = sessionVars.trialNum; %in whole session
trialData.completedTrials = sessionVars.completedTrials; %when this trial starts not ends...
trialData.blockNum = sessionVars.blockNum;

%get image name and load image
trialData.imageName = MSITTaskSpecs.imageNames{sessionVars.blockNum}{sessionVars.completedTrials+1};
trialData.imageType = MSITTaskSpecs.categoryType{sessionVars.blockNum}(sessionVars.completedTrials+1); %good, bad, or neutral
imageMatrix = imread(trialData.imageName);
%--------------------------------------------------------------%




%---Setup the Eye tracker for a new Trial---%
if MSITOpts.eyeParams.eyeTrackerConnected
    if sessionVars.trialNum == 1 %close pretrial file
        closeLastTrialEyeTrackerFile(1,MSITOpts.fileParams)
    else %close alst trial file
        closeLastTrialEyeTrackerFile(sessionVars.trialNum,MSITOpts.fileParams);
    end
    openNewTrialEyeTrackerFile(sessionVars.trialNum,MSITOpts.fileParams.fileBaseName);
    
    %estimated block duration
    expectedTrialDuration = MSITOpts.timingParams.iti(2) + MSITOpts.timingParams.maxResponseTime;
    trialData.eyeSamples = NaN(4,1000*expectedTrialDuration);
else
    trialData.eyeSamples = [];
end

%setup LSL chunk/clear chunk
if ~isempty(lslInlet)
    lslInlet.pull_chunk(); %clean buffer
end

%cheater vars, only used if cheater is selected
trialData.cheaterRT = NaN;
trialData.cheaterID = NaN;
if any(contains(MSITOpts.cheaterMode.cheaterNames,MSITOpts.fileParams.subjID))
    trialData.cheaterID = contains(MSITOpts.cheaterMode.cheaterNames,MSITOpts.fileParams.subjID);
    cheaterRT = MSITOpts.cheaterMode.cheaterRTs{trialData.cheaterID};
    trialData.cheaterRT = cheaterRT(1) + (cheaterRT(2)-cheaterRT(1))*rand(1);
end

end


function MSITCloseTrial(MSITOpts,visEnviro,trialData,sessionVars,lslInlet)
%Seth Konig 2/18/2020 turned into own function
% Closes the trial and stores all the trial data
%simplified since pre-formatted data at opening of trial

if MSITOpts.eyeParams.eyeTrackerConnected
    try
        r = Eyelink('RequestTime');
        if r == 0
            WaitSecs(0.1); %superstition
            beforeTime = GetSecs();
            trackerTime = Eyelink('ReadTime'); % in ms
            afterTime = GetSecs();
            
            pcTime = mean([beforeTime,afterTime]); % in s
            trialData.pcTime = pcTime;
            trialData.trackerTime = trackerTime;
            trialData.trackerOffset = pcTime - (trackerTime./1000);
            % would make legit time = (eyeTimestamp/1000)+offset
        end
    catch
        disp(['Unable to Request Eye Tracker Time on block#' num2str(sessionVars.trialNum)])
    end
    
    %if last trial don't forget to move over file
    if sessionVars.trialNum == MSITOpts.trialParams.numTrials || sessionVars.quitTask
        %must add 1 to trialNum since it's usually for the last trial
        closeLastTrialEyeTrackerFile(sessionVars.trialNum+1,MSITOpts.fileParams);
    end
end

%save trial data
save([MSITOpts.fileParams.dataDirectory MSITOpts.fileParams.fileBaseName '_' num2str(sessionVars.trialNum) '.mat'],'trialData');

%save LSL data chunk
if ~isempty(lslInlet)
    [evoked, evokedt] = lslInlet.pull_chunk();
    save([MSITOpts.fileParams.dataDirectory MSITOpts.fileParams.fileBaseName '_eegChunk_' num2str(sessionVars.trialNum) '.mat'],'evoked','evokedt')
end

% Cleanup screen
% Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %clear screen
Screen(visEnviro.screen.window,'FillRect',0); %clear screen
Screen(visEnviro.screen.window,'Flip');
end
