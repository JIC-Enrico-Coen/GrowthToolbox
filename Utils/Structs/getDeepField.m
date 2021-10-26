function [v,ok] = getDeepField( v, varargin )
%[v,ok] = getDeepField( v, fieldname1, fieldname2, ... )
%   Return v.(fieldname1).(fieldname2)...
%   The fieldnames can also be supplied as a single argument with dots
%   separating the names:  v = getDeepField( v, 'abc.def.gh' ).  This does
%   the same as v = getDeepField( v, 'abc', 'def', 'gh' ).
%
%   If the specified field path does not exist, ok is returned as false and
%   v is empty.
%
%   See also: setDeepField, makeDeepField

    if isempty(varargin)
        ok = true;
        return;
    end
    if length(varargin)==1
        if iscell(varargin{1})
            varargin = varargin{1};
        else
            varargin = splitString( '\.', varargin{1} );
        end
    end
    for i=1:length(varargin)
        fn = varargin{i};
        if isfield( v, fn )
            v = v.(fn);
        else
            ok = false;
            v = [];
            return;
        end
    end
    ok = true;
end
