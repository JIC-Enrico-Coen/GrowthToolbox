function [name,lineno] = callerName( offset )
%[name,lineno] = callerName()
%   Find the name of the function the current function (the one that called
%   this one) was called from, and the line number.
%
%   If it (or this function) was called from the command line, NAME is empty
%   and LINENO is 0.
%
%[name,lineno] = callerName( offset )
%   If OFFSET is 1, this is the same as [name,lineno] = callerName().
%   If OFFSET is 0, this returns the name and line number in the function
%   that called this one.
%   If OFFSET > 1, then it will return the name and line number for the
%   function correspondingly many levels up the call stack.

    if nargin < 1
        offset = 1;
    end
    target = offset+2;
    st = dbstack();
    if (length(st) >= target) && (target >= 1)
        name = st(target).name;
        lineno = st(target).line;
    else
        name = '';
        lineno = 0;
    end
end
