function [m,ok] = setDeepField( m, v, varargin )
%[m,ok] = setDeepField( m, v, fieldname1, fieldname2, ... )
%   This sets a deep field of m to the value v.  See getDeepField for how
%   the fieldnames are supplied.
%
%   If the specified field path does not exist, ok is returned as false.
%   This is the  only difference from makeDeepField, which does creates any
%   field that does not exist.
%
%   See also: getDeepField, makeDeepField

    if length(varargin)==1
        varargin = splitString( '\.', varargin{1} );
    end
    [m,ok] = setDeepField1( m, v, varargin );
end

function [m,ok] = setDeepField1( m, v, fns )
    if isempty(fns)
        m = v;
        ok = true;
    elseif isfield( m, fns{1} )
        [m1,ok] = setDeepField1( m.(fns{1}), v, fns(2:end) );
        if ok
            m.(fns{1}) = m1;
        end
    else
        ok = false;
    end
end

