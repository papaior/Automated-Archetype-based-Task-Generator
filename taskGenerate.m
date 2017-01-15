function [task, targets] = taskGenerate()
dim = randi(4);
logic = randi(2) - 1; % 1 for 'and', 0 for 'or'
task.presence = 1;
task.report = {};
task.dimension = dim;
task.logic = logic;
load('stimVars');
varlist = fieldnames(stimVar);
fields = 0;
fsegs = zeros(6,1);
for idx = 1:6
	fsegs(idx) = numel(fieldnames(stimVar.(varlist{idx})));
	fields = fields + fsegs(idx);
end
temp = randi(fields,dim,1);
while numel(unique(temp)) ~= numel(temp)
	temp = randi(fields,dim,1);
end
temp = sort(temp);
% insseq = [3,1,4,2,5,6];
for idx = 1:dim
	targets(idx).category = 1;
	for jdx = 1:6
		if temp(idx) - fsegs(jdx) > 0
			temp(idx) =  temp(idx) - fsegs(jdx);
		else
			targets(idx).category = jdx;
			break;
		end
	end
	targets(idx).subcat = temp(idx);
end

task.instructions = {'If there is'};
if logic==0
	task.instructions = strcat(task.instructions, ' one and only one of');
end
logickey = {'or', 'and'};
logickey = logickey(logic+1);
for idx = 1:dim
	addition = '';
	switch targets(idx).category
		case {1,3}
			nlst = fieldnames(stimVar.(varlist{targets(idx).category}));
			addition = nlst{targets(idx).subcat};
			addition = strcat({' a(n) '},addition,{' item'});
		case 2
			nlst = fieldnames(stimVar.(varlist{targets(idx).category}));
			addition = nlst{targets(idx).subcat};
			addition = strcat({' a(n) '},addition);
		case 4
			nlst = {'left-tilted','upright','right-tilted'};
			addition = nlst{targets(idx).subcat};
			addition = strcat({' a(n) '},addition,{' item'});
		case 5
			nlst = {'top left corner', 'middle left', 'bottom left corner', 'top center', 'middle center', 'bottom center', 'top right corner', 'middle right', 'bottom right corner'};
			addition = nlst{targets(idx).subcat};
			addition = strcat({' an item on the '},addition);
		case 6
			addition = strcat({' an item on the screen '},int2str(targets(idx).subcat));
	end
	if idx ~= dim
		addition = strcat(addition,{', '},logickey);
	end
	task.instructions = strcat(task.instructions, addition);
end
task.instructions = strcat(task.instructions, {', please click "Present", otherwise please click "Absent".\n'});
temp = task.instructions{1};
interval = 50;
for idx = strfind(temp, ' ')
	if idx > interval
		temp = strcat(temp(1:idx-1),'/',temp(idx+1:end));
		interval = interval + 50;
	end
end
temp = strrep(temp, '/', '\n');
task.instructions = sprintf(temp);

save('Task','task','targets');
end
