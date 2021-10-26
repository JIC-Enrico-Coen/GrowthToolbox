function r = randelement( a, varargin )
    if isempty(a)
        r = [];
    else
        r = a( randi( [1, numel(a)], varargin{:} ) );
    end
end
