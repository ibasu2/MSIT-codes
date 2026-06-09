function sessionVars = setupMSITSessionVars(MSITOpts)
%function setups up sessionVars variable...just easier & cleaner to do
%written by Seth Konig 2/24/21 based on N-back's version

%setup generic sessionVars
sessionVars = createSessionVars();

%save performance results for all tasks
sessionVars.totalReward =  0; %so can track at highest level easier

sessionVars.MSITPerformanceResults = []; 

%trial level stuff for tracking performance
sessionVars.MSITPerformanceResults.accuracy = NaN(1,MSITOpts.trialParams.numTrials);%correct incorrect
sessionVars.MSITPerformanceResults.RT = NaN(1,MSITOpts.trialParams.numTrials);%target = 1, nontarget = 0
sessionVars.MSITPerformanceResults.accuracyType = NaN(1,MSITOpts.trialParams.numTrials);%correct incorrect

end