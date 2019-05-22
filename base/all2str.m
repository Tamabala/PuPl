
function outstr = all2str(arg)

if isnumeric(arg) || islogical(arg)
    outstr = regexprep(sprintf('[%s]', num2str(arg)), '\s+', ' ');
elseif ischar(arg)
    outstr = sprintf('''%s''', arg);
elseif iscell(arg)
    outstr = '{';
    for el = reshape(arg, 1, [])
        outstr = sprintf('%s%s ', outstr, all2str(el{:}));
    end
    outstr = sprintf('%s\b}', outstr);
elseif isstruct(arg)
    if isfield(arg, 'loadstr')
        outstr = arg.loadstr;
    else
        outstr = 'struct(';
        for field = reshape(fieldnames(arg), 1, [])
            outstr = sprintf('%s''%s'', %s, ', outstr, field{:}, all2str({arg.(field{:})}));
        end
        outstr = sprintf('%s\b\b)', outstr);
    end
elseif isempty(arg)
    outstr = '[]';
end

end