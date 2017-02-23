function BinaryTargetSearch_trials()
SSAstimVar;
load('stimVars');

numtrials = 5;
if ~exist('DualSymTask.mat', 'file')
	[SSA, SSATargets] = BinaryTargetSearch_task();
else
	load('DualSymTask');
	SSA = task;
	SSATargets = targets;
end

stims = struct();
plist = fieldnames(stimVar);
stimtargets = struct();
choices = {'Present' 'Absent'};
for t=1:5
	stimtargets(1,t).targetNum = 0;
	stimtargets(1,t).screenno = [];
	stimtargets(1,t).locno = [];
	stimtargets(1,t).correct = choices{randi(2)};
end

% llist = fieldnames(stimVar.location);
% slist = fieldnames(stimVar.screen);
% poslist = [0,0,0,0,1,1]';
% featlist = [1,1,1,1,0,0]';


for idx=1:6
	stims(1,1,1).(plist{idx}) = 0;
end
stims(1,1,1).discard = false;

for trial = 1:numtrials
	% targetpres = zeros(SSA.dimension, 1);
	
	gencell = cell(9);
	
	for screen = 1:9
		for location = 1:9
			[rstim,genvec] = randomGen(location,screen,false);
			stims(trial,screen,location) = rstim;
			gencell{screen,location} = genvec;
			ddims = MSMatchedDims(SSATargets, genvec);
			if ifDiscard(SSATargets, genvec)
				stims(trial,screen,location).discard = true;
			else
				while ddims > 0
					[rstim,genvec] = randomGen(location,screen,false);
					stims(trial,screen,location) = rstim;
					gencell{screen,location} = genvec;
					ddims = MSMatchedDims(SSATargets, genvec);
				end
			end
		end
	end

	% assignin('base','SSATargets',SSATargets);
	% assignin('base','gencell',gencell);
	if strcmp(stimtargets(1,trial).correct,'Present')
		if SSA.logic == true
			togen = [1 2];
		else
			togen = randi(2);
		end
	else
		if SSA.logic == true
			togen = randsample([1 2], randi(2)-1);
		else
			togen = [];
		end
	end
	selected = zeros(9);
	for idim = togen
		screen = randi(9);
		location = randi(9);
		while selected(screen,location) ~= false || stims(trial,screen,location).discard == true
			screen = randi(9);
			location = randi(9);
		end
		if sum(SSATargets(idim).subcat & [1 1 1 1 0 0]) == 0 && sum(SSATargets(idim).subcat & [0 0 0 0 1 1]) == 1
			dislocs = true;
		else
			dislocs = false;
		end
		for dimx = fliplr(SSATargets(idim).category)
			if dimx==5
				location = SSATargets(idim).subcat(5);
				if dislocs
					for idx=1:9
						selected(idx,location) = true;
					end
					stims(trial,screen,location).discard = false;
				end
			end
			if dimx==6
				screen = SSATargets(idim).subcat(6);
				if dislocs
					for idx=1:9
						selected(screen,idx) = true;
					end 
					stims(trial,screen,location).discard = false;
				end
			end
			selected(screen,location) = true;
			dname = fieldnames(stimVar.(plist{dimx}));
			stims(trial,screen,location).(plist{dimx}) = stimVar.(plist{dimx}).(dname{SSATargets(idim).subcat(dimx)});
		end
		stimtargets(1,trial).targetNum = stimtargets(1,trial).targetNum + 1;
		stimtargets(1,trial).screenno = [stimtargets(1,trial).screenno screen];
		stimtargets(1,trial).locno = [stimtargets(1,trial).locno location];
	end
end

save('SSASpecs', 'SSA', 'stims', 'stimtargets', 'numtrials');

end

function idiscard = ifDiscard(targets, genvec)
	idiscard = 0;
	for idx = 1:2
		if sum(targets(idx).subcat & [1 1 1 1 0 0]) == 0 && sum(targets(idx).subcat & [0 0 0 0 1 1]) == 1
			if sum((genvec == targets(idx).subcat) & [0 0 0 0 1 1]) > 0
				idiscard = idiscard + 1;
			end
		else
			continue;
		end
	end
end

function pdims = MSMatchedDims(targets, genvec)
	pdims = 0;
	for idx = 1:2
		mask = targets(idx).subcat & ones(1,6);
		if sum(mask(1:4)) == 0
			continue;
		end
		if sum((targets(idx).subcat == genvec) == mask) == 6
			pdims = pdims+1;
		end
	end
end

function [ranstim, genvec] = randomGen(location, screen, discard)
	load('stimVars');
	plist = fieldnames(stimVar);
	llist = fieldnames(stimVar.location);
	slist = fieldnames(stimVar.screen);

	genvec = zeros(1,6);
	genvec(6) = screen;
	genvec(5) = location;
	for idx=1:4
		pname = plist{idx};
		olist = fieldnames(stimVar.(pname));
		r = randi(numel(olist));
		genvec(idx) = r;
		ranstim.(pname) = stimVar.(pname).(olist{r});
	end
	ranstim.location = stimVar.location.(llist{location});
	ranstim.screen = stimVar.screen.(slist{screen});
	ranstim.discard = discard;
end