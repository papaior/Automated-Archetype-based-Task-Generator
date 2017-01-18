function [task, targets] = dualSymTaskGenerate()
dim1 = randi(3);
dim2 = 4 - dim1;
logic = randi(2) - 1; % 1 for 'and', 0 for 'or'
task.presence = 1;
task.report = {};
task.dimension = [dim1 dim2];
task.logic = logic;
load('stimVars');
varlist = fieldnames(stimVar);
fields = 0;
dims = numel(varlist);
fsegs = zeros(1,dims);
for idx = 1:dims
	fsegs(idx) = numel(fieldnames(stimVar.(varlist{idx})));
	fields = fields + fsegs(idx);
end

for idx = 1:2
	targets(idx).category = sort(randsample(dims, task.dimension(idx), false))';
	targets(idx).subcat = zeros(1,dims);
	for jdx = targets(idx).category
		targets(idx).subcat(jdx) = randi(fsegs(jdx));
	end
end

if dim1>dim2
	dim1 = 2;
	dim2 = 1;
else
	dim1 = 1;
	dim2 = 2;
end
while sum(targets(dim1).subcat == targets(dim2).subcat) == nnz(targets(dim1).subcat)
	idx = randsample(targets(dim1).category, 1);
	targets(dim1).subcat(idx) = randi(fsegs(idx));
end

task.instructions = {'If there'};
if logic==0
	task.instructions = strcat(task.instructions, ' is one and only one of');
else
	task.instructions = strcat(task.instructions, ' are both');
end
logickey = {'or', 'and'};
logickey = logickey(logic+1);
for idx = 1:2
	addition = '';
	for idim = [3 4 1 2]
		if targets(idx).subcat(idim) ~= 0
			nlst = fieldnames(stimVar.(varlist{idim}));
			addition = strcat(addition,{' '},nlst{targets(idx).subcat(idim)});
		end
	end
	if targets(idx).subcat(2) == 0
		addition = strcat(addition, {' item'});
	end
	if targets(idx).subcat(5) ~= 0
		nlst = fieldnames(stimVar.(varlist{5}));
		addition = strcat(addition,{' on the '},nlst{targets(idx).subcat(5)});
	end
	if targets(idx).subcat(6) ~= 0
		nlst = fieldnames(stimVar.(varlist{6}));
		addition = strcat(addition,{' on '},nlst{targets(idx).subcat(6)});
	end
	if sum(addition{1}(2) == ['a' 'e' 'i' 'o' 'u' 'F' 'H' 'I' 'N' 'O' 'R' 'S' 'X'])
		addition = strcat({' an'}, addition);
	else
		addition = strcat({' a'}, addition);
	end
	if idx ~= 2
		addition = strcat(addition,{', '},logickey);
	end
	task.instructions = strcat(task.instructions, addition);
end
task.instructions = strcat(task.instructions, {', please click "Present"; otherwise please click "Absent".\n'});
temp = task.instructions{1};
temp = strrep(temp, '_', ' ');
interval = 50;
for idx = strfind(temp, ' ')
	if idx > interval
		temp = strcat(temp(1:idx-1),'/',temp(idx+1:end));
		interval = interval + 50;
	end
end
temp = strrep(temp, '/', '\n');
task.instructions = sprintf(temp);

save('DualSymTask','task','targets');
end
