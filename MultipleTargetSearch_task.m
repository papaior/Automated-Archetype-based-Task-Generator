function [task, targets] = MultipleTargetSearch_task()
logic = randi(2) - 1; % 1 for 'and', 0 for 'or'
dim = randi(3) + 1;
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
temp = randsample(fields,dim,false);
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
	nums = {' the item', ' ONE AND ONLY ONE of the two items', ' ONE AND ONLY ONE of the three items', ' ONE AND ONLY ONE of the four items'};
	task.instructions = strcat(task.instructions, nums{dim});
else
	nums = {' the item', ' ALL of the two items', ' ALL of the three items', ' ALL of the four items'};
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
			insitems{idx} = strcat({'item in the '},insitems{idx});
		case 6
			nlst = fieldnames(stimVar.(varlist{targets(idx).category}));
			insitems{idx} = nlst{targets(idx).subcat};
			insitems{idx} = strcat({'item on '},insitems{idx});
	end
	if sum(insitems{idx}{1}(1) == ['a' 'e' 'i' 'o' 'u' 'A' 'E' 'F' 'H' 'I' 'M' 'N' 'O' 'R' 'S' 'X'])
		insitems{idx} = strcat({'an '}, insitems{idx});
	else
		insitems{idx} = strcat({'a '}, insitems{idx});
	end
end
% inswidth = numel(task.instructions);
% if inswidth < 50
% 	inswidth = 50;
% end
for idx = 1:dim
% 	dimwidth = numel(insitems{idx}{1});
% 	paddings = ones(1, floor((inswidth - dimwidth)/2))*30;
% 	paddings = ones(1, 2)*30;
	task.instructions = strcat(task.instructions, '\n\t\t', strrep(insitems{idx}{1}, '_', ' '));
end
task.instructions = strcat(task.instructions, {'\nplease click to mark'});
if logic==0
	task.instructions = strcat(task.instructions, ' it');
else
	task.instructions = strcat(task.instructions, ' them');
end
task.instructions = strcat(task.instructions, {'.\nClick "done" when you are done.\n'});
temp = task.instructions{1};
task.instructions = sprintf(temp);

save('Task','task','targets');
end
