function m = makeMap( varargin )
    m = containers.Map();
    for i=1:2:(length(varargin)-1)
        m( varargin{i} ) = varargin{i+1};
    end
end
