function [lensq,len] = veclen(v)
%[lensq,len] = veclen(v)
%   Euclidean length and squared length of a vector.

    lensq = dotproc2(v,v);
    if nargout > 1
        len = sqrt(lensq);
    end
end

