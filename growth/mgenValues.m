function [data,mgenIndexes] = mgenValues( m, mgens )
%mgenAmounts = mgenAmount( m, mgens )
%   Get the morphogen values for the specified morphogens.
%   Non-existent morphogens will be reported as NaN.

    mgenIndexes = FindMorphogenIndex2( m, mgens );
    mgenIndexMap = mgenIndexes ~= 0;
    validMgenIndexes = mgenIndexes(mgenIndexMap);
    data = nan( getNumberOfVertexes( m ), length(mgenIndexes) );
    data( :, mgenIndexMap ) = m.morphogens( :, validMgenIndexes );
end
