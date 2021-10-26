function s = emptystructarray( varargin )
%s = emptystructarray( varargin )
%   Make an empty struct array. The fields are supplied as either
%   * a series of string arguments
%   * a single cell array of strings
%   * a struct, whose fields will be used.
%
%s = emptystructarray( sz, varargin )
%   Make a struct array of the given shape, having the fields supplied as
%   above, with all fields of all structs set to [].

    if nargin==0
        s = struct();
        return;
    end

    if isnumeric( varargin{1} )
        sz = varargin{1};
        varargin(1) = [];
        if isempty(sz)
            sz = [0 0];
        elseif length(sz)==1
            sz = [1 sz];
        end
    else
        sz = [1 0];
    end
    len = prod(sz);
    
    if isempty(varargin)
        s = struct();
    else
        if iscell(varargin{1})
            fields = varargin{1};
        elseif isstruct( varargin{1} )
            fields = fieldnames( varargin{1} );
        else
            fields = varargin;
        end
        for i=1:length(fields)
            s.(fields{i}) = [];
        end
    end
    
    if len==0
        s = s(1:0);
    elseif len > 1
        s(len) = s(1);
    end
    s = reshape( s, sz );
end
