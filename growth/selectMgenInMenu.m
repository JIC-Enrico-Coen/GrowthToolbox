function selectMgenInMenu( h, mgen )
    if isempty( h.mesh )
        set( h.displayedGrowthMenu, 'Value', 1 );
    else
        mgenIndex = FindMorphogenIndex( h.mesh, mgen, '' );
        if isempty(mgenIndex)
            set( h.displayedGrowthMenu, 'Value', 1 );
        else
            mgenMenuIndexes = get( h.displayedGrowthMenu, 'UserData' );
            mgenMenuIndex = mgenMenuIndexes.(h.mesh.mgenIndexToName{mgenIndex});
            set( h.displayedGrowthMenu, 'Value', mgenMenuIndex );
        end
    end
end
