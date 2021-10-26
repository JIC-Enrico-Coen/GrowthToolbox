function datastruct = mgenValuesStruct( m, mgens )
%mdatastruct = mgenValuesStruct( m, mgens )
%   Get the morphogen values for the specified morphogens, returning the
%   result as a struct whose field names are the morphogen names.
%   Non-existent morphogens will be omitted.

    [data,mgenIndexes] = mgenValues( m, mgens );
    
    for i=1:length(mgenIndexes)
        if mgenIndexes(i) > 0
            mgenname = m.mgenIndexToName{mgenIndexes(i)};
            datastruct.(mgenname) = data( :, i );
        end
    end
end
