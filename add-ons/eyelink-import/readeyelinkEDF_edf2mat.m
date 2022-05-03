
function EYE = readeyelinkEDF_edf2mat(fullpath)

EYE = [];

if isempty(which('Edf2Mat'))
    msgbox('Edf2Mat not found. It can be installed from github.com/uzh/edf-converter. If it is already installed, make sure it is in the path (see mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html for an explanation of the path).')
else
    output = Edf2Mat(fullpath);
    edf = output.RawEdf;
    % Get srate
    EYE.srate = double(edf.RECORDINGS(1).sample_rate);
    % Get times
    EYE.times = double(edf.FSAMPLE.time)/EYE.srate;
    % Get data
    fields = {
        {'gaze' 'x'} {'gx'}
        {'gaze' 'y'} {'gy'}
        {'pupil'} {'pa'}
    };
    % Get ocularity
    sides = {'left' 'right'};
    side_indic = double(unique([edf.RECORDINGS.eye]));
    if numel(side_indic) == 1
        if side_indic ~= 3
            sides = sides(side_indic); % 1 = left; 2 = right
        end
    end
    % Get eye event
    eventtype = {'FIX', 'SACC', 'BLINK'};
    eyevent = extractevent(edf, sides, eventtype);
    % Get samples
    for fi = 1:size(fields, 1)
        for si = 1:numel(sides)
            vec = edf.FSAMPLE.(fields{fi, 2}{:})(si, :);
            % Replace missing or zero data with nan
            vec(vec == single(-32768)) = nan;
            vec(eyevent.BLINK.(sides{si})) = nan;
            EYE = setfield(EYE, fields{fi, 1}{:}, sides{si}, vec);
        end
    end
    % Get sample rate
    EYE.srate = double(edf.RECORDINGS(1).sample_rate);
    % Get units
    switch double(edf.RECORDINGS(1).pupil_type)
        case 0
            pupil_type = 'area';
        case 1
            pupil_type = 'diameter';
    end
    EYE.units.pupil = {pupil_type 'arbitrary units' 'absolute'};
    EYE.units.gaze = [];
    EYE.units.gaze.x = {'x' 'px' 'from screen left'};
    EYE.units.gaze.y = {'y' 'px' 'from screen top'};

    % Get events
    msg_idx = arrayfun(@(s)~isempty(s.message), edf.FEVENT);
    msg = edf.FEVENT(msg_idx);
    EYE.event = struct(...
        'time', num2cell(double([msg.sttime])/1000),...
        'name', {msg.message}...
    );
end

    function eyevent = extractevent(rawEDF, sides, eventype)
        
        fevent = rawEDF.FEVENT;
        startStamp = rawEDF.RECORDINGS(1).time;
        eyevent = [];
        
        for j = 1:length(sides)
            eyeName = sides{j};
            if strcmp(eyeName, 'left')
                marker = 0;
            elseif strcmp(eyeName, 'right')
                marker = 1;
            end
            
            eye_idx = arrayfun(@(s) s.eye == marker, fevent);
            
            for i = 1:length(eventype)
                evtName = eventype{i};
                evt_idx = arrayfun(@(s) strcmp(s.codestring, ['END', evtName]), fevent);
                eye_evt_idx = eye_idx & evt_idx;
                events = fevent(eye_evt_idx);
                index = num2cell([[events.sttime]',[events.entime]'], 2);
                index  = cellfun(@(x) x(1):x(2), index, 'UniformOutput', false);
                index = [index{:}] - startStamp + 1;
                eyevent.(evtName).(eyeName) = index;
            end
        end
    end
    
end
