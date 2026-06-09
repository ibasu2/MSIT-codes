function [MSITTaskSpecs,MSITOpts] = MSITSetupStimuli(MSITOpts, visEnviro)
% function sets up specific task stimluli struction for the MSIT task. Like
% the balloon, buttons, and their respective positions!
% wrtiten by Seth Konig 1/26/2021


%---Generate Stimuli & Block Structure---%
stimulusTable = generateMSITStimuli(MSITOpts);


%---Determine Where to Show---%
if MSITOpts.stimParams.showWithImage
    yPostion = visEnviro.screen.screenHeight/2+250;
else
    yPostion = visEnviro.screen.screenHeight/2;
end
if MSITOpts.stimParams.multipleLocations
    spacing = visEnviro.screen.screenWidth*MSITOpts.stimParams.spacing;
    center = visEnviro.screen.screenWidth/2;
    xPostion = [center-spacing center center+spacing];
else %center only
    xPostion = visEnviro.screen.screenWidth/2;
end


%---From lppEmotionSetupStimuli.m: Check That Stimulus [sub]Directory(s) Exist---%
numberCategories = length(MSITOpts.fileParams.stimulusSubDirectories);
if ~exist(MSITOpts.fileParams.stimulusDirectory,'dir')
    error('Stimulus Directory Does not Exist! Please change location in _params file!')
else
    % if numberCategories ~= 3
    %     error('Code is setup to read image categories from 3 subdirectories...')
    % else
        for sd = 1:numberCategories
            if ~exist([MSITOpts.fileParams.stimulusDirectory MSITOpts.fileParams.stimulusSubDirectories{sd}],'dir')
                error(['Subdirectory for ' MSITOpts.fileParams.stimulusSubDirectories{sd} ' does not exist!'])
            end
        end
    % end
end

%---From lppEmotionSetupStimuli.m: Read in All Image Information---%
allCompleteFileNames = cell(1,numberCategories);
allImageInfo = cell(1,numberCategories);
numberOfImages = ones(1,numberCategories);%in each category
for sd = 1:numberCategories
    fullSubDirName = [MSITOpts.fileParams.stimulusDirectory MSITOpts.fileParams.stimulusSubDirectories{sd} filesep];
    ls = dir(fullSubDirName); %get list of all files in directory
    
    for file = 1:length(ls)
        if ~ls(file).isdir
            if contains(lower(ls(file).name),'.jpg')
                allCompleteFileNames{sd}{numberOfImages(sd)} = [fullSubDirName ls(file).name];
                allImageInfo{sd}{numberOfImages(sd)} = imfinfo(allCompleteFileNames{sd}{numberOfImages(sd)});
                numberOfImages(sd) = numberOfImages(sd)+1;
            else
                disp(['Found file that was not an image: ' ls(file).name]);
            end
        end
    end
end
numberOfImages = numberOfImages-1;
totalImageCount = sum(numberOfImages);

if ~all(numberOfImages == numberOfImages(1))
    error('Number of images per category is not the same!')
end

if sum(totalImageCount) < MSITOpts.trialParams.numTrials
    error('Not enough images to run this task!')
end

%---Check that images are all the same size---%
width1 = allImageInfo{1}{1}.Width;
height1 = allImageInfo{1}{1}.Height;
depth1 = allImageInfo{1}{1}.BitDepth;
for sd = 1:numberCategories
    for img = 1:numberOfImages(sd)
        if allImageInfo{sd}{img}.Width ~= width1 || allImageInfo{sd}{img}.Height ~= height1 ...
                || allImageInfo{sd}{img}.BitDepth ~= depth1
            error(['Image file size not the same as the others: ' allImageInfo{sd}{img}.FileName]);
        end
    end
end

%---Organize Images by Block---%
%want to counterbalance so same number of each category of image per block...
numberImagesPerBlock = totalImageCount/MSITOpts.trialParams.nBlocks;
if rem(numberImagesPerBlock,numberCategories) ~= 0
    error('No way to perfectly counter balance images across blocks!')
end
imagesPerBlockPerCategory = numberImagesPerBlock/numberCategories;


%grab all image and category numbers
categoryNumber = [];
imageNumber = []; %in cell above, i.e. category
for sd = 1:numberCategories
    categoryNumber = [categoryNumber sd*ones(1,numberOfImages(sd))];
    imageNumber = [imageNumber 1:numberOfImages(sd)];
end

%counter balance categories across blocks
blockNumber = [];
for sd = 1:numberCategories
    theseBlocks = [];
    for block = 1:MSITOpts.trialParams.nBlocks
        theseBlocks = [theseBlocks block*ones(1,imagesPerBlockPerCategory)];
    end
    theseBlocks = theseBlocks(randperm(length(theseBlocks)));
    blockNumber = [blockNumber theseBlocks];
end

%organize images by block
blockImageNumber = cell(1,MSITOpts.trialParams.nBlocks); %number in category
blockCategories = cell(1,MSITOpts.trialParams.nBlocks);
for block = 1:MSITOpts.trialParams.nBlocks
    %find and store images for this block
    theseImages = find(blockNumber == block);
    blockImageNumber{block} = imageNumber(theseImages);
    blockCategories{block} = categoryNumber(theseImages);
    
    %shuffle order of for this block
    reorder = randperm(numberImagesPerBlock);
    blockImageNumber{block} = blockImageNumber{block}(reorder);
    blockCategories{block} = blockCategories{block}(reorder);
end

%get image names by block, could do this above but may want to keep independent.
blockImageNames = cell(1,MSITOpts.trialParams.nBlocks);
for block = 1:MSITOpts.trialParams.nBlocks
    blockImageNames{block} = cell(1,numberImagesPerBlock);
    for img = 1:numberImagesPerBlock
        blockImageNames{block}{img} = allCompleteFileNames{blockCategories{block}(img)}{blockImageNumber{block}(img)};
    end
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

%---From lppEmotionSetupStimuli.m: Store Task Specs Output---%
MSITTaskSpecs.imageWidth = width1;
MSITTaskSpecs.imageHeight = height1;

MSITTaskSpecs.totalNumberOfImages = totalImageCount;
MSITTaskSpecs.numberOfImagesPerCategory = numberOfImages;
MSITTaskSpecs.numberImagesPerBlock = numberImagesPerBlock;

MSITTaskSpecs.categoryNames = MSITOpts.fileParams.stimulusSubDirectories;
MSITTaskSpecs.categoryType = blockCategories;%category index
MSITTaskSpecs.imageNames = blockImageNames;

%save task parameters
save([MSITOpts.fileParams.dataDirectory MSITOpts.fileParams.fileBaseName '_taskVariables.mat'],'MSITOpts','visEnviro','MSITTaskSpecs');

end