function options = addOptions( options, varargin )
    for i=1:3:(nargin-2)
        field = varargin{i};
        values = varargin{i+1};
        value = varargin{i+2};
        options.(field).range = values;
        options = setOptionIndex( options, field, value );
    end
end
