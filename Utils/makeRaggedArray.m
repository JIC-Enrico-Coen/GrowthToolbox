function raggedarray = makeRaggedArray( cellarray )
%raggedarray = makeRaggedArray( cellarray )
%   cellarray is an cell array of vectors of possibly different lengths.
%   The result is an N*K array where N is the length of cellarray and K the
%   maximum length of any vector.  Unused elements in each row are
%   represented by trailing NaNs.

    calength = length(cellarray);
    maxlen = 0;
    for i=1:calength
        maxlen = max( maxlen, length(cellarray{i}) );
    end
    raggedarray = nan( calength, maxlen );
    for i=1:calength
        raggedarray( i, 1:length(cellarray{i}) ) = cellarray{i};
    end
end
