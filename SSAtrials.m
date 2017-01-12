%% load task and stim vars
%clear stims stimtargets SSA stimVar;

load('stimVars');
load('task.mat');

%% create stim for trials
numtrials = 5;
parameters = fieldnames(stimVar);
screens = fieldnames(stimVar.screen);
locations = fieldnames(stimVar.location);
yessFields = fieldnames(SSA.yess);
nosFields = fieldnames(SSA.nos);
stimtargets = struct('screenno',cell(1,numtrials),'locno',cell(1,numtrials),'correct',cell(1,numtrials));
stimfoils = struct('screenno',cell(1,numtrials),'locno',cell(1,numtrials),'foilfield',cell(1,numtrials));
stims = struct;


for trial = 1:numtrials
  
  %determine if targ would be present
  if SSA.presence
    SSA.present = Sample([true false]);
    if SSA.present %specifies what the correct response would be
      stimtargets(trial).correct = 'Present';
    else
      stimtargets(trial).correct = 'Absent';
    end
  else
    SSA.present = true;
  end
  
  stimcmp = true; %compare stims to target. Default is yes.
  
  for sn = 1:length(fieldnames(stimVar.screen))
    
    %check if targ could be here, and thus we should compare stims to targ
    %     if isfield(SSA.yess,'screen')
    %       if strcmp(SSA.yess.screen,sprintf('screen%d',sn))
    %         stimcmp = true;
    %       else
    %         stimcmp = false;
    %       end
    %     elseif isfield(SSA.nos,'screen')
    %       if strcmp(SSA.nos.screen,sprintf('screen%d',sn))
    %         stimcmp = false;
    %       else
    %         stimcmp = true;
    %       end
    %     end
    
    for loc = 1:length(fieldnames(stimVar.location))
      %determine if stim will be present
      if Sample(false)%set so all locs have stim. Could add TRUEs to adjust probability of getting a stim
        continue %skips this cycle if true, so that no stim is defined
      end
      
      %cycle through parameters
      for par = 1:length(parameters)
        field = parameters{par};
        %set parameter to random value
        stims(trial,sn,loc).(field) = stimVar.(field).(strjoin(Sample(fieldnames(stimVar.(field)))));
      end
      
      %redefine location and screen as the current values
      stims(trial,sn,loc).screen = stimVar.screen.(screens{sn});
      stims(trial,sn,loc).location = stimVar.location.(locations{loc});
      
      %check if we need to compare to target
      if stimcmp
        same = true; %marks if stim is same as a target. starts as true, but the loop then checks it.
        it_num = 1; %starts iteration counter.
        while same
          %check if stim fulfils yess.
          for ith = 1:length(yessFields)
            if ischar(stims(trial,sn,loc).(yessFields{ith}))
              if ~strcmp(stims(trial,sn,loc).(yessFields{ith}),stimVar.(yessFields{ith}).(SSA.yess.(yessFields{ith})))
                same = false;
              end
            elseif any(stims(trial,sn,loc).(yessFields{ith})~=stimVar.(yessFields{ith}).(SSA.yess.(yessFields{ith})))
              same = false;
            end
          end
          %check if stim has ANY nos
          hasnos = zeros(1,length(nosFields));
          for ith = 1:length(nosFields)
            hasnos(ith) = isequal(stims(trial,sn,loc).(nosFields{ith}),stimVar.(nosFields{ith}).(SSA.nos.(nosFields{ith})));
          end
          same = same && ~any(hasnos);
          
          if it_num >500
            stims(trial,sn,loc).discard = true;
            same = false;
          else
            stims(trial,sn,loc).discard = false;
          end
          
          if same %reset stim if same as targ
            for par = 1:length(parameters)
              field = parameters{par};
              %set parameter to random value
              stims(trial,sn,loc).(field) = stimVar.(field).(strjoin(Sample(fieldnames(stimVar.(field)))));
            end
            %restore location and screen as the current values
            stims(trial,sn,loc).screen = stimVar.screen.(screens{sn});
            stims(trial,sn,loc).location = stimVar.location.(locations{loc});
            it_num = it_num+1; %increases the iteration counter
          end
          
        end
      end
    end
  end
  
  %set a stim as target if needed
  if SSA.present
    %determine which screen it will be on
    %if screen is a target property, set to that
    if isfield(SSA.yess,'screen')
      stimtargets(trial).screenno= find(strcmp(screens,SSA.yess.screen));
      %if screen a negative target property, set it as something other than SSA.nos.screen
    elseif isfield(SSA.nos,'screen')
      stimtargets(trial).screenno= randi([1 length(screens)]);
      while stimtargets(trial).screenno == find(strcmp(screens,SSA.nos.screen))
        stimtargets(trial).screenno= randi([1 length(screens)]);
      end
      %else if it doesn't matter, pick at random
    else
      stimtargets(trial).screenno= randi([1 length(screens)]);
    end
    
    %Determine the location too (same idea as screen)
    %if location is in SSA.yess, set to that
    if isfield(SSA.yess,'location')
      stimtargets(trial).locno = find(strcmp(locations,SSA.yess.location));
    else
      %if not, pick at random
      stimtargets(trial).locno = randi([1 length(locations)]);
      %if location is in SSA.nos, make sure loc is not that
      if isfield(SSA.nos,'location')
        while stimtargets(trial).locno == find(strcmp(locations,SSA.nos.location))
          stimtargets(trial).locno = randi([1 length(locations)]);
        end
      end
    end
    
    %Set stim parameters at random
    
    for par = 1:length(parameters)
      field = parameters{par};
      %set parameter to random value
      value = strjoin(Sample(fieldnames(stimVar.(field)))); %this picks a random label from within the field values. e.g, if field is 'colors', this might choose 'red'
      if ~isempty(SSA.report)&&strcmp(field,fieldnames(SSA.report)) %if this field is the one that needs to br reported, save value
        if strcmp(value,SSA.report.(field)) %if it's the same as the value to be reported, save as that
          stimtargets(trial).correct = value;
        else
          stimtargets(trial).correct = ['not ' SSA.report.(field)]; %else, change to "not %valuetobereported"
        end
      end
      stims(trial,stimtargets(trial).screenno,stimtargets(trial).locno).(field) = stimVar.(field).(value);
    end
    %Set screen and location, and set discard to false
    stims(trial,stimtargets(trial).screenno,stimtargets(trial).locno).screen = stimVar.screen.(screens{stimtargets(trial).screenno});
    stims(trial,stimtargets(trial).screenno,stimtargets(trial).locno).location = stimVar.location.(locations{stimtargets(trial).locno});
    stims(trial,stimtargets(trial).screenno,stimtargets(trial).locno).discard = false;
    
    %Go to that stim and set parameters according to SSA.yess
    for ith=1:length(yessFields)
      stims(trial,stimtargets(trial).screenno,stimtargets(trial).locno).(yessFields{ith})= stimVar.(yessFields{ith}).(SSA.yess.(yessFields{ith}));
    end
    %Make sure that no parameters are set to the SSA.nos
    samenos = true; %assume stim is same as the nos stim
    while samenos %check if it's the same, and if so, randomize features
      for ith=1:length(nosFields) %check if ALL fields are the same
        if ischar(stims(trial,stimtargets(trial).screenno,stimtargets(trial).locno).(nosFields{ith}))
          if ~strcmp(stims(trial,stimtargets(trial).screenno,stimtargets(trial).locno).(nosFields{ith}),stimVar.(nosFields{ith}).(SSA.nos.(nosFields{ith})))
            samenos = false;
          end
        else
          if ~all(stims(trial,stimtargets(trial).screenno,stimtargets(trial).locno).(nosFields{ith}) == stimVar.(nosFields{ith}).(SSA.nos.(nosFields{ith})))
            samenos = false;
          end
        end
      end
      
      if isempty(fieldnames(SSA.nos)) %if no nos, set as not the same
        samenos = false;
      end
      
      if samenos %if they where the same, randomize
        for ith = 1:length(nosFields)
          stims(trial,stimtargets(trial).screenno,stimtargets(trial).locno).(nosFields{ith}) = stimVar.(nosFields{ith}).(strjoin(Sample(fieldnames(stimVar.(nosFields{ith})))));
        end
      end
    end
  end
  
  %Add foils
  
  %choose the foil field
  stimfoils(trial).foilfield = Sample(SSA.targs(:,1));
  foilfield = stimfoils(trial).foilfield;
  
  %Pick random screen and loc
  stimfoils(trial).screenno= randi([1 length(screens)]);
  stimfoils(trial).locno= randi([1 length(locations)]);
  %check that it's not in the same loc as target (if target exists
  while stimfoils(trial).screenno == sum(stimtargets(trial).screenno) && stimfoils(trial).locno == sum(stimtargets(trial).locno)
    stimfoils(trial).screenno= randi([1 length(screens)]);
    stimfoils(trial).locno= randi([1 length(locations)]);
  end
  %if screen or loc need to be a particular value, do that
    %if foilfield = screen, and screen is in nosFields, set screen to SSA.nos.screen
  if strcmp(foilfield,'screen') && ismember('screen',fieldnames(SSA.nos))
    stimfoils(trial).screenno = find(strcmp(screens,SSA.nos.screen));
    %if it's not foilfield, and is in yess, set to SSA.yess.screen
  elseif ~strcmp(foilfield,'screen') && ismember('screen',fieldnames(SSA.yess))
    stimfoils(trial).screenno = find(strcmp(screens,SSA.yess.screen));
    %Same two conditions for loc
  end
  if strcmp(foilfield,'location') && ismember('location',fieldnames(SSA.nos))
    stimfoils(trial).locno = find(strcmp(locations,SSA.nos.location));
  elseif ~strcmp(foilfield,'location') && ismember('location',fieldnames(SSA.yess))
    stimfoils(trial).locno = find(strcmp(locations,SSA.yess.location));
  end
  
  %Set foil stim parameters at random
  for par = 1:length(parameters)
    field = parameters{par};
    %set parameter to random value
    value = strjoin(Sample(fieldnames(stimVar.(field)))); %this picks a random label from within the field values. e.g, if field is 'colors', this might choose 'red'
    stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(field) = stimVar.(field).(value);
  end
  %Set screen and location and set discard to false
  stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).screen = stimVar.screen.(screens{stimfoils(trial).screenno});
  stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).location = stimVar.location.(locations{stimfoils(trial).locno});
  stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).discard = false;
  
  %Go to that stim and set parameters according to SSA.yess
  for ith=1:length(yessFields)
    stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(yessFields{ith})= stimVar.(yessFields{ith}).(SSA.yess.(yessFields{ith}));
  end
  %Reset screen and location
  stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).screen = stimVar.screen.(screens{stimfoils(trial).screenno});
  stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).location = stimVar.location.(locations{stimfoils(trial).locno});
  
  %Make sure that no values are set to nos
  samenos = true; %assume stim is same as the nos stim
  while samenos %check if it's the same, and if so, randomize features
    for ith=1:length(nosFields) %check if ALL fields are the same
      if ischar(stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(nosFields{ith}))
        if ~strcmp(stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(nosFields{ith}),stimVar.(nosFields{ith}).(SSA.nos.(nosFields{ith})))
          samenos = false;
        end
      else
        if ~all(stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(nosFields{ith}) == stimVar.(nosFields{ith}).(SSA.nos.(nosFields{ith})))
          samenos = false;
        end
      end
    end
    
    if isempty(fieldnames(SSA.nos)) %if no nos, set as not the same
      samenos = false;
    end
    
    if samenos %if they where the same, randomize
      for ith = 1:length(nosFields)
        stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(nosFields{ith}) = stimVar.(nosFields{ith}).(strjoin(Sample(fieldnames(stimVar.(nosFields{ith})))));
      end
    end
  end
  %Reset screen and location
  stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).screen = stimVar.screen.(screens{stimfoils(trial).screenno});
  stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).location = stimVar.location.(locations{stimfoils(trial).locno});
  
  
  %Change foilfield
  if ismember(foilfield,fieldnames(SSA.yess))
    if ischar(stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}))
      while strcmp(stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}),stimVar.(foilfield{:}).(SSA.yess.(foilfield{:})))
        stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}) = stimVar.(foilfield{:}).(strjoin(Sample(fieldnames(stimVar.(foilfield{:})))));
      end
    else
      while stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}) == stimVar.(foilfield{:}).(SSA.yess.(foilfield{:}))
        stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}) = stimVar.(foilfield{:}).(strjoin(Sample(fieldnames(stimVar.(foilfield{:})))));
      end
    end
  elseif ismember(foilfield,fieldnames(SSA.nos))
    if ischar(stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}))
      while ~strcmp(stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}),stimVar.(foilfield{:}).(SSA.nos.(foilfield{:})))
        stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}) = stimVar.(foilfield{:}).(strjoin(Sample(fieldnames(stimVar.(foilfield{:})))));
      end
    else
      while ~stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}) == stimVar.(foilfield{:}).(SSA.nos.(foilfield{:}))
        stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).(foilfield{:}) = stimVar.(foilfield{:}).(strjoin(Sample(fieldnames(stimVar.(foilfield{:})))));
      end
    end
  end
  %Reset screen and location
  stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).screen = stimVar.screen.(screens{stimfoils(trial).screenno});
  stims(trial,stimfoils(trial).screenno,stimfoils(trial).locno).location = stimVar.location.(locations{stimfoils(trial).locno});
  
end

save('SSASpecs','stims','stimtargets', 'stimfoils','stimVar')