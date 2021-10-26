function i = binsearchupper( vec, val )
%i = binsearchupper( vec, val )
%   Find that i such that vec(i-1) < val <= vec(i).
%
%   If val is less than or equal to the first element of vec, 1 is
%   returned. If it is greater than the last element, length(vec) is
%   returned.
%
%   val may be an array, in which case i will be an array of the
%   same shape.  i is always returned as a uint32 array.
%
%   The definition implies that when vec contains consecutive identical
%   values, only the first element of the run can ever be chosen.
%
%   This is correct for vec of length up to 1073741823 (2^30-1).
%
%   See also:
%       binsearchlower

    i = zeros(size(val),'uint32');
    for vi=1:numel(val)
        lo = uint32(1);
        hi = uint32(length(vec));
        while hi > lo
            mid = bitshift( lo+hi, -1 );
            if val(vi) <= vec(mid)
                hi = mid;
            else
                lo = mid+1;
            end
        end
        i(vi) = lo;
    end
end
