%%
function SSAShowDims()
Screen('CloseALL');

stimVar = load('stimVars.mat');
stimVar = stimVar.stimVar;

screens = Screen('Screens');
screenNumber = max(screens);
% screenNumber = 0;
Screen('Preference', 'DefaultFontName', 'Calibri' );

fonts = struct2table(FontInfo('Fonts'));
stimfontnum = fonts.number(strcmp('Open Sans Condensed Bold',fonts.name));

resAdjusted = false;
scaleFactors = [1 1];

if resAdjusted
% Use native resolution
	res = Screen('Resolution',screenNumber);
	scaleFactors = [res.width/1280 res.height/800];
else
%make resolution into a standard res, or as close as we can get it (standardize across monitors)
	resVal = [1280 800]; %desired resolution
	resolutions = struct2table(Screen('Resolutions',screenNumber)); %gets possible resolutions for monitor

	if ismember(resVal(1),resolutions.width(resolutions.height == resVal(2))) %checks if desired resolution is possible on the monitor 
		Screen('Resolution', screenNumber, resVal(1), resVal(2)); %sets resolution if possible
		res = Screen('Resolution',screenNumber); %store resolution info
		
	else %if not, throw a warning and set to closest value
		resolutions.diff = [resolutions.width-resVal(1) resolutions.height-resVal(2)];%creates a variable with the difference of the resolutions to the desired resolution
		resolutions.norm = nan(height(resolutions),1); %set up another field that will contain the magnitute of the difference
		for ith = 1:height(resolutions) 
			resolutions.norm(ith) = norm(resolutions.diff(ith,:)); %populate the new field
		end
		
		resValNew = [resolutions.width(resolutions.norm == min(resolutions.norm)) resolutions.height(resolutions.norm == min(resolutions.norm))]; %set new res value to the resolutions with the least difference
		resValNew = resValNew(1,:); %if multiple resolutions have the min difference, choose the top one

		warning('Desired resolution not supported!! Resolution changed to %.f by %.f instead',resValNew(1), resValNew(2));
		
		Screen('Resolution', screenNumber, resValNew(1), resValNew(2)); %sets resolution to new value
		res = Screen('Resolution',screenNumber); %store resolution info
	end
end

%pick default colors and other settings
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
bgcol = white/2;
% bgcol = white;
grid.col = black;
grid.bgcol = white/5;
% grid.bgcol = white;
highlightcol = [255 100 100];
textcol = black;
txtsize = round(res.height/28);
isi = 0.500;
iti = 1;

grid.rectsize = [res.width*1/5 res.height*1/5]; %size of one grid rectangle
grid.pos = [res.width*1/12 res.height*1/8]; %starting position of the grid (defined at top left)
grid.border = [grid.pos grid.pos+3*grid.rectsize]; %square making outer grid border
grid.lines = [grid.pos(1) (grid.pos(1)+3*grid.rectsize(1)) grid.pos(1) (grid.pos(1)+3*grid.rectsize(1)) (grid.pos(1)+1*grid.rectsize(1)) (grid.pos(1)+1*grid.rectsize(1)) (grid.pos(1)+2*grid.rectsize(1)) (grid.pos(1)+2*grid.rectsize(1)); ... %x coordinates (pairs of cooedinates denote the start and end of a line)
  (grid.pos(2)+1*grid.rectsize(2)) (grid.pos(2)+1*grid.rectsize(2)) (grid.pos(2)+2*grid.rectsize(2)) (grid.pos(2)+2*grid.rectsize(2)) grid.pos(2) (grid.pos(2)+3*grid.rectsize(2)) grid.pos(2) (grid.pos(2)+3*grid.rectsize(2))]; %y coordinates
grid.linewidth = 5;

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

PsychImaging('PrepareConfiguration');
[expWin,rect]=PsychImaging('OpenWindow',screenNumber, grid.bgcol);

gridscreen = Screen('OpenOffscreenWindow',screenNumber,bgcol,rect);
Screen('FillRect',gridscreen,grid.bgcol,grid.border);
Screen('FrameRect',gridscreen,grid.col,grid.border,grid.linewidth);
Screen('DrawLines',gridscreen,grid.lines,grid.linewidth,grid.col);

function drawPrev(destscreen, btform)
	Screen('FillRect',destscreen,btform.col,btform.button1);
	Screen('FrameRect',destscreen,btform.framecol,btform.button1,btform.linewidth);
	Screen('TextSize',destscreen,btform.textsize);
	DrawFormattedText(destscreen,'Prev','center','center',btform.textcol,[],[],[],[],[],btform.button1);
end

function drawNext(destscreen, btform)
	Screen('FillRect',destscreen,btform.col,btform.button2);
	Screen('FrameRect',destscreen,btform.framecol,btform.button2,btform.linewidth);
	Screen('TextSize',destscreen,btform.textsize);
	DrawFormattedText(destscreen, 'Next ' ,'center','center',btform.textcol,[],[],[],[],[],btform.button2);
end

%% Show instructions
emptyscreen = Screen('OpenOffscreenWindow',screenNumber,bgcol,rect);
Screen('TextSize', expWin, 30);
DrawFormattedText(expWin,'Welcome!\n\nYou''re going to be asked to do a series of tasks involving visual stimuli.\n\n\nClick anywhere to continue','center','center',white);
Screen('Flip',expWin);

clicked = 0;
while ~clicked
  [x,y,clicked] = GetMouse(screenNumber);
  clicked = sum(clicked);
end
WaitSecs(isi);

DrawFormattedText(expWin,'These stimuli are defined by six variables:\n Color, Size, Orientation, Shape, Location, and Screen Position.\n\n\nClick anywhere to continue','center','center',white);
Screen('Flip',expWin);

clicked = 0;
while ~clicked
  [x,y,clicked] = GetMouse(screenNumber);
  clicked = sum(clicked);
end
WaitSecs(isi);


%% show all the dimensions
dimnames = fieldnames(stimVar);
defsymbol.colors = stimVar.colors.red;
defsymbol.shape = stimVar.shape.X;
defsymbol.size = stimVar.size.medium;
defsymbol.orientation = stimVar.orientation.upright;
sym_per_row = 6;

for idx = 1:4
	Screen('TextSize', expWin, 20);
	message = strcat({'Showing all possible '},dimnames(idx));
	if message{1}(end)~='s'
		message = strcat(message,'s');
	end
	message = message{1};
	DrawFormattedText(expWin, message, 'center', 35, white);
	DrawFormattedText(expWin, 'Click anywhere to continue.', 'center', 'center', white,[],[],[],[],[],[0,res.height-50,res.width,res.height]);
	letterscreen = Screen('OpenOffscreenWindow', screenNumber, grid.bgcol, rect);
    Screen('TextFont',letterscreen,stimfontnum);

	symbols = fieldnames(stimVar.(dimnames{idx}));
	numsymbols = numel(symbols);
	numrows = floor(numsymbols/sym_per_row)+ (mod(numsymbols,sym_per_row)>0);
	heightS = round((res.height-100)/numrows);
	widthS = (res.width - 150)/sym_per_row;
	ystart = 50;

	for hd = 1:numrows
		if hd == numrows
			symthisrow = mod(numsymbols,sym_per_row);
			if symthisrow == 0
				symthisrow = sym_per_row;
			end
		else
			symthisrow = sym_per_row;
		end
		xoffset = 75 + floor((sym_per_row-symthisrow)*widthS/2);
		for wd = 1:symthisrow
			currsym = defsymbol;
			currsym.(dimnames{idx}) = stimVar.(dimnames{idx}).(symbols{(hd-1)*sym_per_row+wd});
			% Screen('FramePoly', expWin, black, [xoffset,ystart;xoffset,ystart+heightS;xoffset+widthS,ystart+heightS;xoffset+widthS,ystart]);
			letterrect = [xoffset,ystart,xoffset+widthS,ystart+heightS];
			Screen('TextSize',letterscreen,currsym.size);
			[x,y,letterrect] = DrawFormattedText(letterscreen,currsym.shape,'center','center',currsym.colors,[],[],[],[],[],letterrect);
			Screen('DrawTexture', expWin, letterscreen, letterrect, letterrect, currsym.orientation);
% 			if ~ strcmp(dimnames{idx},'shape')
				DrawFormattedText(expWin,strrep(symbols{(hd-1)*sym_per_row+wd}, '_', ' '),'center','center',white,[],[],[],[],[],[letterrect(1), letterrect(4),letterrect(3),letterrect(4)+50]);
% 			end
			xoffset = xoffset+widthS;
		end
		ystart = ystart + heightS;
	end
	Screen('Flip', expWin);
	clicked = 0;
	while ~clicked
		[x,y,clicked] = GetMouse(screenNumber);
		clicked = sum(clicked);
	end
	WaitSecs(isi);
end

buttons.col = white/1.8*[1 1 1.7];
buttons.framecol = white/1.5;
buttons.textcol = black;
buttons.textsize = round(res.height/40);
buttons.linewidth = 2;
rb.area = [grid.border(3)+(res.width-grid.border(3))/10 grid.border(2) res.width-(res.width-grid.border(3))/10 grid.border(4)]; %defines area where buttons can be placed. It corresponds to the area directly to the left of the grid, with a 10% margin at left and right
rb.width = rb.area(3)-rb.area(1); %the width of rb.area
rb.height = rb.area(4)-rb.area(2); %the height
buttons.loc(1,:) = [(rb.area(1)+rb.width*1/3) (rb.area(2)+rb.height*1/5) (rb.area(1)+rb.width*2/3)  (rb.area(2)+rb.height*2/5)];
buttons.label(1) = {'Finish'};

for idx = 5:6
  if idx == 5
		Screen('TextSize', expWin, 20);
		Screen('DrawTexture', expWin, gridscreen);
		message = 'This is is an experiment window, please review all possible locations:';
		DrawFormattedText(expWin, message, 'center', 35, white);
		DrawFormattedText(expWin, 'Click anywhere to continue.', 'center', 'center', white,[],[],[],[],[],[0,res.height-50,res.width,res.height]);
		letterscreen = Screen('OpenOffscreenWindow', screenNumber, grid.bgcol, rect);
	  Screen('TextFont',letterscreen,stimfontnum);
		symbols = fieldnames(stimVar.location);
		
		for loc = 1:numel(symbols)
			gridrect = [grid.pos+grid.rectsize.*stimVar.location.(symbols{loc}) grid.pos+grid.rectsize.*(stimVar.location.(symbols{loc})+[1 1])]; %determines the location of the gridsquare that we need to put the stim in,
			Screen('TextSize',letterscreen,defsymbol.size);
			[letterx, lettery, letterrect] = DrawFormattedText(letterscreen, defsymbol.shape,'center','center',defsymbol.colors,[],[],[],[],[],gridrect);
			Screen('DrawTexture', expWin, letterscreen, letterrect, letterrect, defsymbol.orientation);
			DrawFormattedText(expWin,strrep(symbols{loc}, '_', ' '),'center','center',white,[],[],[],[],[],[letterrect(1), letterrect(4),letterrect(3),letterrect(4)+50]);
			% Screen('DrawTexture',expWin,letterscreen,letterrect,gridrect,defsymbol.orientation);
			% rscreen = Screen('OpenOffscreenWindow',screenNumber,grid.bgcol,rect); %reset letterscreen
		end
		Screen('Flip', expWin);
		clicked = 0;
		while ~clicked
			[x,y,clicked] = GetMouse(screenNumber);
			clicked = sum(clicked);
		end
		WaitSecs(isi);
	else
		screen = 1;
		while screen <= 9
			Screen('TextSize', expWin, 20);
			Screen('DrawTexture', expWin, gridscreen);
			message = 'You can see the current screen number below in the experiment.\nYou can also cycle through the screens by clicking the Prev and Next buttons.';
			DrawFormattedText(expWin, message, 'center', 35, white);
			DrawFormattedText(expWin, 'Click finish to continue.', 'center', 'center', white,[],[],[],[],[],[0,res.height-50,res.width,res.height]);
			letterscreen = Screen('OpenOffscreenWindow', screenNumber, grid.bgcol, rect);
		  Screen('TextFont',letterscreen,stimfontnum);

			for loc = 1:numel(symbols)
				gridrect = [grid.pos+grid.rectsize.*stimVar.location.(symbols{loc}) grid.pos+grid.rectsize.*(stimVar.location.(symbols{loc})+[1 1])]; %determines the location of the gridsquare that we need to put the stim in,
				sym2show = defsymbol;
				dimnames = fieldnames(stimVar);
				for dims = 1:4
					subdimnames = fieldnames(stimVar.(dimnames{dims}));
					sym2show.(dimnames{dims}) = randsample(subdimnames, 1);
					sym2show.(dimnames{dims}) = stimVar.(dimnames{dims}).(sym2show.(dimnames{dims}){1});
				end
				Screen('TextSize',letterscreen,sym2show.size);
				[letterx, lettery, letterrect] = DrawFormattedText(letterscreen, sym2show.shape,'center','center',sym2show.colors,[],[],[],[],[],gridrect);
				Screen('DrawTexture', expWin, letterscreen, letterrect, letterrect, sym2show.orientation);
			end
			if screen ~= 1
				drawPrev(expWin, sp);
			end
			if screen ~= 9
				drawNext(expWin, sp);
			end
			Screen('TextStyle',expWin,0);
			Screen('TextSize',expWin,round(txtsize*1.2));
			[tx, ty, bounds] = DrawFormattedText(expWin,sprintf('Screen %d',screen),'center','center',textcol,[],[],[],[],[],[0 (grid.border(4)+ grid.rectsize(2)/2) res.width (grid.border(4)+grid.rectsize(2)/2+sp.rectsize(2))]);
			Screen('FrameRect', expWin, highlightcol, bounds + [-20 -15 20 15], 7);
			for ith = 1:length(buttons.label)
				Screen('FillRect',expWin,buttons.col,buttons.loc(ith,:));% Same process as above, done for every button
				Screen('FrameRect',expWin,buttons.framecol,buttons.loc(ith,:),buttons.linewidth);
				Screen('TextSize',expWin,buttons.textsize);
				DrawFormattedText(expWin, buttons.label{ith} ,'center','center',sp.textcol,[],[],[],[],[],buttons.loc(ith,:  ));
			end
			Screen('Flip', expWin);
			WaitSecs(isi);
			cont = 0;
			while cont == 0
			  [mousex,mousey,mouseb] = GetMouse(screenNumber);
			  mouse = sum(mouseb);
			  if mouse ~= 0 %if click happened, find out where
			    if sp.button1(1) <= mousex && mousex <= sp.button1(3) && sp.button1(2) < mousey && mousey < sp.button1(4) %if on prev button, go to previous screen
			      screen = max(1,screen-1);
			      cont = 1;
			    elseif sp.button2(1) <= mousex && mousex <= sp.button2(3) && sp.button2(2) <= mousey && mousey <= sp.button2(4) %if on next button, go to next screen
			      screen = min(9,screen+1);
			      cont = 1;
			    end
			    for ith = 1
			      if buttons.loc(ith,1)<= mousex && mousex <=buttons.loc(ith,3) && buttons.loc(ith,2)<= mousey && mousey <=buttons.loc(ith,4)
			        response = buttons.label(ith);
			        screen = 10; %this ends this loop to move to the next trial
			        cont = 1;
			      end
			    end
			  end
			end
		end
	end
end

Screen('CloseALL');
end
