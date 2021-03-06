function [task, targets] = BinaryTargetSearch_task()
total_dims = randi(2) + 2;
dim1 = randi(total_dims-1);
dim2 = total_dims - dim1;
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
    while sum(targets(idx).category == 5) && sum(targets(idx).category == 6)
        targets(idx).category = sort(randsample(dims, task.dimension(idx), false))';
    end
	targets(idx).subcat = zeros(1,dims);
	for jdx = targets(idx).category
		targets(idx).subcat(jdx) = randi(fsegs(jdx));
	end
end

if task.dimension(1)>task.dimension(2)
	dim1 = 2;
	dim2 = 1;
else
	dim1 = 1;
	dim2 = 2;
end
while sum( (targets(dim1).subcat == targets(dim2).subcat) & (targets(dim1).subcat | targets(dim2).subcat) ) == nnz(targets(dim1).subcat)
	if task.dimension(dim1) == 1
		idx = sum(targets(dim1).category);
	else
		idx = randsample(targets(dim1).category, 1);
	end
	targets(dim1).subcat(idx) = randi(fsegs(idx));
end

task.instructions = {'You will see'};
if logic==0
	task.instructions = strcat(task.instructions, ' ONE AND ONLY ONE');
else
	task.instructions = strcat(task.instructions, ' BOTH');
end
task.instructions = strcat(task.instructions, ' of the two items listed below:');
insitems = cell(2, 1);
for idx = 1:2
	insitems{idx} = {''};
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
		addition = strcat(addition,{' in the '},nlst{targets(idx).subcat(5)});
	end
	if targets(idx).subcat(6) ~= 0
		nlst = fieldnames(stimVar.(varlist{6}));
		addition = strcat(addition,{' on '},nlst{targets(idx).subcat(6)});
	end
	if sum(addition{1}(2) == ['a' 'e' 'i' 'o' 'u' 'A' 'E' 'F' 'H' 'I' 'M' 'N' 'O' 'R' 'S' 'X'])
		addition = strcat({' an'}, addition);
	else
		addition = strcat({' a'}, addition);
  end
	insitems{idx} = addition;
end
for idx = 1:2
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

save('DualSymTask','task','targets');
end
