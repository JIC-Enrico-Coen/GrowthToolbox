function paramValues = getModelOptionsModifiedByMorphogens( m, varargin )
%paramValues = getOptionsModifiedByMorphogens( m, paramname1, paramname2, ... )
%
%   This is like getModelOptions, but where the value of an option is a
%   string, and that string is the name of a morphogen, the values of that
%   morphogen for all vertexes are returned.

    [paramValues,alloptions] = getModelOptions( m, varargin{:} );
    
    fns = fieldnames(paramValues);
    for fi=1:length(fns)
        fn = fns{fi};
        if ~ischar( paramValues.(fn) )
            continue;
        end
        
        mi = FindMorphogenIndex2( m, paramValues.(fn) );
        if mi==0
            continue;
        end
        
        paramValues.(fn) = m.morphogens( :, mi );
    end
end
