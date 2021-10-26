function a = extendArray2( a, len, v )
%a = extendArray1( a, len, v )
%   Extend the array A to the given length LEN in its second dimension by
%   padding it with value V.
%   If A is longer than LEN along that dimension it will be truncated.

    sza = size(a);
    if sza(2) > len
        sza(2) = len;
        a = reshape( a(:,1:len,:), sza );
    elseif sza(2) < len
        a(:,(end+1):len,:) = v;
    end
end