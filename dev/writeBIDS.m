
function writeBIDS(EYE, varargin)

p = inputParser;
addParameter(p, 'projectpath', []);
addParameter(p, 'types', []);
addParameter(p, 'move', []);
parse(p, varargin{:});
if isempty(p.Results.projectpath)
    projectpath = uigetdir(pwd, 'Select top-level folder');
    if projectpath == 0
        return
    end
else
    projectpath = p.Results.projectpath;
end

typeopts = {
    'raw'
    'sourcedata'
    'derivatives'
};
if isempty(p.Results.types)
    sel = listdlg(...
        'PromptString', 'Save which data?',...
        'ListString', typeopts);
    if isempty(sel)
        return
    else
        types = typeopts(sel);
    end
else
    types = p.Results.types;
end
types = cellstr(types);
if ismember('derivatives', types)
    deriv = inputdlg('Name of derivative?');
    if isempty(deriv)
        return
    else
        types(strcmp(types, 'derivatives')) = deriv;
    end
end
if ismember('raw', types)
    if isempty(p.Results.move)
        q = 'Delete original raw data?';
        a = questdlg(q, q, 'Yes', 'No', 'Cancel', 'No');
        switch a
            case 'Yes'
                move = true;
            case 'No'
                move = false;
            otherwise
                return
        end
    else
        move = p.Results.move;
    end
end

fpritnf('Saving to BIDS format...\n')
for dataidx = 1:numel(EYE) % Populate
    fprintf('\t%s...\n', EYE(dataidx).name);
    masterfilehead = getfilehead(EYE(dataidx));
    
    if ismember('raw', types)
        % Save raw data
        fprintf('\t\tSaving raw...');
        currfilehead = sprintf('%s/raw/%s', projectpath, masterfilehead);
        mkdir(fileparts(currfilehead)); % Create folder
        [~, ~, eyext] = fileparts(EYE(dataidx).src);
        saveraw(move, EYE(dataidx).src, sprintf('%s_eyetrack%s', currfilehead, eyext));
        curreventlog = EYE(dataidx).eventlog;
        if ~isempty(curreventlog)
            [~, ~, evext] = fileparts(curreventlog.src);
            saveraw(move, curreventlog.src, sprintf('%s_events%s', currfilehead, evext));
        end
        fprintf('done\n');
    end
    
    if ismember('sourcedata', types)
        % Save source data
        fprintf('\t\tSaving sourcedata...');
        currfilehead = sprintf('%s/sourcedata/%s', projectpath, masterfilehead);
        mkdir(fileparts(currfilehead)); % Create folder
        data = EYE(dataidx).getraw();
        save(sprintf('%s_eyetrack.eyedata', currfilehead), 'data', '-v6');
        if ~isempty(curreventlog)
            eventlog2tsv(curreventlog, sprintf('%s_events.tsv', currfilehead));
        end
        fprintf('done\n');
    end
    
    for deriv = reshape(types(~ismember(types, {'raw' 'sourcedata'})), 1, [])
        % Save derived data
        fprintf('\t\tSaving derivatives: %s...', deriv{:});
        currfilehead = sprintf('%s/derivatives/%s/%s', projectpath, deriv{:}, masterfilehead);
        mkdir(fileparts(currfilehead)); % Create folder
        data = EYE(dataidx);
        save(sprintf('%s_eyetrack.eyedata', currfilehead), 'data', '-v6');
        fprintf('done\n');
    end
end
fprintf('Done\n');

end

function filehead = getfilehead(EYE)

currpath = sprintf('sub-%s/', EYE(dataidx).BIDS.sub);
% Session-specific data?
if isfield(EYE(dataidx).BIDS, 'ses')
    sespath = sprintf('%s/ses-%s/', currpath, EYE(dataidx).BIDS.ses);
    mkdir(sespath);
    currpath = sespath;
end
currpath = sprintf('%s/eyetrack/', currpath);
filehead = sprintf('%ssub-%s', currpath, EYE(dataidx).BIDS.sub);
for field = {'ses' 'acq' 'ce' 'task' 'run'}
    if isfield(EYE(dataidx).BIDS, field{:})
        filehead = sprintf('%s_%s-%s', filehead, field{:}, EYE(dataidx).BIDS.(field{:}));
    end
end

end

function saveraw(move, varargin)

if move
    movefile(varargin{:});
else
    copyfile(varargin{:});
end

end