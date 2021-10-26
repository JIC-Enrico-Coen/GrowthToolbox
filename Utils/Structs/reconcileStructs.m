function sa = reconcileStructs( varargin )
%sa = reconcileStructs( varargin )
%   The arguments are structs of possibly dissimilar structures.
%   The result is an array of structs, consisting of all the given structs
%   in the order they were given, and with any missing fields filled by [].
%   If no arguments are given, an empty struct array of empty structs is
%   returned.

    if nargin==0
        sa = struct([]);
        return;
    end

    if nargin==1
        sa = varargin{1};
        return;
    end
    
    allfields = fieldnames(varargin{1});
    for i=2:nargin
        allfields = union( allfields, fieldnames(varargin{i}) );
    end
    
    sa = struct([]);
    for i = 1:nargin
        s = varargin{i};
        f = setdiff( allfields, fieldnames(s) );
        for j=1:length(f)
            s.(f{j}) = [];
        end
        sa = [sa s];
    end
end
