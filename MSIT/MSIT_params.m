function MSITOpts = MSIT_params(subjID,useTaskTriggeredStim)
%function sets generate parameters for task, this is the only place you
%should have to do this.
%turned into function by Seth Konig 2/17/20, and compiled all the necessary
%task variables here.

MSITOpts = struct;

%---File & Directory parameters---%
mainFolderName = 'MSIT';
thisPath = mfilename('fullpath');
mainFolderStart = strfind(thisPath,mainFolderName);
MSITFolder = thisPath(1:mainFolderStart+length(mainFolderName));
cd(MSITFolder)

MSITOpts.fileParams.MSITFolder = MSITFolder;
MSITOpts.fileParams.createEDFFile = true;
MSITOpts.fileParams.subjID = subjID;
MSITOpts.fileParams.taskName = 'MSIT';
[MSITOpts.fileParams.fileBaseName,MSITOpts.fileParams.subjectDir,MSITOpts.fileParams.dataDirectory] = ...
    hdLabSetFileNames(subjID,MSITOpts.fileParams.taskName);
MSITOpts.fileParams.eyeDataFolder = [MSITOpts.fileParams.dataDirectory 'eyeData' filesep];
MSITOpts.fileParams.stimulusDirectory = [MSITFolder 'MSIT' filesep 'stimuli' filesep];


%---Trial Parameters---%
MSITOpts.trialParams.numTrials = 96; %should be even number


%---Timing Parameters---%
%all values in seconds
MSITOpts.timingParams.drawTime = @(x) min(x) + (range(x) .* rand(1,1));

%trial timing
MSITOpts.timingParams.iti = [2,3];% time between blocks (i.e inter-block interval)
MSITOpts.timingParams.maxResponseTime = 3; %in seconds


%---Stimulus Parameters---%
%stimulus information
MSITOpts.stimParams.multipleLocations = false; %if true displays stimuli appart, if false all in center of screen
MSITOpts.stimParams.spacing = 0.125; %proportion of screen size
MSITOpts.stimParams.proportionControl = 0.5;%control conditions with just 1 target i.e. 100, 020, 003
MSITOpts.stimParams.proportionInterference = 0.5;%control conditions with just 1 target i.e. 100, 020, 003


%---Text Parameters---%
MSITOpts.textParams.textColor = [255, 255, 255];% [0 0 0]; %original was on dark background[150, 150, 150];
MSITOpts.textParams.textSize = 50; %original was 40
MSITOpts.textParams.stimTextSize = 300; %60; %original was 40
MSITOpts.textParams.textFont = 'Arial';


%---Input Options---%
%keyboard: 1 target, 2 non-target
%reponse pad: green target, red non-target
MSITOpts.responseMode = [];
MSITOpts.responseMode.type = 'keyBoard';%current options: responsePad or keyBoard
MSITOpts.responseMode.connected = false; %keep false


%---Eye tracker parameters---%
MSITOpts.eyeParams.eyeTrackingMode = 'none';%'passive' else, 'none' for no tracking; could make active?
MSITOpts.eyeParams.eyeTrackerConnected = false;


%---Task-Triggered Stimulation Parameters--%
%all stimulation specific parameters (e.g. pulse width,amplitude, etc) are
%coded on the blackrock cerestim and not here!
MSITOpts.taskTriggeredStimParams = [];
MSITOpts.taskTriggeredStimParams.useTaskTriggeredStim = useTaskTriggeredStim;
if useTaskTriggeredStim
    MSITOpts.taskTriggeredStimParams.whichTrials = 'randomBlocks';%currently only supports random
    MSITOpts.taskTriggeredStimParams.propStimTrials = 0.5;% 50% of random trials in block fasion
    MSITOpts.taskTriggeredStimParams.trialsToCounterBalanceOver = 10;
    %psuedorandomize over these trials, should divide into total trial count (usually multiples of 100)
    MSITOpts.taskTriggeredStimParams.stimPeriod = 'stimulusOn';
    MSITOpts.taskTriggeredStimParams.postEventDelay = 0;%seconds
end

%---Debug Parameters---%
MSITOpts.debugMode = false; %flags extra print functions in mutliple locations

%cheater modes are autoplayers with different perofmances i.e. accurancy and speed
%cheater mode is activated by setting subject ID to one of the cheater names
MSITOpts.cheaterMode.cheaterNames = {'Cheater','Naive','Troll'};%acceptable autoplayer names, don't modify without modifying code
MSITOpts.cheaterMode.cheaterRTs = {[0.5 1.5],[0.5 1.5],[1.0 1.0]};%rts for various selection/fixation epochs
MSITOpts.cheaterMode.cheaterNames = cellfun(@lower, MSITOpts.cheaterMode.cheaterNames,'UniformOutput',false);%lower all

end