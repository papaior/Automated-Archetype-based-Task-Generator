%% Add PTB
addpath('/Users/Shared/toolboxes/ptb_3012/Psychtoolbox');
%% Get words
path = '/Users/orestispapaioannou/Box Sync/MATLAB/PWM Pilot/PWM_fntpilot/Version2/';
%path = '/Users/papaior/Desktop/PWM Pilot/Version2/';
[wlength, wlist, wraw] = xlsread([path 'wordlist50w.xlsx']);
[clength, clist, craw] = xlsread([path 'wordlist50c.xlsx']);
numw = length(wlist);
numc = length(clist);

wordlength = cat(1,wlength,clength);
wordlist = cat(1,wlist,clist);
wordraw = cat(1,wraw,craw);
numwords = length(wordlist);

numblanks = numwords/2;

wordcats = {'W','C'};
fonts = {'Calibri'};
numfonts = length(fonts);
%% colors
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];
yellow = [255 255 0];
purple = [102 0 255];
cyan = [0 255 255];
pink = [204 0 102];
gray = [100 100 100];
black = [0 0 0];
white = [255 255 255];
orange = [255 100 0];
magenta = [255 0 255];
rgbcolors = [red;green;blue;yellow; purple;cyan;pink;gray;black;white;orange;magenta]';
rgbnames = table(rgbcolors', 'VariableNames',{'value'});
names = {'red';'green';'blue';'yellow';'purple';'cyan';'pink';'gray';'black';'white';'orange';'magenta'};
rgbnames.name = names;
 
backgroundColor = [50 50 50];

%% stimulus info
resVal = [1280 800];
mon_width   = 43.5;   % horizontal dimension of viewable screen (cm)
v_dist      = 100;   % viewing distance (cm)
ppd = round(pi * resVal(1) / atan(mon_width/v_dist/2) / 360);    % pixels per degree

lineWidth = 2;
chipOffset = 0.15*ppd;

[centerX, centerY] = RectCenter([0 0 resVal]);
margindeg = 80/25;
eccentdeg = 30/25;
leftsideX = [round(centerX-margindeg*ppd), round(centerX-eccentdeg*ppd)];
rightsideX = [round(centerX+eccentdeg*ppd),round(centerX+margindeg*ppd)];
leftsideY = [round(centerY-margindeg*ppd), round(centerY+margindeg*ppd)];
rightsideY = [round(centerY-margindeg*ppd), round(centerY+margindeg*ppd)];
positions = [leftsideX leftsideY; rightsideX rightsideY];

baserect = [0 0 (8/25*ppd) (23/25*ppd)];
basecrcl = [0 0 (18/25*ppd) (18/25*ppd)];

baseimgrect = [0 0 8*ppd 8*ppd];
photocellrect = [0 0 1/2*ppd 1/2*ppd];

%% Default screen info
fixcolor = [180 30 30];
fixfont = 'Arial';
fixstyle = 1;
fixsize = round(0.4*ppd);
txtcolor = white;
txtsize = round(0.5*ppd);
stimfontsize = round(0.8*ppd);


%% Trial Properties
fudgefactor = 4;
fix1minisi= 1100-fudgefactor; %in ms
fix1maxisi = 1200-fudgefactor;
screen1dur = 200-fudgefactor;
fix2minisi= 350-fudgefactor;
fix2maxisi = 350-fudgefactor;
screen2dur = 200-fudgefactor;
fix3minisi= 700-fudgefactor;
fix3maxisi = 700-fudgefactor;
screen3dur = 2000-fudgefactor;
iti = 0;
countdowndelay = 800; %determines how fast the countdown moves (in ms)


%% Save setup
save('PWM_fntpilot2_Setup');