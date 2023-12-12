function paramValue = getModelOptionModifiedByMorphogens( m, paramnane )
%paramValues = getOptionModifiedByMorphogens( m, paramname1, paramname2, ... )
%
%   This is like getModelOption, but where the value of an option is a
%   string, and that string is the name of a morphogen, the values of that
%   morphogen for all vertexes are returned.

    paramValue = getModelOption( m, paramnane );
    
    if ischar( paramValue )
        mi = FindMorphogenIndex2( m, paramValue );
        if mi > 0
            paramValue = m.morphogens( :, mi );
        end
    end
end
