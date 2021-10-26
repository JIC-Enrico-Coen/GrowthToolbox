function s = replacefields( s, varargin )
    deletefields = {};
    for i=1:2:(length(varargin)-1)
        oldfield = varargin{i};
        newfield = varargin{i+1};
        if isfield( s, oldfield )
            newfn = varargin{i+1};
            s.(newfield) = s.(oldfield);
            deletefields{end+1} = oldfield;
        end
    end
    s = rmfield( s, deletefields );
end
