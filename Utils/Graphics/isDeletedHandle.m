function isdel = isDeletedHandle( h )
%isdel = isDeletedHandle( h )
%   Determine whether H is a deleted handle. This procedure returns TRUE if
%   so, and FALSE if H is anything else, whether a handle or not. If H is
%   an array of handles, deleted or otherwise, an array of booleans of the
%   same shape is returned. If H is an array of non-handles, FALSE is
%   returned.
%
%   Matlab provides no simple way of determining whether an arbitrary
%   object is a deleted handle. When h is a deleted handle, ishandle(h)
%   returns false, but when h is not a handle at all, not even a deleted
%   one, isvalid(h) throws an exception.

    try
        isdel = ~isvalid( h );
    catch e %#ok<NASGU>
        isdel = false;
    end
end
