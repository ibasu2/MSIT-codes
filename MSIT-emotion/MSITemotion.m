function MSITemotion(subjID,showInstructions,usingLSL,useTaskTriggeredStim)
% MSIT.m
% The new Matlab version of the MSIT (Multisource Interference Task) task
% without efficacy!
% Original written by Seth Konig 11/3/2022 based on MSIT with efficacy part of the
% code stripped out!
% Further adapted by Aniruddha Shekara 5/2/2026 to add emotional/neutral
% images during ITI prior to stimulus presentation
%
%
% Inputs:
%   1) subjID: name of files to be saved as data output
%   2) showInstructions: true/false to shows Instructions!
%   3) usingLSL: true/false flag for whether using LSL lab-streaming-layer
%   4) useTaskTriggeredStim: true/false flag for if using task-triggered


%add all folders and subfolders to path
mainFolderName = 'MSIT-emotion';
thisFunctionPath = mfilename('fullpath');
mainFolderStart = strfind(thisFunctionPath,mainFolderName);
addpath(genpath(thisFunctionPath(1:mainFolderStart+length(mainFolderName))));

if nargin < 1
    error('Patient not listed. Please at least include the patient number e.g. P999')
end
if nargin < 2
    showInstructions = true;
end
if nargin < 3
    usingLSL = false;
end
if nargin < 4
    useTaskTriggeredStim = false;
end



%setup LSL if using it
if usingLSL
    lslInlet = setupLSL();
else
    lslInlet = [];
end



%---Do Task Setup and Initiate All Variables/Parameters---%
try %for task setup
    
    ListenChar(2);
    
    %Setup Task
    MSITOpts = MSIT_params(subjID,useTaskTriggeredStim); % Load & store the task parameters
    [eyeTrackerhHandle,visEnviro,MSITOpts,ttlStruct] = MSITOpenTask(MSITOpts); % general rig stuff, seperate function in case need task specific
    [MSITTaskSpecs, MSITOpts] = MSITSetupStimuli(MSITOpts,visEnviro);  % specific task function for reward and Stimuli
    HideCursor();

catch ME
    disp('Unable to start task!');
    if exist('ttlStruct','var') == 1
        closeTask(ttlStruct,visEnviro);
    else
        closeTask();
    end
    if strcmpi(MSITOpts.responseMode.type,'RB-740')
        %dont need to check if connected because if error crashed after connected it may not be saved
        CedrusResponseBox('CloseAll');
    end
    rethrow(ME)
end



%---Show Instructions---%
%added try catch me statement because requires user input for practice
%which means hardware issues could arise!
if showInstructions
try
    MSITInstructions(MSITOpts,visEnviro,MSITTaskSpecs);
catch ME
    disp('Unable to complete instructions!');
    if exist('ttlStruct','var') == 1
        closeTask(ttlStruct,visEnviro);
    else
        closeTask();
    end
    if strcmpi(MSITOpts.responseMode.type,'RB-740')
        %dont need to check if connected because if error crashed after connected it may not be saved
        CedrusResponseBox('CloseAll');
    end
    rethrow(ME)
end
end


%---Run task---%
sessionVars = setupMSITSessionVars(MSITOpts); %create variables for tracking across trials and blocks
sessionVars = MSITRunTrial(MSITOpts,MSITTaskSpecs,sessionVars,visEnviro,eyeTrackerhHandle,ttlStruct,lslInlet);
save([MSITOpts.fileParams.dataDirectory MSITOpts.fileParams.fileBaseName '_sessionVars.mat'],'sessionVars');



%---End Task & Clean Up---%
try
    thankYouText = 'Thank you!';
    DrawFormattedText(visEnviro.screen.window,thankYouText,'center', 'center');
    markEvent('taskStop',NaN,ttlStruct,visEnviro.screen.window,MSITOpts.eyeParams.eyeTrackerConnected,1);
    WaitSecs(2);
    closeTask(ttlStruct); % general rig specific function
    if exist('MSITOpts','var') == 1
        if strcmpi(MSITOpts.responseMode.type,'RB-740')
            %dont need to check if connected because if error crashed after connected it may not be saved
            CedrusResponseBox('CloseAll');
        end
    end

    %close LSL lsllslInlet if using LSL
    if ~isempty(lslInlet)
        close lslInlet
    end

catch
    disp('Unable to end task properly...likely from quitting and screen being closed!');
    if exist('ttlStruct','var') == 1
        closeTask(ttlStruct);
    else
        closeTask();
    end
    if exist('MSITOpts','var') == 1
        if strcmpi(MSITOpts.responseMode.type,'RB-740')
            %dont need to check if connected because if error crashed after connected it may not be saved
            CedrusResponseBox('CloseAll');
        end
    end
end

MSITPerformanceResults = sessionVars.MSITPerformanceResults;
accuracy = nanmean(MSITPerformanceResults.accuracy==1);
meanRT = nanmean(MSITPerformanceResults.RT);
disp(['Mean Accuracy: ', num2str(accuracy)])
disp(['Mean RT: ', num2str(meanRT)])

end