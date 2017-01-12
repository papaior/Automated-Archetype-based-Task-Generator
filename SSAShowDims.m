sca
%%
clear;
Screen('CloseALL');
%Screen('Preference', 'SkipSyncTests', 1);

load('stimVars.mat');

screens = Screen('Screens');
screenNumber = max(screens);
% screenNumber = 0;
Screen('Preference', 'DefaultFontName', 'Subfont' )

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
bgcol = white/5;
% bgcol = white;
grid.col = black;
grid.bgcol = white/5;
% grid.bgcol = white;
textcol = black;
txtsize = round(res.height/28);
isi = 0.500;
iti = 1;

PsychImaging('PrepareConfiguration');
[expWin,rect]=PsychImaging('OpenWindow',screenNumber, bgcol);

%% show all the dimensions
dimnames = fieldnames(stimVar);
defsymbol.colors = stimVar.colors.red;
defsymbol.shape = stimVar.shape.A;
defsymbol.size = stimVar.size.medium;
defsymbol.orientation = stimVar.orientation.notilt;
sym_per_row = 6;

for idx = 1:4
	Screen('TextSize', expWin, 20*scaleFactors(2));
	message = strcat({'Showing all possible '},dimnames(idx));
	if message{1}(end)~='s'
		message = strcat(message,'s');
	end
	message = message{1};
	DrawFormattedText(expWin, message, 'center', 35*scaleFactors(2), black);
	DrawFormattedText(expWin, 'Click anywhere to continue.', 'center', 'center', black,[],[],[],[],[],[0,res.height-50*scaleFactors(2),res.width,res.height]);
	letterscreen = Screen('OpenOffscreenWindow', screenNumber, bgcol, rect);

	symbols = fieldnames(stimVar.(dimnames{idx}));
	numsymbols = numel(symbols);
	numrows = floor(numsymbols/sym_per_row)+ (mod(numsymbols,sym_per_row)>0);
	heightS = round((res.height-100*scaleFactors(2))/numrows);
	widthS = (res.width - 150*scaleFactors(1))/sym_per_row;
	ystart = 50*scaleFactors(2);

	for hd = 1:numrows
		if hd == numrows
			symthisrow = mod(numsymbols,sym_per_row);
			if symthisrow == 0
				symthisrow = sym_per_row;
			end
		else
			symthisrow = sym_per_row;
		end
		xoffset = 75*scaleFactors(1) + floor((sym_per_row-symthisrow)*widthS/2);
		for wd = 1:symthisrow
			currsym = defsymbol;
			currsym.(dimnames{idx}) = stimVar.(dimnames{idx}).(symbols{(hd-1)*sym_per_row+wd});
			% Screen('FramePoly', expWin, black, [xoffset,ystart;xoffset,ystart+heightS;xoffset+widthS,ystart+heightS;xoffset+widthS,ystart]);
			letterrect = [xoffset,ystart,xoffset+widthS,ystart+heightS];
			Screen('TextSize',letterscreen,floor(currsym.size*scaleFactors(2)));
			[x,y,letterrect] = DrawFormattedText(letterscreen,currsym.shape,'center','center',currsym.colors,[],[],[],[],[],letterrect);
			Screen('DrawTexture', expWin, letterscreen, letterrect, letterrect, currsym.orientation);
			if ~ strcmp(dimnames{idx},'shape')
				DrawFormattedText(expWin,symbols{(hd-1)*sym_per_row+wd},'center','center',black,[],[],[],[],[],[letterrect(1), letterrect(4),letterrect(3),letterrect(4)+floor(50*scaleFactors(2))]);
			end
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

Screen('CloseALL');