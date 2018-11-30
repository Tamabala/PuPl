function varargout = fieldconsistency(varargin)

% Ensures all input struct arrays have the same fields

varargout = varargin;

allFields = cellfun(@(x) reshape(fieldnames(x), 1, []), varargin, 'un', 0);
allFields = unique([allFields{:}]);

for idx = 1:numel(varargin)
    for newField = reshape(allFields(~ismember(allFields, fieldnames(varargin{idx}))), 1, [])
        [varargout{idx}.(newField{:})] = deal([]);
    end
end

end