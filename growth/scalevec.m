function v = scalevec( v, newmin, newmax )
%v = scalevec( v, newmin, newmax )
%   Scale the entries of the vector so they span the range between
%   min and max.  If all the entries are equal, they are all set to
%   min.
%
%   v can be an array of arbitrary shape. The result will have the same
%   shape.

    oldmin = min(v(:));
    oldmax = max(v(:));
    if (oldmin >= oldmax)
        v(:) = newmin;
    else
        v = (v - oldmin)*((newmax-newmin)/(oldmax-oldmin)) + newmin;
    end
end
