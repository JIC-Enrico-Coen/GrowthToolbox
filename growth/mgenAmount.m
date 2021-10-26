function mgenAmounts = mgenAmount( m, mgens, mgeninterp )
%mgenAmounts = mgenAmount( m, mgens )
%   Calculate the total quantity of each of a given set of morphogens.
%   Non-existent morphogens will be reported as zero.
%   For a morphogen that takes only the values 1 and 0, this in effect
%   calculates the volume occupied by that morphogen.
%
%   MGENS can instead be an N*K matrix, where N is the number of vertexes
%   of the mesh. It will return the amounts as if these were morphogens.

    haveRawData = isnumeric( mgens ) && (size(mgens,1)==getNumberOfVertexes( m ));
    if haveRawData
        data = mgens;
        defaultmgeninterp = 'mid';
    else
        mgenIndexes = FindMorphogenIndex2( m, mgens );
        mgenIndexMap = mgenIndexes ~= 0;
        validMgenIndexes = mgenIndexes(mgenIndexMap);
        data = m.morphogens( :, validMgenIndexes );
        defaultmgeninterp = m.mgen_interpType( validMgenIndexes );
    end
    if ~exist( 'mgeninterp', 'var' )
        mgeninterp = defaultmgeninterp;
    end
    if ischar( mgeninterp )
        mgeninterp = { mgeninterp };
    end
    numvalidmgens = size( data, 2 );
    if (length(mgeninterp)==1) && (numvalidmgens > 1)
        mgeninterp = repmat( mgeninterp, 1, numvalidmgens );
    end

%     mgenAmounts = zeros( 1, numvalidmgens );
%     mgenAmounts4= zeros( 1, numvalidmgens );
    
    if usesNewFEs(m)
        if length(m.FEsets(1).fevolumes) ~= size( m.FEsets(1).fevxs, 1 )
            m = calcFEvolumes( m );
        end
        
        vxsPerFE = size( m.FEsets.fevxs, 2 );
        midmgens = strcmp( mgeninterp, 'mid' );
        minmgens = strcmp( mgeninterp, 'min' );
        maxmgens = strcmp( mgeninterp, 'max' );
        
        mgenAmounts4 = zeros( 1, numvalidmgens );
        if any(midmgens)
            midmgenperFE = mean( reshape( data( m.FEsets.fevxs', midmgens ), vxsPerFE, [], sum(midmgens) ), 1 );
            mgenAmounts4(midmgens) = (midmgenperFE * m.FEsets(1).fevolumes)';
        end
        if any(minmgens)
            minmgenperFE = min( reshape( data( m.FEsets.fevxs', minmgens ), vxsPerFE, [], sum(minmgens) ), [], 1 );
            mgenAmounts4(minmgens) = (minmgenperFE * m.FEsets(1).fevolumes)';
        end
        if any(maxmgens)
            maxmgenperFE = max( reshape( data( m.FEsets.fevxs', maxmgens ), vxsPerFE, [], sum(maxmgens) ), [], 1 );
            mgenAmounts4(maxmgens) = (maxmgenperFE * m.FEsets(1).fevolumes)';
        end

%         switch mgeninterp{1}
%             case 'min'
%                 mgenAmounts = mgenAmounts + dot( min( data( m.FEsets.fevxs ), [], 2 ), m.FEsets.fevolumes );
%             case 'max'
%                 mgenAmounts = mgenAmounts + dot( max( data( m.FEsets.fevxs ), [], 2 ), m.FEsets.fevolumes );
%             otherwise
%                 mgenAmounts = mgenAmounts + dot( mean( data( m.FEsets.fevxs ), 2 ), m.FEsets.fevolumes );
%         end
        mgenAmounts = mgenAmounts4;
        xxxx = 1;
    else
        numFEs = getNumberOfFEs(m);
        mgenAmounts2 = zeros( getNumberOfVertexes(m), numvalidmgens );
        for fei=1:numFEs
            vxs = m.tricellvxs(fei,:);
            mgenAmounts2(vxs,:) = mgenAmounts2(vxs,:) + data( vxs, : ) * m.cellareas(fei);
        end
        mgenAmounts = sum(mgenAmounts2,1)/size( m.tricellvxs, 2 );
    end
    
    if ~haveRawData
        foo = zeros( 1, length(mgenIndexes) );
        foo( mgenIndexMap ) = mgenAmounts;
        mgenAmounts = foo;
    end
end
