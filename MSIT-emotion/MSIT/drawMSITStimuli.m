function drawMSITStimuli(visEnviro,MSITTaskSpecs,numberString)
%function draws stimui
%written by Seth Konig 2/24/21
%edited by Aniruddha Shekara 5/16/26
if length(MSITTaskSpecs.stimuliLocation.xPosition) == 1
    % DrawFormattedText2(numberString,'win',visEnviro.screen.window,'sx','center','sy',eMSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','xlayout','left','winRect',r1,'baseColor',[0 0 0]); %original
    DrawFormattedText2(numberString,'win',visEnviro.screen.window,'sx','center','sy',eMSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','xlayout','left','baseColor',[255 255 255]);%,[0 0 0]); Basu lab edit
else
    rect = CenterRectOnPoint([0 0 600 150],MSITTaskSpecs.stimuliLocation.xPosition(2),MSITTaskSpecs.stimuliLocation.yPosition);
    Screen('FillRect', visEnviro.screen.window, 0, rect);
    DrawFormattedText2(numberString(1),'win',visEnviro.screen.window,'sx',MSITTaskSpecs.stimuliLocation.xPosition(1),'sy',MSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','baseColor',[255 255 255]);%,[0 0 0]);
    DrawFormattedText2(numberString(2),'win',visEnviro.screen.window,'sx',MSITTaskSpecs.stimuliLocation.xPosition(2),'sy',MSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','baseColor',[255 255 255]);%,[0 0 0]);
    DrawFormattedText2(numberString(3),'win',visEnviro.screen.window,'sx',MSITTaskSpecs.stimuliLocation.xPosition(3),'sy',MSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','baseColor',[255 255 255]);%,[0 0 0]);
end

end