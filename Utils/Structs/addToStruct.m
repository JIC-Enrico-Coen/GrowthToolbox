function s = addToStruct( s, varargin )
    for i=1:2:length(varargin)
        s.(varargin{i}) = varargin{i+1};
    end
end
