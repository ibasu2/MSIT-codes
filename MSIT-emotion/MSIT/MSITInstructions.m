function MSITInstructions(MSITOpts,visEnviro,MSITTaskSpecs)
%shows instructions for the MSIT task
%written by Seth Konig 11/3/2022


%---Create Central Position Rectangles (rect) for Text---%
%create rectangle, doesn't have to be exact size
squareSize = 0.8*visEnviro.screen.screenHeight;
r0 = [0 0 squareSize squareSize]; %position invarient which will get translated

%create centralized rectangle
r1 = CenterRectOnPointd(r0, visEnviro.screen.screenWidth/2, visEnviro.screen.screenHeight/2);

%---Set Text Font & Style---%
Screen('TextSize',visEnviro.screen.window,MSITOpts.textParams.textSize); %font size
Screen('TextStyle',visEnviro.screen.window,0); %font style i.e. normal text vs bold
Screen('TextFont',visEnviro.screen.window,MSITOpts.textParams.textFont); %font type
% Screen('TextColor',visEnviro.screen.window,[1,1,1]); %font type
Screen('TextColor',visEnviro.screen.window,MSITOpts.textParams.textColor); %color


%brief wait for endering
WaitSecs(0.5);



%---Screen #1: General Task Description---%
%Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %Clears screen
% Screen(visEnviro.screen.window,'FillRect',0); %Clears screen

% text = strcat('Hello!','\n \n');
% text = strcat(text,'Now you are going to play odd-ball detection game. \n\n');
% text = strcat(text,'Now you are going to play a numbers game. \n\n');
% text = strcat(text,'You goal is to earn as many points as possible. \n');
% text = strcat(text,'At the end of this game your points will be tallied. \n');
% text = strcat(text,'If you earn enough points you get bonus points too!\n');
% text = strcat(text,'You will receive money based on the total points you earned. \n\n\n');
% text = strcat(text,'Press the space bar to continue.');
% DrawFormattedText2(text,'win',visEnviro.screen.window,'sx','center','sy','center','xalign','center','yalign','center','xlayout','left','winRect',r1);%,'baseColor',[0 0 0]);
% Screen(visEnviro.screen.window,'Flip');

% waitForKeyPress = true;
% while waitForKeyPress
%     [~, ~, keyCode] = KbCheck;
%     if keyCode(MSITOpts.KB.space)
%         waitForKeyPress = false;
%     end
%     WaitSecs(0.001);%so doesn't loop too fast
% end
% WaitSecs(0.5);



%---Screen #2: Trial Structure-Intro--%
% Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %Clears screen
Screen(visEnviro.screen.window,'FillRect',0); %Clears screen

%draw text
% text = 'Now we will discuss the task you must do to get points...\n\n\n';
text = strcat('Welcome to the numbers game! \n\n');
text = strcat(text,'Your goal is to identify the number that is not like the others,\n');
text = strcat(text,'and then press the button that corresponds to that number!\n\n');
text = strcat(text,'You should respond as quickly and accurately as possible!\n\n');
% text = strcat(text,'The amount of points you earn is based on your performance.\n');
text = strcat(text,'Press the space bar to continue.');
DrawFormattedText2(text,'win',visEnviro.screen.window,'sx','center','sy','center','xalign','center','yalign','center','xlayout','left','winRect',r1);%,'baseColor',[0 0 0]);

Screen('Flip',visEnviro.screen.window);

waitForKeyPress = true;
while waitForKeyPress
    [~, ~, keyCode] = KbCheck;
    if keyCode(MSITOpts.KB.space)
        waitForKeyPress = false;
    end
    WaitSecs(0.001);%so doesn't loop too fast
end
WaitSecs(0.5);


%---Screen #3: Trial Structure-Easy Example Trial#1--%
% Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %Clears screen
Screen(visEnviro.screen.window,'FillRect',0); %Clears screen

%draw text instructions
text = 'If you see these numbers on the screen...\n';
% text = strcat(text,'then you should press the 1 key!\n\n\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'then you should press the 1 key!\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'Press the 1 key to continue.');
DrawFormattedText2(text,'win',visEnviro.screen.window,'sx','center','sy',visEnviro.screen.screenHeight*0.33,'xalign','center','yalign','center','xlayout','left','winRect',r1);%,'baseColor',[0 0 0]);

%draw stimuli
drawMSITStimuli(visEnviro,MSITTaskSpecs,'<size=120>100')

Screen('Flip',visEnviro.screen.window);

if strcmpi(MSITOpts.responseMode.type,'RB-740')
    CedrusResponseBox('FlushEvents', MSITOpts.responseMode.responsePadHandle); %get rid of stale inputs
    waitForKeyPress = true;
    while waitForKeyPress
        evt = CedrusResponseBox('GetButtons', MSITOpts.responseMode.responsePadHandle);
        if ~isempty(evt) && evt.action == 1 %key pressed
            if evt.button == visEnviro.rig.responsePad1
                waitForKeyPress = false;
            end
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
else
    waitForKeyPress = true;
    while waitForKeyPress
        [~, ~, keyCode] = KbCheck;
        if keyCode(MSITOpts.KB.onekey)
            waitForKeyPress = false;
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
end
WaitSecs(0.5);


%---Screen #4: Trial Structure-Easy Example Trial#2--%
% Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %Clears screen
Screen(visEnviro.screen.window,'FillRect',0); %Clears screen

%draw text instructions
text = 'If you see these numbers on the screen...\n';
% text = strcat(text,'then you should press the 2 key!\n\n\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'then you should press the 2 key!\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'Press the 2 key to continue.');
DrawFormattedText2(text,'win',visEnviro.screen.window,'sx','center','sy',visEnviro.screen.screenHeight*0.33,'xalign','center','yalign','center','xlayout','left','winRect',r1);%,'baseColor',[0 0 0]);

%draw stimuli
drawMSITStimuli(visEnviro,MSITTaskSpecs,'<size=120>020')

Screen('Flip',visEnviro.screen.window);

if strcmpi(MSITOpts.responseMode.type,'RB-740')
    CedrusResponseBox('FlushEvents', MSITOpts.responseMode.responsePadHandle); %get rid of stale inputs
    waitForKeyPress = true;
    while waitForKeyPress
        evt = CedrusResponseBox('GetButtons', MSITOpts.responseMode.responsePadHandle);
        if ~isempty(evt) && evt.action == 1 %key pressed
            if evt.button == visEnviro.rig.responsePad2
                waitForKeyPress = false;
            end
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
else
    waitForKeyPress = true;
    while waitForKeyPress
        [~, ~, keyCode] = KbCheck;
        if keyCode(MSITOpts.KB.twokey)
            waitForKeyPress = false;
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
end
WaitSecs(0.5);


%---Screen #5: Trial Structure-Easy Example Trial#3--%
% Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %Clears screen
Screen(visEnviro.screen.window,'FillRect',0); %Clears screen

%draw text instructions
text = 'If you see these numbers on the screen...\n';
% text = strcat(text,'then you should press the 3 key!\n\n\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'then you should press the 3 key!\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'Press the 3 key to continue.');
DrawFormattedText2(text,'win',visEnviro.screen.window,'sx','center','sy',visEnviro.screen.screenHeight*0.33,'xalign','center','yalign','center','xlayout','left','winRect',r1);%,'baseColor',[0 0 0]);

%draw stimuli
drawMSITStimuli(visEnviro,MSITTaskSpecs,'<size=120>003')

Screen('Flip',visEnviro.screen.window);

if strcmpi(MSITOpts.responseMode.type,'RB-740')
    CedrusResponseBox('FlushEvents', MSITOpts.responseMode.responsePadHandle); %get rid of stale inputs
    waitForKeyPress = true;
    while waitForKeyPress
        evt = CedrusResponseBox('GetButtons', MSITOpts.responseMode.responsePadHandle);
        if ~isempty(evt) && evt.action == 1 %key pressed
            if evt.button == visEnviro.rig.responsePad3
                waitForKeyPress = false;
            end
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
else
    waitForKeyPress = true;
    while waitForKeyPress
        [~, ~, keyCode] = KbCheck;
        if keyCode(MSITOpts.KB.threekey)
            waitForKeyPress = false;
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
end
WaitSecs(0.5);


%---Screen #6: Trial Structure-Harder Example Trial#4--%
% Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %Clears screen
Screen(visEnviro.screen.window,'FillRect',0); %Clears screen

%draw text instructions
text = 'Some trials will be harder!\n';
text = strcat(text,'If you see these numbers on the screen.\n');
% text = strcat(text,'then you should press the 1 key!\n\n\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'then you should press the 1 key!\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'Press the 1 key to continue.');
DrawFormattedText2(text,'win',visEnviro.screen.window,'sx','center','sy',visEnviro.screen.screenHeight*0.33,'xalign','center','yalign','center','xlayout','left','winRect',r1);%,'baseColor',[0 0 0]);

%draw stimuli
drawMSITStimuli(visEnviro,MSITTaskSpecs,'<size=120>313')

Screen('Flip',visEnviro.screen.window);

if strcmpi(MSITOpts.responseMode.type,'RB-740')
    CedrusResponseBox('FlushEvents', MSITOpts.responseMode.responsePadHandle); %get rid of stale inputs
    waitForKeyPress = true;
    while waitForKeyPress
        evt = CedrusResponseBox('GetButtons', MSITOpts.responseMode.responsePadHandle);
        if ~isempty(evt) && evt.action == 1 %key pressed
            if evt.button == visEnviro.rig.responsePad1
                waitForKeyPress = false;
            end
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
else
    waitForKeyPress = true;
    while waitForKeyPress
        [~, ~, keyCode] = KbCheck;
        if keyCode(MSITOpts.KB.onekey)
            waitForKeyPress = false;
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
end
WaitSecs(0.5);


%---Screen #7: Trial Structure-Hadrer Example Trial#5--%
%Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %Clears screen
Screen(visEnviro.screen.window,'FillRect',0); %Clears screen

%draw text instructions
text = 'This is another example of a harder trial!\n';
text = strcat(text,'If you see these numbers on the screen.\n');
% text = strcat(text,'then you should press the 2 key!\n\n\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'then you should press the 2 key!\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'Press the 2 key to continue.');
DrawFormattedText2(text,'win',visEnviro.screen.window,'sx','center','sy',visEnviro.screen.screenHeight*0.33,'xalign','center','yalign','center','xlayout','left','winRect',r1);%,'baseColor',[0 0 0]);

%draw stimuli
drawMSITStimuli(visEnviro,MSITTaskSpecs,'<size=120>211')

Screen('Flip',visEnviro.screen.window);

if strcmpi(MSITOpts.responseMode.type,'RB-740')
    CedrusResponseBox('FlushEvents', MSITOpts.responseMode.responsePadHandle); %get rid of stale inputs
    waitForKeyPress = true;
    while waitForKeyPress
        evt = CedrusResponseBox('GetButtons', MSITOpts.responseMode.responsePadHandle);
        if ~isempty(evt) && evt.action == 1 %key pressed
            if evt.button == visEnviro.rig.responsePad2
                waitForKeyPress = false;
            end
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
else
    waitForKeyPress = true;
    while waitForKeyPress
        [~, ~, keyCode] = KbCheck;
        if keyCode(MSITOpts.KB.twokey)
            waitForKeyPress = false;
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
end
WaitSecs(0.5);


%---Screen #8: Trial Structure-Hadrer Example Trial#6--%
% Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %Clears screen
Screen(visEnviro.screen.window,'FillRect',0); %Clears screen

%draw text instructions
text = 'This is another example of a harder trial!\n';
text = strcat(text,'If you see these numbers on the screen.\n');
% text = strcat(text,'then you should press the 3 key!\n\n\n\n\n\n\n\n\n\n\n\n\n');
text = strcat(text,'then you should press the 3 key!\n\n\n\n\n\n\n\n\n\n\n');

text = strcat(text,'Press the 3 key to continue.');
DrawFormattedText2(text,'win',visEnviro.screen.window,'sx','center','sy',visEnviro.screen.screenHeight*0.33,'xalign','center','yalign','center','xlayout','left','winRect',r1);%,'baseColor',[0 0 0]);

%draw stimuli
drawMSITStimuli(visEnviro,MSITTaskSpecs,'<size=120>131')

Screen('Flip',visEnviro.screen.window);

if strcmpi(MSITOpts.responseMode.type,'RB-740')
    CedrusResponseBox('FlushEvents', MSITOpts.responseMode.responsePadHandle); %get rid of stale inputs
    waitForKeyPress = true;
    while waitForKeyPress
        evt = CedrusResponseBox('GetButtons', MSITOpts.responseMode.responsePadHandle);
        if ~isempty(evt) && evt.action == 1 %key pressed
            if evt.button == visEnviro.rig.responsePad3
                waitForKeyPress = false;
            end
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
else
    waitForKeyPress = true;
    while waitForKeyPress
        [~, ~, keyCode] = KbCheck;
        if keyCode(MSITOpts.KB.threekey)
            waitForKeyPress = false;
        end
        WaitSecs(0.001);%so doesn't loop too fast
    end
end
WaitSecs(0.5);




%---Screen #9: Summary--%
%Screen(visEnviro.screen.window,'FillRect',visEnviro.rig.colorDepth/2); %Clears screen
Screen(visEnviro.screen.window,'FillRect',0); %Clears screen

%draw text instructions
text = 'To summarize, you will be playing a game in which you need to identify \n';
text = strcat(text,'the number that is not like the others, and then\n');
text = strcat(text,'press the key that corresponds to this number.\n\n');
text = strcat(text,'Some trials will be easier in which the number that is different\n');
text = strcat(text,'is in the same position as its value. For example 100!\n\n');
text = strcat(text,'Some trials will be harder in which the value of the number that is different\n');
text = strcat(text,'is not the same as its position. For example 212!\n\n');
% text = strcat(text,'Some trials may  background that may be disturbing. \n\n');
% text = strcat(text,'These pictures do not  \n\n');
% text = strcat(text,'Please let us know at any time if you wish to stop looking at these pictures! \n');
% text = strcat(text,'Your goal is to earn as many points as possible.\n');
% text = strcat(text,'Try to perform this task as quickly and accurately as possible!\n\n');
text = strcat(text,'Your goal is to perform this task as quickly and accurately as possible.\n\n');
text = strcat(text,'Press the space bar to start the game!');
DrawFormattedText2(text,'win',visEnviro.screen.window,'sx','center','sy','center','xalign','center','yalign','center','xlayout','left','winRect',r1);%,'baseColor',[0 0 0]);

Screen('Flip',visEnviro.screen.window);

waitForKeyPress = true;
while waitForKeyPress
    [~, ~, keyCode] = KbCheck;
    if keyCode(MSITOpts.KB.space)
        waitForKeyPress = false;
    end
    WaitSecs(0.001);%so doesn't loop too fast
end
WaitSecs(0.5);


end