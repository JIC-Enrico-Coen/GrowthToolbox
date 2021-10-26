function types = addFieldTypes( types, varargin )
    if isempty(types)
        types = struct();
    end
    for i=1:3:(length(varargin)-2)
        fn = varargin{i};
        if ischar(fn)
            fn = {fn};
        end
        types.(fn).indextypes = varargin{i+1};
        types.(fn).valuetypes = varargin{i+2};
    end
end
