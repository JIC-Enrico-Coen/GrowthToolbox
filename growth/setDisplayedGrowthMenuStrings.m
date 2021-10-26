function setDisplayedGrowthMenuStrings( h )
    if isempty( h.mesh )
        set( h.displayedGrowthMenu, 'String', {''} );
        set( h.displayedGrowthMenu, 'Value', 1 );
        set( h.displayedGrowthMenu, 'UserData', [] );
    else
        % We want to display all of the reserved morphogens first, in the
        % order that they are listed in the role list, followed by the
        % other morphogens in alphabetical order.
        % If a morphogen is assigned multiple roles, it will appear
        % according to the position of the first of those roles in the
        % list.
        roleNames = fieldnames( h.mesh.roleNameToMgenIndex )';
        roleIndexes = FindMorphogenRole( h.mesh, roleNames );
        [roleIndexes,~,~] = unique( roleIndexes, 'stable' );
        roleMgenNames = cell(1,length(roleIndexes));
        for i=1:length(roleIndexes)
            roleMgenNames{i} = h.mesh.mgenIndexToName{ roleIndexes(i) };
        end
        otherMgenIndexes = 1:size(h.mesh.morphogens,2);
        otherMgenIndexes(roleIndexes) = [];
        otherMgenNames = h.mesh.mgenIndexToName(otherMgenIndexes);
        otherMgenNames = sort( otherMgenNames );
        mgenNames = [ roleMgenNames otherMgenNames ];
        
        for i=1:length(mgenNames)
            menuIndexes.(mgenNames{i}) = i;
        end
        for i=1:length(roleIndexes)
            mgenNames{i} = [ '* ' mgenNames{i} ];
        end
        set( h.displayedGrowthMenu, 'UserData', menuIndexes );
        
        set( h.displayedGrowthMenu, 'String', mgenNames );
        currentMgen = FindMorphogenIndex( h.mesh, h.mesh.globalProps.displayedGrowth, '' );
        if isempty(currentMgen) || (currentMgen(1) < 1) || (currentMgen(1) > length(get(h.displayedGrowthMenu, 'String')))
            h.mesh.plotdefaults.morphogen = 1;
        end
    end
end
