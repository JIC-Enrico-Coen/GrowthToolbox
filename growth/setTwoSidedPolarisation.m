function m = setTwoSidedPolarisation( m, twosidedpolarisation )
% Set the single or double-sided nature of the polarisation.
% If m.globalProps.twosidedpolarisation already has the specified value,
% the other fields will be forced to be consistent with it.

    full3d = usesNewFEs( m );
    if full3d
        % Volumetric meshes do not have two-sided polarisation.
        return;
    end
    
    m.globalProps.twosidedpolarisation = twosidedpolarisation;
    if twosidedpolarisation
        if size( m.gradpolgrowth, 3 )==1
            m.gradpolgrowth = repmat( m.gradpolgrowth, 1, 1, 2 );
        end
        if size( m.polfrozen, 2 )==1
            m.polfrozen = repmat( m.polfrozen(:,1), 1, 2 );
        end
        if size( m.polsetfrozen, 2 )==1
            m.polsetfrozen = repmat( m.polsetfrozen(:,1), 1, 2 );
        end
        if size( m.polfreeze, 3 )==1
            m.polfreeze = repmat( m.polfreeze, 1, 1, 2 );
        end
        if size( m.polfreezebc, 3 )==1
            m.polfreezebc = repmat( m.polfreezebc, 1, 1, 2 );
        end
    else
        if size( m.gradpolgrowth, 3 ) > 1
            m.gradpolgrowth = sum( m.gradpolgrowth, 3 )/size( m.gradpolgrowth, 3 );
        end
        if size( m.polfrozen, 2 ) > 1
            m.polfrozen = any( m.polfrozen, 2 );
        end
        if size( m.polsetfrozen, 2 ) > 1
            m.polsetfrozen = any( m.polsetfrozen, 2 );
        end
        if size( m.polfreeze, 3 ) > 1
            m.polfreeze = sum( m.polfreeze, 3 )/size( m.polfreeze, 3 );
        end
        if size( m.polfreezebc, 3 ) > 1
            m.polfreezebc = sum( m.polfreezebc, 3 )/size( m.polfreezebc, 3 );
        end
    end
end
