%% load stim vars
clear SSA StimVar;

load('stimVars'); %loads up a structure named stimVar 

%% Pick target
SSA.presence = Sample([true]); %if 1, task is report wether target was present or not. If 0, task is report particular dimension
SSA.conjuction = {'AND'};
SSA.conjuctionNo = randi([1 4]);%max conjuctions is 4
SSA.notmask = true;
for ith = 1:SSA.conjuctionNo 
  if ~sum(SSA.notmask)
  SSA.notmask(ith) = Sample([true false]);
  else
    SSA.notmask(ith) = false;
  end
end
SSA.targs = cell(0);

oVarmask = ~ismember(fieldnames(stimVar),{'screen','location'}); %Vars of which at least one must exist in the task (i.e. not screen or loc)
oVars = fieldnames(stimVar);
oVars = oVars(oVarmask);

%this picks a different dimension for each target and then assigns particular values to that 
validtask = 0;
while ~validtask
  for ith = 1:SSA.conjuctionNo
    temparray = SSA.targs;
    SSA.targs(ith,1) = Sample(fieldnames(stimVar));
    while ismember(SSA.targs(ith,1), temparray)
      SSA.targs(ith,1) = Sample(fieldnames(stimVar));
    end
    SSA.targs(ith,2) = Sample(fieldnames(getfield(stimVar,cell2mat(SSA.targs(ith,1)))));
  end
  
  if sum(ismember(SSA.targs(:,1),oVars))>0
    validtask=1;
  end
  
  if all(ismember({'screen','location'},SSA.targs(:,1)))
    validtask = 0;
  end
end

SSA.yess = SSA.targs(~SSA.notmask,:);
SSA.nos = SSA.targs(SSA.notmask,:);

SSA.report = cell(0);
if ~SSA.presence %if a parameter is to be reported, pick one
  SSA.report = Sample(fieldnames(stimVar));
  while ismember(SSA.report, SSA.targs)
    SSA.report = Sample(fieldnames(stimVar));
  end
  SSA.report(2) = Sample(fieldnames(stimVar.(SSA.report{1})));
  SSA.report = cell2struct(SSA.report(2),SSA.report(1),1);
end


%% Print instructions
vowels = 'aAeEiIoOuUhH';

SSA.instructions = sprintf('You''re looking for a single item that has ALL of the following features:\n');
if ~isempty(SSA.yess)
  SSA.yess = cell2struct(SSA.yess(:,2),SSA.yess(:,1),1);
  fields = fieldnames(stimVar);
  for ifield = 1:length(fields)
    if isfield(SSA.yess, fields{ifield})
      if strcmp(fields{ifield},'location')
        SSA.instructions = sprintf('%s\t\ton the %s\n', SSA.instructions, SSA.yess.(fields{ifield}));
      elseif strcmp(fields{ifield},'screen')
        SSA.instructions = sprintf('%s\t\ton %s\n', SSA.instructions, SSA.yess.(fields{ifield}));
      else
       SSA.instructions = sprintf('%s\t\t%s\n', SSA.instructions, SSA.yess.(fields{ifield}));
      end
    end
  end
end

if ~isempty(SSA.nos)
  fields = fieldnames(stimVar);
  SSA.nos = cell2struct(SSA.nos(:,2),SSA.nos(:,1),1);
  for ifield = 1:length(fields)
    if isfield(SSA.nos, fields{ifield})
      if strcmp(fields{ifield},'location')
        SSA.instructions = sprintf('%s\t\tNOT on the %s\n', SSA.instructions, SSA.nos.(fields{ifield}));
      elseif strcmp(fields{ifield},'screen')
        SSA.instructions = sprintf('%s\t\tNOT on %s\n', SSA.instructions, SSA.nos.(fields{ifield}));
      else
       SSA.instructions = sprintf('%s\t\tNOT %s\n', SSA.instructions, SSA.nos.(fields{ifield}));
      end
    end
  end
end


% SSA.instructions = sprintf(' Look for the');
% 
% 
% % if ~isempty(SSA.yess)
%   SSA.yess = cell2struct(SSA.yess(:,2),SSA.yess(:,1),1);
%   if isfield(SSA.yess, 'size')
%      SSA.instructions = sprintf('%s %s', SSA.instructions, SSA.yess.size);
%     if isfield(SSA.yess, 'colors')
%       SSA.instructions = [SSA.instructions ','];
%     end
%   end
%   
%   if isfield(SSA.yess,'colors')
%     SSA.instructions = sprintf('%s %s', SSA.instructions, SSA.yess.colors);
%   end
%   
%   if isfield(SSA.yess,'orientation')
%       if strcmp(SSA.yess.orientation, 'upright')
%           if isfield(SSA.yess, 'colors')
%               SSA.instructions = [SSA.instructions ','];
%           end
%           SSA.instructions = sprintf('%s %s',SSA.instructions,SSA.yess.orientation);
%       end
%   end
%   
%   if isfield(SSA.yess, 'shape')
%     SSA.instructions = sprintf('%s %s', SSA.instructions, SSA.yess.shape);
%   else
%     SSA.instructions = sprintf('%s %s', SSA.instructions, 'item');
%   end
%   
%   if isfield(SSA.yess,'orientation')
%     if ~strcmp(SSA.yess.orientation, 'upright')
%       SSA.instructions = sprintf('%s with a %s',SSA.instructions,SSA.yess.orientation);
%     end
%   end
%   
%   if isfield(SSA.yess,'location')
%     SSA.instructions = sprintf('%s on the %s', SSA.instructions, SSA.yess.location);
%     if isfield(SSA.yess,'screen')
%       SSA.instructions = sprintf('%s of %s', SSA.instructions, SSA.yess.screen);
%     end
%   else
%     if isfield(SSA.yess,'screen')
%       SSA.instructions = sprintf('%s on %s', SSA.instructions, SSA.yess.screen);
%     end
%   end
%   
%   if ~isempty(SSA.nos)
%     SSA.instructions = sprintf('%s,\n that is',SSA.instructions);
%   else
%       SSA.instructions = sprintf('%s\n',SSA.instructions);
%   end
% end
% 
% if ~isempty(SSA.nos)
%   SSA.nos = cell2struct(SSA.nos(:,2),SSA.nos(:,1),1);
%   SSA.instructions = sprintf('%s *NOT* a',SSA.instructions);
%   dimensionorder = {'size','colors','orientation','shape','orientation','location','screen'};
% 
%   nosvalues = {};
%   
%   
%   for ithdim = 1:length(dimensionorder)
%     if isfield(SSA.nos, dimensionorder{ithdim})
%         if ithdim == 3 && ~strcmp(SSA.nos.orientation, 'upright')
%         elseif ithdim == 5 && strcmp(SSA.nos.orientation, 'upright')
%         else
%             nosvalues = [nosvalues, SSA.nos.(dimensionorder{ithdim})];   
%         end
%     elseif ithdim == 4
%         nosvalues = [nosvalues, 'item'];
%     end
%   end
%  
%   if ismember(nosvalues{1}(1),vowels) || all(ismember(nosvalues{1},'rR'))
%       SSA.instructions = sprintf('%sn',SSA.instructions);
%   else
%       SSA.instructions = sprintf('%s',SSA.instructions);
%   end
%   
%   if isfield(SSA.nos, 'size')
%      SSA.instructions = sprintf('%s %s', SSA.instructions, SSA.nos.size);
%     if isfield(SSA.nos, 'colors')
%       SSA.instructions = [SSA.instructions ','];
%     end
%   end
%   
%   if isfield(SSA.nos,'colors')
%     SSA.instructions = sprintf('%s %s', SSA.instructions, SSA.nos.colors);
%   end
%   
%   if isfield(SSA.nos,'orientation')
%       if strcmp(SSA.nos.orientation, 'upright')
%           if isfield(SSA.nos, 'colors')
%               SSA.instructions = [SSA.instructions ','];
%           end
%           SSA.instructions = sprintf('%s, %s',SSA.instructions,SSA.nos.orientation);
%       end
%   end
%   
%   if isfield(SSA.nos, 'shape')
%     SSA.instructions = sprintf('%s %s', SSA.instructions, SSA.nos.shape);
%   else
%     SSA.instructions = sprintf('%s %s', SSA.instructions, 'item');
%   end
%   
%   if isfield(SSA.nos,'orientation')
%     if ~strcmp(SSA.nos.orientation, 'upright')
%       SSA.instructions = sprintf('%s with a %s',SSA.instructions,SSA.nos.orientation);
%     end
%   end
%   
%   if isfield(SSA.nos,'location')
%     SSA.instructions = sprintf('%s on the %s', SSA.instructions, SSA.nos.location);
%     if isfield(SSA.nos,'screen')
%       SSA.instructions = sprintf('%s of %s', SSA.instructions, SSA.nos.screen);
%     end
%   else
%     if isfield(SSA.nos,'screen')
%       SSA.instructions = sprintf('%s on %s', SSA.instructions, SSA.nos.screen);
%     end
%   end
%   SSA.instructions = sprintf('%s\n',SSA.instructions);
% end
% SSA.instructions = sprintf('%s\n',SSA.instructions);

if SSA.presence
  SSA.instructions = sprintf('%sClick on the target to highlight it.\nClick Done to lock your choice.',SSA.instructions);
else
    SSA.instructions = sprintf('%sReport if the target is', SSA.instructions);
    if isfield(SSA.report,'colors')
        if ismember(SSA.report.colors(1),vowels)
            SSA.instructions = sprintf('%s a %s item', SSA.instructions,SSA.report.colors);
        else
            SSA.instructions = sprintf('%s a %s item', SSA.instructions,SSA.report.colors);
        end
    elseif isfield(SSA.report,'size')
        if ismember(SSA.report.size(1),vowels)
            SSA.instructions = sprintf('%s a %s item', SSA.instructions,SSA.report.size);
        else
            SSA.instructions = sprintf('%s a %s item', SSA.instructions,SSA.report.size);
        end
    elseif isfield(SSA.report,'shape')
        if ismember(SSA.report.shape(1),[vowels 'rR'])
            SSA.instructions = sprintf('%s an %s', SSA.instructions,SSA.report.shape);
        else
            SSA.instructions = sprintf('%s a %s', SSA.instructions,SSA.report.shape);
        end
  elseif isfield(SSA.report,'orientation')
      if strcmp(SSA.report.orientation,'upright')
          SSA.instructions = sprintf('%s %s', SSA.instructions,SSA.report.orientation);
      else
          SSA.instructions = sprintf('%s an item with a %s', SSA.instructions,SSA.report.orientation);
      end
  elseif isfield(SSA.report,'location')
     SSA.instructions = sprintf('%s on the %s', SSA.instructions,SSA.report.location);
  elseif isfield(SSA.report,'screen')
     SSA.instructions = sprintf('%s on %s', SSA.instructions,SSA.report.screen); 
  end
end

SSA.instructions = strrep( SSA.instructions,'_',' ');

%makes sure both SSA.yess and SSA.nos are struct for compatibility
if ~isstruct(SSA.yess)
  SSA.yess = cell2struct(SSA.yess(:,2),SSA.yess(:,1),1); 
  %technically could just make it empty struct, since ~isstruct(SSA.yess)
  %== isempty(SSA,yess)
end
if ~isstruct(SSA.nos)
  SSA.nos = cell2struct(SSA.nos(:,2),SSA.nos(:,1),1);
end


save('task','SSA');

