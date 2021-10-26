function [m,ok] = makeDeepField( m, v, varargin )
%[m,ok] = makeDeepField( m, v, fieldname1, fieldname2, ... )
%   This sets a deep field of m to the value v.  See getDeepField for how
%   the fieldnames are supplied.
%
%   If the specified field path does not exist, it is created. This is the
%   only difference from setDeepField, which does not create any field that
%   does not exist.
%
%   If part of the specified path does exist, but ends with a non-empry,
%   non-struct value, then m is unchanged and ok is false.
%
%   See also: getDeepField, setDeepField

    if length(varargin)==1
        varargin = splitString( '\.', varargin{1} );
    end
    [m,ok] = makeDeepField1( m, v, varargin );
end

function [m,ok] = makeDeepField1( m, v, fns )
    if isempty(fns)
        m = v;
        ok = true;
    elseif ~isempty(m) && ~isstruct(m)
        ok = false;
    else
        if ~isfield( m, fns{1} )
            m.(fns{1}) = [];
        end
        if isempty( m.(fns{1}) ) || isstruct( m.(fns{1}) )
            [m.(fns{1}),ok] = makeDeepField1( m.(fns{1}), v, fns(2:end) );
        else
            ok = false;
        end
    end
end

