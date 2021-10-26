function a = extendArray1( a, len, v )
%a = extendArray1( a, len, v )
%   Extend the array A to the given length LEN in its first dimension by
%   padding it with value V.
%   If A is longer than LEN along that dimension it will be truncated.

    sza = size(a);
    if sza(1) > len
        sza(1) = len;
        a = reshape( a(1:len,:), sza );
    elseif sza(1) < len
        a((end+1):len,:) = v;
    end
end