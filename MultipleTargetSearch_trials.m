function MultipleTargetSearch_trials()
SSAstimVar;
load('stimVars');

numtrials = 5;
if ~exist('Task.mat', 'file')
	[SSA, SSATargets] = MultipleTargetSearch_task();
else
	load('Task');
	SSA = task;
	SSATargets = targets;
end

stims = struct();
plist = fieldnames(stimVar);
stimtargets = struct();
choices = {'Present', 'Absent'};
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

targetsvec = zeros(6,1);
for idx = 1:SSA.dimension
	targetsvec(SSATargets(idx).category) = SSATargets(idx).subcat;
end

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
			[ddims, ldims] = matchedDims(SSATargets, genvec);
			if ldims > 0
				stims(trial,screen,location).discard = true;
			else
				while ddims > 0
					[rstim,genvec] = randomGen(location,screen,false);
					stims(trial,screen,location) = rstim;
					gencell{screen,location} = genvec;
					[ddims, ldims] = matchedDims(SSATargets, genvec);
				end
			end
		end
	end

% 	assignin('base','SSATargets',SSATargets);
% 	assignin('base','gencell',gencell);
%randsample
	if strcmp(stimtargets(1,trial).correct,'Present')
		selected = zeros(9);
		if SSA.logic == true
			if targetsvec(5) && targetsvec(6)
				selected(targetsvec(6), targetsvec(5)) = true;
			end
			for dimx=numel(SSATargets):-1:1
				screen = randi(9);
				location = randi(9);
				while selected(screen,location) ~= false
					screen = randi(9);
					location = randi(9);
				end
				selected(screen,location) = true;
				if SSATargets(dimx).category==5
					location = SSATargets(dimx).subcat;
					for idx=1:9
						selected(idx,location) = true;
						stims(trial,idx,location).discard = true;
					end
					stims(trial,screen,location).discard = false;
				end
				if SSATargets(dimx).category==6
					screen = SSATargets(dimx).subcat;
					for idx=1:9
						selected(screen,idx) = true;
						stims(trial,screen,idx).discard = true;
					end 
					stims(trial,screen,location).discard = false;
				end
				dname = fieldnames(stimVar.(plist{SSATargets(dimx).category}));
				stims(trial,screen,location).(plist{SSATargets(dimx).category}) = stimVar.(plist{SSATargets(dimx).category}).(dname{SSATargets(dimx).subcat});
				stimtargets(1,trial).targetNum = stimtargets(1,trial).targetNum +1;
				stimtargets(1,trial).screenno = [stimtargets(1,trial).screenno screen];
				stimtargets(1,trial).locno = [stimtargets(1,trial).locno location];
			end
		else
			dimx = randi(numel(SSATargets));
			screen = randi(9);
			location = randi(9);
			if SSATargets(dimx).category==5
				location = SSATargets(dimx).subcat;
				for idx=1:9
					selected(idx,location) = true;
					stims(trial,idx,location).discard = true;
				end
				stims(trial,screen,location).discard = false;
			end
			if SSATargets(dimx).category==6
				screen = SSATargets(dimx).subcat;
				for idx=1:9
					selected(screen,idx) = true;
					stims(trial,screen,idx).discard = true;
				end 
				stims(trial,screen,location).discard = false;
			end
			dname = fieldnames(stimVar.(plist{SSATargets(dimx).category}));
			stims(trial,screen,location).(plist{SSATargets(dimx).category}) = stimVar.(plist{SSATargets(dimx).category}).(dname{SSATargets(dimx).subcat});
			stimtargets(1,trial).targetNum = stimtargets(1,trial).targetNum +1;
			stimtargets(1,trial).screenno = [stimtargets(1,trial).screenno screen];
			stimtargets(1,trial).locno = [stimtargets(1,trial).locno location];
		end
	else
		selected = zeros(9);
		if SSA.logic == true
			seldims = randsample(numel(SSATargets),randi(numel(SSATargets))-1,false);
			if numel(seldims) > 0
				seldims = sort(seldims,'descend');
				for dimx=1:numel(seldims)
					screen = randi(9);
					location = randi(9);
					while selected(screen,location) ~= false
						screen = randi(9);
						location = randi(9);
					end
					selected(screen,location) = true;
					if SSATargets(dimx).category==5
						location = SSATargets(dimx).subcat;
						for idx=1:9
							selected(idx,location) = true;
							stims(trial,idx,location).discard = true;
						end
						stims(trial,screen,location).discard = false;
					end
					if SSATargets(dimx).category==6
						screen = SSATargets(dimx).subcat;
						for idx=1:9
							selected(screen,idx) = true;
							stims(trial,screen,idx).discard = true;
						end 
						stims(trial,screen,location).discard = false;
					end
					dname = fieldnames(stimVar.(plist{SSATargets(dimx).category}));
					stims(trial,screen,location).(plist{SSATargets(dimx).category}) = stimVar.(plist{SSATargets(dimx).category}).(dname{SSATargets(dimx).subcat});
                    
					stimtargets(1,trial).targetNum = stimtargets(1,trial).targetNum +1;
					stimtargets(1,trial).screenno = [stimtargets(1,trial).screenno screen];
					stimtargets(1,trial).locno = [stimtargets(1,trial).locno location];
				end
			end
		end
	end
	
end

save('SSASpecs', 'SSA', 'stims', 'stimtargets', 'numtrials');

end

function [pdims, ldims] = matchedDims(targets, genvec)
	pdims = 0;
	for idx=1:4
		for jdx = 1:numel(targets)
			if targets(jdx).category == idx && targets(jdx).subcat == genvec(idx)
				pdims = pdims +1;
			end
		end
	end
	ldims = 0;
	for idx=5:6
		for jdx = 1:numel(targets)
			if targets(jdx).category == idx && targets(jdx).subcat == genvec(idx)
				ldims = ldims +1;
			end
		end
	end
end

function [ranstim, genvec] = randomGen(location, screen, discard)
	load('stimVars');
	plist = fieldnames(stimVar);
	llist = fieldnames(stimVar.location);
	slist = fieldnames(stimVar.screen);

	genvec = zeros(6,1);
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