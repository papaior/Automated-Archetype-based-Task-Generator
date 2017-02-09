load('SSASpecs.mat');

%specify grid dimensions and position
grid.rectsize = [res.width*1/5 res.height*1/5]; %size of one grid rectangle
grid.pos = [res.width*1/12 res.height*1/8]; %starting position of the grid (defined at top left)
grid.border = [grid.pos grid.pos+3*grid.rectsize]; %square making outer grid border
grid.lines = [grid.pos(1) (grid.pos(1)+3*grid.rectsize(1)) grid.pos(1) (grid.pos(1)+3*grid.rectsize(1)) (grid.pos(1)+1*grid.rectsize(1)) (grid.pos(1)+1*grid.rectsize(1)) (grid.pos(1)+2*grid.rectsize(1)) (grid.pos(1)+2*grid.rectsize(1)); ... %x coordinates (pairs of cooedinates denote the start and end of a line)
  (grid.pos(2)+1*grid.rectsize(2)) (grid.pos(2)+1*grid.rectsize(2)) (grid.pos(2)+2*grid.rectsize(2)) (grid.pos(2)+2*grid.rectsize(2)) grid.pos(2) (grid.pos(2)+3*grid.rectsize(2)) grid.pos(2) (grid.pos(2)+3*grid.rectsize(2))]; %y coordinates
grid.linewidth = 5;

%Specify screen propagation buttons
sp.rectsize = [res.width*1/8 res.height*1/11]; %button size
sp.pos = [res.width*1/5 grid.border(4)+ grid.rectsize(2)/2;...
  res.width*4/5-sp.rectsize(1) grid.border(4)+ grid.rectsize(2)/2]; %starting positions for the two buttons
sp.col = white/1.8*[1.2 1.2 1];
sp.framecol = white/1.5;
sp.textcol = black;
sp.textsize = round(res.height/30);
sp.linewidth = 2;

sp.button1 = [sp.pos(1,:) sp.pos(1,:)+sp.rectsize];
sp.button2 = [sp.pos(2,:) sp.pos(2,:)+sp.rectsize];

%specify response buttons (depends on task)
buttons.col = white/1.8*[1 1 1.7];

buttons.framecol = white/1.5;
buttons.textcol = black;
buttons.textsize = round(res.height/40);
buttons.linewidth = 2;
rb.area = [grid.border(3)+(res.width-grid.border(3))/10 grid.border(2) res.width-(res.width-grid.border(3))/10 grid.border(4)]; %defines area where buttons can be placed. It corresponds to the area directly to the left of the grid, with a 10% margin at left and right
rb.width = rb.area(3)-rb.area(1); %the width of rb.area
rb.height = rb.area(4)-rb.area(2); %the height
if SSA.presence %if the response is present/absent, we need 2 buttons
  buttons.loc(1,:) = [(rb.area(1)+rb.width*1/3) (rb.area(2)+rb.height*1/5) (rb.area(1)+rb.width*2/3)  (rb.area(2)+rb.height*2/5)];
  buttons.label(1) = {'Present'};
  buttons.loc(2,:) = [(rb.area(1)+rb.width*1/3) (rb.area(2)+rb.height*3/5) (rb.area(1)+rb.width*2/3)  (rb.area(2)+rb.height*4/5)];
  buttons.label(2) = {'Absent'};
  numbuttons = 2;
  
else
  reportdims = fieldnames(SSA.report);
  
  numbuttons = 2*length(reportdims);
  for ith = 1:numbuttons
    buttons.loc(ith,:) = [(rb.area(1)+rb.width*1/3) (rb.area(2)+rb.height*(2*ith-1)/(2*numbuttons+1)) (rb.area(1)+rb.width*2/3)  (rb.area(2)+rb.height*(2*ith)/(2*numbuttons+1))];
  end
  buttons.label = {SSA.report.(reportdims{1}),sprintf('not %s',SSA.report.(reportdims{1}))};
  for ith = 1:length(buttons.label) %if report dimension is shape, change labels of shapes to actual shapes
    
    l = buttons.label{ith};
    switch l
      case 'rectangle'
        buttons.label{ith} = '#';
      case 'triangle'
        buttons.label{ith} = '^';
      case 'oval'
        buttons.label{ith} = '*';
      case 'diamond'
        buttons.label{ith} = '$';
    end
  end
end

%open onscreen and offscreen windows

blank = Screen('OpenOffscreenWindow',screenNumber,bgcol,rect);%this is an empty offscreen window
letterscreen = Screen('OpenOffscreenWindow',screenNumber,grid.bgcol,rect);%used to print letters in
testscreen = Screen('OpenOffscreenWindow',screenNumber,bgcol,rect);%this is also empty
mOScreen = Screen('OpenOffscreenWindow',screenNumber,bgcol,rect);%this is also empty
%responce button screen
buttonsscreen = Screen('OpenOffscreenWindow',screenNumber,bgcol,rect);
for ith = 1:length(buttons.label)
  Screen('FillRect',buttonsscreen,buttons.col,buttons.loc(ith,:));% Same process as above, done for every button
  Screen('FrameRect',buttonsscreen,buttons.framecol,buttons.loc(ith,:),buttons.linewidth);
  Screen('TextSize',buttonsscreen,buttons.textsize);
  DrawFormattedText(buttonsscreen, buttons.label{ith} ,'center','center',sp.textcol,[],[],[],[],[],buttons.loc(ith,:  ));
end
%continue button screen
repbuttonsscreen = Screen('OpenOffscreenWindow',screenNumber,bgcol,rect);
Screen('FillRect',repbuttonsscreen,buttons.col,buttons.loc(1,:));% Same process as above, done for every button
Screen('FrameRect',repbuttonsscreen,buttons.framecol,buttons.loc(1,:),buttons.linewidth);
Screen('TextSize',repbuttonsscreen,buttons.textsize);
DrawFormattedText(repbuttonsscreen, 'Continue' ,'center','center',sp.textcol,[],[],[],[],[],buttons.loc(1,:  ));

%grid texture
gridscreen = Screen('OpenOffscreenWindow',screenNumber,bgcol,rect);%Also starts empty, but all the common structures will be added further along
%Screen('DrawTexture',gridscreen,buttonsscreen);%adds the responce buttons
Screen('FillRect',gridscreen,grid.bgcol,grid.border);%creates the background for the grid
Screen('FrameRect',gridscreen,grid.col,grid.border,grid.linewidth);%creates the outline of the entire grid
Screen('DrawLines',gridscreen,grid.lines,grid.linewidth,grid.col);%draws the inner lines
%add screen propagation buttons
Screen('FillRect',gridscreen,sp.col,sp.button1); %Draws the rectangle for button 1 ('previous')
Screen('FrameRect',gridscreen,sp.framecol,sp.button1,sp.linewidth);%outlines it in grey
Screen('TextSize',gridscreen,sp.textsize);
DrawFormattedText(gridscreen,'Prev','center','center',sp.textcol,[],[],[],[],[],sp.button1);%prints 'prev' in the center of the rectangle. Bunch of text wrapping options left unspecified
Screen('FillRect',gridscreen,sp.col,sp.button2);% Same process for button 2 ('next')
Screen('FrameRect',gridscreen,sp.framecol,sp.button2,sp.linewidth);
Screen('TextSize',gridscreen,sp.textsize);
DrawFormattedText(gridscreen, 'Next ' ,'center','center',sp.textcol,[],[],[],[],[],sp.button2);

%open logfile
log = fopen(filename,'a+');
fprintf(log,'Date\tTime\tTrial\tResponse\tCorrectResponse\tAccuracy\tTargetScreenNo\tTargetLoc\n');

%  present trials
trial = 1;
replay = 0;
while trial <= size(stims,1)
  %present instructions
  if replay %if replaying, show replay instructions
    %Screen('DrawTexture',expWin,repbuttonsscreen)
    Screen('TextSize',expWin,txtsize);
    DrawFormattedText(expWin,sprintf('The correct answer is %s\n\n\nClick anywhere to review\nClick the continue button to move on',stimtargets(trial).correct),'center','center',textcol,[],[],[],[],[],grid.border); %prints instructions
    Screen('Flip',expWin);%this command presents the screen that was set up before (i.e. the instructions)
  elseif trial ~= numtrials
    Screen('DrawTexture',expWin,buttonsscreen)
    Screen('TextSize',expWin,txtsize);
    
    DrawFormattedText(expWin,sprintf('%s\n\n\n(Click anywhere to continue)',SSA.instructions),100,'center',textcol,[],[],[],[],[],grid.border); %prints instructions

    Screen('Flip',expWin);%this command presents the screen that was set up before (i.e. the instructions)
  else
    Screen('DrawTexture',expWin,buttonsscreen)
    Screen('TextSize',expWin,txtsize);
    DrawFormattedText(expWin,sprintf('Do the same task as the previous trials.\n\n\n(Click anywhere to continue)'),'center','center',textcol,[],[],[],[],[],grid.border); %prints only buttons (no instructions)
    Screen('Flip',expWin);
  end
  
  % wait for mouse click to continue
  mouse = 0;
  while mouse == 0
    [mousex,mousey,mouseb] = GetMouse(screenNumber);
    mouse = sum(mouseb);
  end
  WaitSecs(isi)
  
  screen = 1;
  mOscreentime = GetSecs;
  noclick = true;
  while screen <= size(stims,2)
    Screen('DrawTexture',testscreen,blank); %reset testscreen screen to blank
    Screen('DrawTexture',testscreen,gridscreen); %copy the texture from gridscreen (i.e. grid plus all the buttons)
    
    if replay %if a replay highlights targets
      targs = screen == stimtargets(trial).screenno; %find which targets are on this screen
      for targi = 1:length(targs) %loop through targets
        if targs(targi) %if target on this screen, highlight
          targScreen = stimtargets(trial).screenno(targi);
          targLoc = stimtargets(trial).locno(targi);
          HighlightRect = [grid.pos+grid.rectsize.*stims(trial,screen,targLoc).location grid.pos+grid.rectsize.*(stims(trial,screen,targLoc).location+[1 1])];
          Screen('FrameRect',testscreen,highlightcol,HighlightRect,grid.linewidth);
        end
      end
      Screen('DrawTexture',testscreen,repbuttonsscreen,buttons.loc(1,:),buttons.loc(1,:));
    else
      for ith = 1:length(buttons.label)
        Screen('DrawTexture',testscreen,buttonsscreen,buttons.loc(ith,:),buttons.loc(ith,:));
      end
    end
              
    
    for loc =  1:size(stims,3) %this prints all the stimuli
      Screen('TextFont',letterscreen,stimfontnum);%this font will actually is a custom font.
      %Screen('TextStyle',testscreen,stims(trial,screen,loc).orientation); %Sets orientartion
      Screen('TextSize',letterscreen,stims(trial,screen,loc).size ); %sets size
      if stims(trial,screen,loc).discard %if stim is to be blank, change it to bgcolor.
        stims(trial,screen,loc).colors = [grid.bgcol 0];
      end
      [letterx, lettery, letterrect] = DrawFormattedText(letterscreen,stims(trial,screen,loc).shape,'center','center',stims(trial,screen,loc).colors);%print the stim on lettescreen
      gridrect = CenterRect(letterrect,[grid.pos+grid.rectsize.*stims(trial,screen,loc).location grid.pos+grid.rectsize.*(stims(trial,screen,loc).location+[1 1])]); %determines the location of the gridsquare that we need to put the stim in,
      Screen('DrawTexture',testscreen,letterscreen,letterrect,gridrect,stims(trial,screen,loc).orientation);
      letterscreen = Screen('OpenOffscreenWindow',screenNumber,grid.bgcol,rect); %reset letterscreen
    end
    Screen('TextStyle',testscreen,0);%Prints the screen number nice and big in the bottom
    Screen('TextSize',testscreen,round(txtsize*1.2));
    DrawFormattedText(testscreen,sprintf('Screen %1.f',screen),'center','center',textcol,[],[],[],[],[],[0 (grid.border(4)+ grid.rectsize(2)/2) res.width (grid.border(4)+grid.rectsize(2)/2+sp.rectsize(2))]);
    
    Screen('DrawTexture',expWin,testscreen); %load texture into the online window
    
    if noclick
      Screen('TextSize',expWin,txtsize);
      DrawFormattedText(expWin,'Click on a stimulus to see the description','center',round(0.02*res.height),white); %add text
    end
    Screen('Flip',expWin);% present things
    
    %wait for mouse click, and determine what to do next
    cont = 0;
    mouseOver = 0;
    while cont == 0
      [mousex,mousey,mouseb] = GetMouse(screenNumber);
      mouse = sum(mouseb);
      if mouse ~= 0 %if click happened, find out where
        if sp.button1(1) <= mousex && mousex <= sp.button1(3) && sp.button1(2) < mousey && mousey < sp.button1(4) %if on prev button, go to previous screen
          screen = max(1,screen-1);
          cont = 1;
        elseif sp.button2(1) <= mousex && mousex <= sp.button2(3) && sp.button2(2) <= mousey && mousey <= sp.button2(4) %if on next button, go to next screen
          screen = min(size(stims,2),screen+1);
          cont = 1;
        else %if on any screen, check for response or mouseovers
          for loc =  1:size(stims,3) %check for mouseovers in each gridsquare
            checkRect = [grid.pos+grid.rectsize.*stims(trial,screen,loc).location grid.pos+grid.rectsize.*(stims(trial,screen,loc).location+[1 1])];
            mouseOver = mouseOverText*(mousex<=checkRect(3) && mousex >=checkRect(1));
            mouseOver = mouseOver*(mousey<=checkRect(4) && mousey>=checkRect(2));
           
            
            if mouseOver && ~stims(trial,screen,loc).discard %if the mouse is on a grid square, find the values for that stim
              mouseOverValues = struct(); %creates struct that saves values
              %Get all fields
              mOFields = [fieldnames(stimVar)];
              for mOFieldCount = 1:length(mOFields)
                mOField = mOFields{mOFieldCount}; %get name for all fields (sequenctially)
                mOSubfields = [fieldnames(stimVar.(mOField))];
                for mOSubfieldCount = 1:length(mOSubfields)%check all subfields
                  mOSubfield = mOSubfields{mOSubfieldCount}; %get names of subfields
                  if length(stims(trial,screen,loc).(mOField)) == length(stimVar.(mOField).(mOSubfield))
                      if stims(trial,screen,loc).(mOField) == stimVar.(mOField).(mOSubfield) %check if stim value is this subfield
                          mouseOverValues.(mOField) = mOSubfield; %if it is, store this field as being this subfield (e.g. store "colors" as "red" for this stim)
                      end
                  end
                end
              end
              
              mouseOverString = sprintf('%s, %s %s, with a',mouseOverValues.size,mouseOverValues.colors,mouseOverValues.shape); %create string
              if strcmp(mouseOverValues.orientation,'upright')
                 mouseOverString = sprintf('%sn %s orientation',mouseOverString, mouseOverValues.orientation);
              else
                mouseOverString = sprintf('%s %s',mouseOverString, mouseOverValues.orientation);
              end
              mouseOverString = strrep(mouseOverString,'_',' ');
              
              Screen('DrawTexture',mOScreen,testscreen);%copy testscreen to mO screen
              Screen('TextSize',mOScreen,txtsize);
              DrawFormattedText(mOScreen,mouseOverString,'center',round(0.02*res.height),white); %add text
              Screen('DrawTexture',expWin,mOScreen)%load texture into the online window
              mOscreentime = Screen('Flip',expWin); %flip
              Screen('DrawTexture',expWin,testscreen);%reset screen
              noclick = false;
            elseif GetSecs > mOscreentime+0.2
                Screen('DrawTexture',expWin,testscreen);
                mOscreentime = Screen('Flip',expWin); %flip
                Screen('DrawTexture',expWin,testscreen);%reset screen
            end
            
          end
          for ith = 1:numbuttons
            if buttons.loc(ith,1)<= mousex && mousex <=buttons.loc(ith,3) && buttons.loc(ith,2)<= mousey && mousey <=buttons.loc(ith,4)
              response = buttons.label(ith);
              screen = size(stims,2)+1; %this ends this loop to move to the next trial
              if ~replay
                feedback(trial) = strcmp(response{:},stimtargets(trial).correct);
              end
              cont = 1;
            end
          end
        end
        
      end
    end
    WaitSecs(isi); %this is mostly so that the participants has time to depress the mouse button
  end
  
  Screen('DrawTexture',expWin,blank); %load blank texture into the online window
  Screen('Flip',expWin);% present blank screen during iti
  WaitSecs(iti); %iti
  
  %write info in logfile
  fprintf(log,'%s\t%s\t%.f\t%s\t%s\t%.f\t%.f\t%.f\n',datestr(now,'yyyy/mm/dd'),datestr(now,'HH:MM:SS'),trial,response{:},stimtargets(trial).correct,feedback(trial),stimtargets(trial).screenno,stimtargets(trial).locno);
  
  
  if givefeedback
    replay = ~replay;
  end
  
  if ~replay
    trial = trial+1;
  end
  
end

Screen('TextSize',expWin,txtsize);
DrawFormattedText(expWin,sprintf('Ok, that''s it for this task!\n You got %.f out of %.f trials correct.\n\n\n(Click anywhere to continue to the next task)', sum(feedback),size(stims,1)),'center','center',textcol); %prints feedback
fprintf(log,'\t\t\t\tTotalAccuracy\t%.f\n',sum(feedback));
Screen('Flip',expWin);

%wait for mouse click to continue
mouse = 0;
while mouse == 0
  [mousex,mousey,mouseb] = GetMouse(screenNumber);
  mouse = sum(mouseb);
end
