clear all

%% Collect subjectg info and initialize logfile
ListenChar;
prompt = {'Enter subject number','Enter subject age','Enter subject gender'};
def={'99', '0', 'O'};
answer = inputdlg(prompt, 'Experimental setup information',1,def);
[subjNumber, subjAge, subjGender]  = deal(answer{:});

logfile = [subjNumber '_logfile'];
save('log','logfile')

numTasks = 30;
numBlock = 10;
numPractice = 1;
instructions = true;

screens = Screen('Screens');
screenNumber = max(screens);
Screen('Preference', 'DefaultFontName', 'Helvetica')

fonts = struct2table(FontInfo('Fonts'));
stimfontnum = fonts.number(strcmp('Open Sans Condensed Bold',fonts.name));



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

%pick default colors and other settings
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
bgcol = [1 1 1]*white/2;
grid.col = black;
grid.bgcol = [1 1 1]*white/5;
highlightcol = [255 100 100];
textcol = [1 1 1]*black;
txtsize = round(res.height/28);
isi = 0.500;
iti = 1;
filename = logfile;

mouseOverText = true;

[expWin,rect]=PsychImaging('OpenWindow',screenNumber, bgcol);%opens onscreen window


tasks = {'SingleTargetSearch_task.m','MultipleTargetSearch_task.m','BinaryTargetSearch_task.m'};
trials = {'SingleTargetSearch_trials.m','MultipleTargetSearch_trials.m','BinaryTargetSearch_trials.m'};

taskSeq = zeros(1,numTasks);
taskSeqp = 1;
for idx = 1:numel(tasks)
	ntask = floor(numTasks/numel(tasks));
	if idx < mod(numTasks, numel(tasks))
		ntask = ntask +1;
	end
	taskSeq(taskSeqp:taskSeqp+ntask-1) = idx;
	taskSeqp = taskSeqp + ntask;
end
taskSeq = taskSeq(randperm(numTasks));
taskSeq = taskSeq(randperm(numTasks));
taskSeq = taskSeq(randperm(numTasks)); % for better randomness

for itask = 1:numTasks
  if itask <= numPractice
    givefeedback = true;
  else
    givefeedback = false;
	end
	if mod(itask, numBlock) == 0 && itask~=numTasks
		Screen('TextSize',expWin,txtsize);
		DrawFormattedText(expWin, 'You can take a break now.\nClick anywhere to continue the experiment.', 'center', 'center');
		Screen('Flip', expWin);
		
		mouse = 0;
		while mouse == 0
			[mousex,mousey,mouseb] = GetMouse(screenNumber);
			mouse = sum(mouseb);
		end
	end
%   taskid = randi(length(tasks));
	taskid = taskSeq(itask);
  clear stims stimtargets stimfoils SSA stimVar
  SSAstimVar
  run(tasks{taskid});
  run(trials{taskid});
  WaitSecs(1);

  
  save([subjNumber '_task' num2str(itask)])
  SSAtrialrun
  
end
sca