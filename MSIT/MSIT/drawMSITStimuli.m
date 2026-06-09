function drawMSITStimuli(visEnviro,eMSITTaskSpecs,numberString)
%function draws stimui
%written by Seth Konig 2/24/21

if length(eMSITTaskSpecs.stimuliLocation.xPosition) == 1
    % DrawFormattedText2(numberString,'win',visEnviro.screen.window,'sx','center','sy',eMSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','xlayout','left','winRect',r1,'baseColor',[0 0 0]);
    DrawFormattedText2(numberString,'win',visEnviro.screen.window,'sx','center','sy',eMSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','xlayout','left','baseColor',[255 255 255]);%,[0 0 0]);
else
    DrawFormattedText2(numberString(1),'win',visEnviro.screen.window,'sx',eMSITTaskSpecs.stimuliLocation.xPosition(1),'sy',eMSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','baseColor',[255 255 255]);%,[0 0 0]);
    DrawFormattedText2(numberString(2),'win',visEnviro.screen.window,'sx',eMSITTaskSpecs.stimuliLocation.xPosition(2),'sy',eMSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','baseColor',[255 255 255]);%,[0 0 0]);
    DrawFormattedText2(numberString(3),'win',visEnviro.screen.window,'sx',eMSITTaskSpecs.stimuliLocation.xPosition(3),'sy',eMSITTaskSpecs.stimuliLocation.yPosition,'xalign','center','yalign','center','baseColor',[255 255 255]);%,[0 0 0]);
end

end