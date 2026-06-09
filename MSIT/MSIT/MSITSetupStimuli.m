function [MSITTaskSpecs,MSITOpts] = MSITSetupStimuli(MSITOpts, visEnviro)
% function sets up specific task stimluli struction for the MSIT task. Like
% the balloon, buttons, and their respective positions!
% wrtiten by Seth Konig 1/26/2021


%---Generate Stimuli & Block Structure---%
stimulusTable = generateMSITStimuli(MSITOpts);


%---Determine Where to Show---%
yPostion = visEnviro.screen.screenHeight/2;
if MSITOpts.stimParams.multipleLocations
    spacing = visEnviro.screen.screenWidth*MSITOpts.stimParams.spacing;
    center = visEnviro.screen.screenWidth/2;
    xPostion = [center-spacing center center+spacing];
else %center only
    xPostion = visEnviro.screen.screenWidth/2;
end



%---Stimulation Parameters---%
stimulationTrials = [];
if MSITOpts.taskTriggeredStimParams.useTaskTriggeredStim
    switch lower(MSITOpts.taskTriggeredStimParams.whichTrials)
        case 'randomblocks'
            if MSITOpts.taskTriggeredStimParams.propStimTrials ~= 0.5
                error('need to check something! Should be doing on 50% of trials!?')
            end
            nBlocks = ceil(MSITOpts.trialParams.numTrials/MSITOpts.taskTriggeredStimParams.trialsToCounterBalanceOver);
            if rem(nBlocks,2) ~= 0
                error('blocks dont divide well into trial count check stim parameters!')
            end
            nStimBlocks = nBlocks/2;
            for nSB = 1:nStimBlocks
                if rand(1) < 0.5
                   stimulationTrials = [stimulationTrials ones(1,MSITOpts.taskTriggeredStimParams.trialsToCounterBalanceOver) zeros(1,MSITOpts.taskTriggeredStimParams.trialsToCounterBalanceOver)]; 
                else
                   stimulationTrials = [stimulationTrials zeros(1,MSITOpts.taskTriggeredStimParams.trialsToCounterBalanceOver) ones(1,MSITOpts.taskTriggeredStimParams.trialsToCounterBalanceOver)]; 
                end
            end
            stimulationTrials = stimulationTrials(1:MSITOpts.trialParams.numTrials);%in case rounding caused errors
        otherwise
            error('trial types unknown')
    end
    
else
   stimulationTrials = false(1,MSITOpts.trialParams.numTrials);
end


%---Store Output---%
MSITTaskSpecs = [];

%which stimuli to show and block structure
MSITTaskSpecs.stimuli = stimulusTable;
MSITTaskSpecs.stimulationTrials = stimulationTrials;

%where to show
MSITTaskSpecs.stimuliLocation = [];
MSITTaskSpecs.stimuliLocation.xPosition = xPostion;
MSITTaskSpecs.stimuliLocation.yPosition = yPostion;

%save task parameters
save([MSITOpts.fileParams.dataDirectory MSITOpts.fileParams.fileBaseName '_taskVariables.mat'],'MSITOpts','visEnviro','MSITTaskSpecs');

end