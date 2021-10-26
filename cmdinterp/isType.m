function ok = isType( x, type )
%ok = isType( x, type )
%   Determine whether X has type TYPE.  TYPE can be a string or a cell
%   array of strings.  In the latter case, the result is true if X has a
%   type contained in the cell array.

    if iscell(type)
        for i=1:length(type)
            ok = isa(x,type{i});
            if ok, return; end
        end
        ok = false;
    else
        ok = isa(x,type);
    end
end
