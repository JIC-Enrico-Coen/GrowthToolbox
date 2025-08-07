function m = setMorphogen( m, mgens, values )
    mgenIndexes = FindMorphogenIndex2( m, mgens );
    validMgens = mgenIndexes ~= 0;
    mgenIndexes = mgenIndexes(validMgens);
    values = values( :, validMgens );
    if size(values,1)==getNumberOfFEs(m)
        newvalues = zeros( getNumberOfVertexes(m), size(values,2) );
        for mi=1:length(mgenIndexes)
            newvalues(:,mi) = FEToFEvertex( m, values(:,mi), m.mgen_interpType{mgenIndexes(mi)} );
        end
        values = newvalues;
    end
    m.morphogens( :, mgenIndexes ) = values;
end