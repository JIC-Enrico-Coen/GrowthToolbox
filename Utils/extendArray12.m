function a = extendArray12( a, sz, v )
%a = extendArray12( a, sz, v )
%   Extend the array A to the given size SZ (a two-element array) in its
%   first two dimensions by padding it with value V.
%   If A is longer than SZ along either dimension it will be truncated.

    if prod(sz)==0
        a = reshape( [], sz );
    else
        sza = size(a);
        if sza(1) > sz(1)
            sza(1) = sz(1);
            a = reshape( a(1:sz(1),:), sza );
        elseif sza(1) < sz(1)
            a((end+1):sz(1),:) = v;
        end
        if sza(2) > sz(2)
            sza(2) = sz(2);
            a = reshape( a(:,1:sz(2),:), sza );
        elseif sza(2) < sz(2)
            a(:,(end+1):sz(2),:) = v;
        end
    end
end