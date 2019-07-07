
function EYE = readeyelinkASC(fullpath)

EYE = [];

%% Read raw

rawdata = fastfileread(fullpath);
% Get data lines
lines = regexp(rawdata, '.*', 'match', 'dotexceptnewline');
% Get first characters of lines
tokens = regexp(rawdata, '^.', 'match', 'lineanchors');
nonemptyidx = ~cellfun(@isempty, lines);
tokens = tokens(nonemptyidx);
lines = lines(nonemptyidx);

issample = ismember([tokens{:}], '123456789'); % Lines beginning with a number are data samples
samples = lines(issample); % Data sample lines
infolines = lines(~issample); % All other lines contain metadata/events
firstwords = cellfun(@(x) sscanf(x, '%s', 1), infolines, 'UniformOutput', false); % Other lines are identified by their first words

%% Find data

samples = regexprep(samples, '\s\.\s', ' nan '); % Missing data are dots, replace with space-padded nan
datamat = cell2mat(cellfun(@(x) sscanf(x, '%g'), samples, 'UniformOutput', false));

% Find an info line beginning with "samples"
sampleinfo = lower(regexp(infolines{find(strcontains(lower(firstwords), 'samples'), 1)}, '\t', 'split'));
for ii = 1:numel(sampleinfo)
    switch sampleinfo{ii}
        case 'gaze'
            neyes = nnz(ismember(sampleinfo([ii+1 ii+2]), {'left' 'right'}));
            if neyes == 1
                whicheye = lower(sampleinfo{ii+1});
            end
        case 'rate'
            srate = sscanf(sampleinfo{ii+1}, '%g', 1);
            srate = round(srate);
        otherwise
            continue
    end
end

if neyes == 1
    fields = {
        {'urgaze' 'x' whicheye}
        {'urgaze' 'y' whicheye}
        {'urdiam' whicheye}
    };
else
    fields = {
        {'urgaze' 'x' 'left'}
        {'urgaze' 'y' 'left'}
        {'urdiam' 'left'}
        {'urgaze' 'x' 'right'}
        {'urgaze' 'y' 'right'}
        {'urdiam' 'right'}
    };
end

% Assign samples
for ii = 1:numel(fields)
    EYE = setfield(EYE, fields{ii}{:}, datamat(ii+1, :));
end

EYE.srate = srate;

%% Find events

eventlines = infolines(strcontains(lower(firstwords), 'msg'));
eventtimes = nan(size(eventlines));
eventtypes = cell(size(eventlines));
for ii = 1:numel(eventlines)
    curreventinfo = regexp(eventlines{ii}, '\t', 'split');
    curreventinfo = regexp(curreventinfo{2}, '\s', 'split');
    eventtimes(ii) = sscanf(curreventinfo{1}, '%g');
    eventtypes{ii} = strtrim(sprintf('%s ', curreventinfo{2:end}));
end

% Find latencies
timestamps = datamat(1, :);
latencies = nan(size(eventtimes));
for ii = 1:numel(latencies)
    [~, latencies(ii)] = min(abs(timestamps - eventtimes(ii)));
end

EYE.event = struct(...
    'type', eventtypes,...
    'time', num2cell(eventtimes / 1000),...
    'latency', num2cell(latencies),...
    'rt', repmat({NaN}, size(latencies)));

end