function s = defaultfields( s, varargin )
%s = defaultfields( s, fieldname, fieldvalue, ... )
%   Set nonexistent fields of s to the specified values.
    if isempty(s)
        s = struct();
        for i = 1 : 2 : (length( varargin )-1)
            s.(varargin{i}) = varargin{i+1};
        end
    else
        for i = 1 : 2 : (length( varargin )-1)
            if ~isfield( s, varargin{i} )
                s.(varargin{i}) = varargin{i+1};
            end
        end
    end
end
