%% Collect subjectg info and initialize logfile
ListenChar;
prompt = {'Enter subject number','Enter subject age','Enter subject gender','Manual Run'};
def={'99', '0', 'O','0'};
answer = inputdlg(prompt, 'Experimental setup information',1,def);
[subjNumber, subjAge, subjGender, manualRun]  = deal(answer{:});

filename = [subjNumber '_logfile'];
save('log','filename')

clicklog = fopen(strcat(subjNumber, '_click_logfile'), 'a+');
trial_start = now;
fprintf(clicklog, 'Date: %s, Time: %s\n', datestr(trial_start,'yyyy/mm/dd'),datestr(trial_start,'HH:MM:SS'));
fprintf(clicklog, 'Time\tTrial\tEvent\tScreen\tLocation\n');

numTasks = 30;
numBlock = 10;
numPractice = 2;
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
highlightcol = [255 255 255];
replaycol = [255 100 100];
textcol = [1 1 1]*black;
txtsize = round(res.height/28);
isi = 0.300;
iti = 1;

mouseOverText = true;

[expWin,rect]=PsychImaging('OpenWindow',screenNumber, bgcol);%opens onscreen window


tasks = {'SingleTargetSearch_task','MultipleTargetSearch_task.m','BinaryTargetSearch_task.m'};
trials = {'SingleTargetSearch_trials','MultipleTargetSearch_trials.m','BinaryTargetSearch_trials.m'};

accuracy = 0;
perfectTask = 0;
badTask = 0;

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

if ~str2double(manualRun)
  for itask = 1:numTasks
    if itask <= numPractice
      givefeedback = true;
    else
      givefeedback = false;
    end
    
    %   taskid = randi(length(tasks));
    taskid = taskSeq(itask);
    clear stims stimtargets stimfoils SSA stimVar
    SSAstimVar
    run(tasks{taskid});
    run(trials{taskid});
    WaitSecs(1);
    if mod(itask, numBlock) == 0 && itask~=numTasks
      Screen('TextSize',expWin,txtsize);
      DrawFormattedText(expWin, 'You can take a break now.\nClick anywhere to continue the experiment.', 'center', 'center');
      Screen('Flip', expWin);
      
      mouse = 0;
      while mouse == 0

        [mousex,mousey,mouseb] = GetMouse(screenNumber);
        mouse = sum(mouseb);
      end
      WaitSecs(isi);
    end
    
    load('SSASpecs.mat');
    save([subjNumber '_task' num2str(itask)]);
    logfile = fopen(filename,'a+');
    fprintf(logfile,'Task %.f\n',itask);

    SSAtrialrun
    save([subjNumber '_task' num2str(itask) '_response'], 'stimtargets', 'recordedResponses');
    fclose(logfile);
    taskcorrect = sum([recordedResponses(:).correct]);
    accuracy = accuracy + taskcorrect;
    
    if taskcorrect == 5
      perfectTask = perfectTask+1;
    elseif taskcorrect < 3
      badTask = badTask+1;
    end
  end
else
  logfile = fopen(filename,'a+');
  fprintf(logfile,'Task %.f\n',itask);
  SSAtrialrun
  fclose(logfile);
end
accuracy = (accuracy/numTasks)/5;
logfile = fopen(filename,'a+');
fprintf(logfile, 'Total accuracy: %f, perfect tasks: %.f, tasks with less than half accuracy: %.f\n', accuracy, perfectTask, badTask);
fclose(logfile);

sca
fclose(clicklog);
