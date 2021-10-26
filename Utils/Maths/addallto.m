function v = addallto( v, vi, vv )
%v = addall( v, vi, vv )
%   V is a vector.  VI is a vector of indexes into V.  VV is a vector the
%   same length as VI.  For each element of VI and VV, add the value in VV
%   to the VI'th member of V.
%   This cannot be programmed as v(vi) = v(vi) + vv, because an index may occur
%   in VI multiple times.
%   If the input value of V is empty, it defaults to a zero vector whose
%   length is the maximum element of VI.

    if isempty(vi)
        return;
    end
    if isempty(v)
        v = zeros(1,max(vi));
    end
    for i=1:length(vi)
        vii = vi(i);
        v(vii) = v(vii) + vv(i);
    end
end

    
