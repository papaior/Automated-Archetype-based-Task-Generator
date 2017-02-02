function [task, targets] = taskGenerate()
logic = randi(2) - 1; % 1 for 'and', 0 for 'or'
if logic
	dim = randi(4);
else
	dim = randi(3) + 1;
end
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

task.instructions = {'If you see'};
if logic==0
	nums = {' the item', ' either one of the two items', ' either one of the three items', ' either one of the four items'};
	task.instructions = strcat(task.instructions, nums{dim});
else
	nums = {' the item', ' all of the two items', ' all of the three items', ' all of the four items'};
	task.instructions = strcat(task.instructions, nums{dim});
end
task.instructions = strcat(task.instructions, ' listed below:');
insitems = cell(dim, 1);
for idx = 1:dim
	insitems{idx} = {''};
	switch targets(idx).category
		case {1,3}
			nlst = fieldnames(stimVar.(varlist{targets(idx).category}));
			insitems{idx} = nlst{targets(idx).subcat};
			insitems{idx} = strcat(insitems{idx},{' item'});
		case 2
			nlst = fieldnames(stimVar.(varlist{targets(idx).category}));
			insitems{idx} = strcat({nlst{targets(idx).subcat}});
		case 4
			nlst = fieldnames(stimVar.(varlist{targets(idx).category}));
			insitems{idx} = nlst{targets(idx).subcat};
			insitems{idx} = strcat(insitems{idx},{' item'});
		case 5
% 			nlst = {'top left corner', 'middle left', 'bottom left corner', 'top center', 'middle center', 'bottom center', 'top right corner', 'middle right', 'bottom right corner'};
			nlst = fieldnames(stimVar.(varlist{targets(idx).category}));
			insitems{idx} = nlst{targets(idx).subcat};
			insitems{idx} = strcat({'item on the '},insitems{idx});
		case 6
			insitems{idx} = strcat({'item on the screen '},int2str(targets(idx).subcat));
	end
	if sum(insitems{idx}{1}(1) == ['a' 'e' 'i' 'o' 'u' 'A' 'E' 'F' 'H' 'I' 'M' 'N' 'O' 'R' 'S' 'X'])
		insitems{idx} = strcat({'an '}, insitems{idx});
	else
		insitems{idx} = strcat({'a '}, insitems{idx});
	end
end
inswidth = numel(task.instructions);
if inswidth < 50
	inswidth = 50;
end
for idx = 1:dim
	dimwidth = numel(insitems{idx}{1});
	paddings = ones(1, floor((inswidth - dimwidth)/2))*30;
	task.instructions = strcat(task.instructions, '\n', char(paddings), insitems{idx}{1});
end
task.instructions = strcat(task.instructions, {'\nPlease click "Present"; otherwise please click "Absent".\n'});
temp = task.instructions{1};
task.instructions = sprintf(temp);

save('Task','task','targets');
end
