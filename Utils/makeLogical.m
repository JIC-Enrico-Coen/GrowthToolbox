function x = makeLogical( v )
%x = makeLogical( v )
%
%   Return the logical value that v, whatever it is, behaves as.
%
%   If using v where a logical value is expected would throw an error, so
%   will this.

    if v
        x = true;
    else
        x = false;
    end
end
