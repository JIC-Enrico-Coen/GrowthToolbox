function mgenNVxs = mgenNumVxs( m, mgens, thresholds )
%mgenNumVxs = mgenAmount( m, mgens )
%   Calculate the number of vertexes at which each of a given set of
%   morphogens exceeds a threshold.
%   Non-existent morphogens will be reported as zero.
%
%   MGENS can instead be an N*K matrix, where N is the number of vertexes
%   of the mesh. It will return the amounts as if these were morphogens.

    haveRawData = (isnumeric( mgens ) || islogical( mgens )) && (size(mgens,1)==getNumberOfVertexes( m ));
    if haveRawData
        data = mgens;
    else
        mgenIndexes = FindMorphogenIndex2( m, mgens );
        mgenIndexMap = mgenIndexes ~= 0;
        validMgenIndexes = mgenIndexes(mgenIndexMap);
        data = m.morphogens( :, validMgenIndexes );
    end
    if ~exist( 'thresholds', 'var' ) || isempty( thresholds )
        thresholds = 0;
    end
    numvalidmgens = size( data, 2 );
    if (length(thresholds)==1) && (numvalidmgens > 1)
        thresholds = thresholds + zeros( 1, numvalidmgens );
    end
    
    mgenNVxs = sum( data > thresholds, 1 );
    
    if ~haveRawData
        foo = zeros( 1, length(mgenIndexes) );
        foo( mgenIndexMap ) = mgenNVxs;
        mgenNVxs = foo;
    end
end
