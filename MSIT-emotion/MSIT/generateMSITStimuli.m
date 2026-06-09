function stimulusTable = generateMSITStimuli(MSITOpts)
%function generates list stimuli for trial and block structures to run task from
%written by Seth Konig on 2/23/21 based on code by Alik Widge

%--Trial Counterbalance Parameters---%
maxConditionsInARow = 3; %no more than 3 control/interferenece or same key responses in a row
numTrialsToCounterBalance = 48; %number of trials to generate per psuedo blocks then counter balance over


%---MSIT Stimulus Parameters---%
msitControl = {'100','020','003'};
msitInterfere = {'112','131','211','212','221','232','233','311','313','322','331','332'};



%---Determine How Many Trials Total Across Blocks----%
totalNumberTrials = MSITOpts.trialParams.numTrials;
numBlocksToGenerate = ceil(totalNumberTrials/numTrialsToCounterBalance);
if MSITOpts.stimParams.proportionControl ~= 0.5 || MSITOpts.stimParams.proportionInterference ~= 0.5
    error('we dont have code for this yet!')
else
    numControl = numTrialsToCounterBalance/length(msitControl)/2;
    numInterfere = numTrialsToCounterBalance/length(msitInterfere)/2;
    if rem(numControl,1) ~= 0 || rem(numInterfere,1) ~= 0
        error('need to return numbers to get whole numbers!')
    end
end


%---Create General Trial Structure for Task---%
% Finish assigning control/interference.
msitIDs = [repmat(msitControl,1,numControl)  repmat(msitInterfere,1,numInterfere)];
isControl = [ones(1,numTrialsToCounterBalance/2)  zeros(1,numTrialsToCounterBalance/2)];

% Pull out the correct response for each of those, will need it
% later for testing.
correctResponse = NaN(1,length(msitIDs)); %target is odd one out
flankers = NaN(1,length(msitIDs)); %flanking numbers i.e. non-target numbers
targetPosition = NaN(1,length(msitIDs)); %location of target
for thisStim = 1:length(msitIDs)
    theStim = str2num(char(msitIDs{thisStim}')); %#ok<ST2NM> %convert to numbers, str2double does not work here
    flankers(thisStim) = mode(theStim);
    targetPosition(thisStim) = find(theStim ~= flankers(thisStim));
    correctResponse(thisStim) = theStim(targetPosition(thisStim));
end

%do a quick sanity check
if ~all(targetPosition(isControl == 1) == correctResponse(isControl == 1))
    error('Control trials: something wrong with positions or responses!')
elseif any(targetPosition(isControl == 0) == correctResponse(isControl == 0))
    error('Interference trials: something wrong with positions or responses!')
end



%---Generate List of Stimuli---%
%create a matrix to determine if criterion was met
criterionIndeces = cell(1,maxConditionsInARow);
for mC = 1:maxConditionsInARow
    criterionIndeces{mC} = diag(ones(1,numTrialsToCounterBalance),mC); %create a diagonal matrix offset by min spacing
    criterionIndeces{mC} = criterionIndeces{mC}(1:numTrialsToCounterBalance,1:numTrialsToCounterBalance); %make sure same size as the data
end


%where to store permuted data
allStimuli = cell(1,totalNumberTrials);
allControls = NaN(1,totalNumberTrials);
allResponses = NaN(1,totalNumberTrials);
allFlankers = NaN(1,totalNumberTrials);
allTargetPositions = NaN(1,totalNumberTrials);
theseTrials = 1;
for block = 1:numBlocksToGenerate
    
   % Loop till we find one that matches our criterion
    reachedCriterion = 0;
    numPermutes = 0;
    while(~reachedCriterion)
        % Track how many it took.
        numPermutes = numPermutes + 1;
        
        % Permute the control and the interference separately, then
        randInd = randperm(numTrialsToCounterBalance);
        thisCorrectResponse = correctResponse(randInd);
        thisControl = isControl(randInd);
        
        %determine if meets criterion for responses (i.e. don't want the same response key too many times in a row
        correctDistance = pdist2(thisCorrectResponse',thisCorrectResponse');
        correctCriterion = NaN(sum(criterionIndeces{1}(:) == 1),maxConditionsInARow);
        for mC = 1:maxConditionsInARow
            results = correctDistance(criterionIndeces{mC} == 1) == 0;
            correctCriterion(1:length(results),mC) = results;
        end
        
        %check if this meets correct response criterion
        if any(nansum(correctCriterion,2) == maxConditionsInARow)
            continue
        end
        
        
        %determine if meets criterion for control/interfereence (i.e. dont want too many of the same conditions in a row)
        %seth cant get pdist2 to work on binary signals so brute forcing it
        metConditionCriterion = true;
        for stim = 1:numTrialsToCounterBalance-maxConditionsInARow
           if all(thisControl(stim:stim+maxConditionsInARow-1) == thisControl(stim))
               metConditionCriterion = false;
               break
           end
        end

        %check if this meets correct response criterion
        if ~metConditionCriterion
            continue
        else %met all criterion
           break 
        end
    end
    
    %store output
    allStimuli(theseTrials:theseTrials+numTrialsToCounterBalance-1) = msitIDs(randInd);
    allControls(theseTrials:theseTrials+numTrialsToCounterBalance-1) = thisControl;
    allResponses(theseTrials:theseTrials+numTrialsToCounterBalance-1) = thisCorrectResponse;
    allFlankers(theseTrials:theseTrials+numTrialsToCounterBalance-1) = flankers(randInd);
    allTargetPositions(theseTrials:theseTrials+numTrialsToCounterBalance-1) = targetPosition(randInd);
    
    theseTrials = theseTrials+numTrialsToCounterBalance;
end


%---Reformat Data to Table---%
stimulusTable = table(allStimuli',allControls',allResponses',allTargetPositions',allFlankers',...
    'VariableNames',{'stimulus','isControl','correctResponse','targetPosition','flankers'});

%trim for number of trials we are going to use
stimulusTable = stimulusTable(1:totalNumberTrials,:);

end