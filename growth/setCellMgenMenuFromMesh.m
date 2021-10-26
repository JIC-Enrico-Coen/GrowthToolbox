function setCellMgenMenuFromMesh( h )
%setCellMgenMenuFromMesh( h )
%   h is either a mesh or the set of GUI handles for GFtbox.
%   Set the cellular morphogens menu strings and currently selected item
%   from the mesh.

    if isfield( h, 'displayedCellMgenMenu' )
        % h is the set of GFtbox GUI handles.
        % Note that isfield() is safe to call on anything, even
        % non-structs.
        m = h.mesh;
    elseif isinteractive( h )
        % h is a mesh.
        m = h;
        if isempty( m.pictures ) || ~ishandle(m.pictures(1)) 
            return;
        end
        h = guidata(m.pictures(1));
        if ~isfield( h, 'displayedCellMgenMenu' )
            return;
        end
    else
        % Either h is an inappropriate argument, or there is no GUI.  In
        % either case, do nothing.
        return;
    end
    factornames = ' ';
    currentMgenMenuIndex = 1;
    if ~isempty( m )
        [factornames,perm] = sort( m.secondlayer.valuedict.index2NameMap );
        if isempty(factornames)
            factornames = ' ';
        end
        currentMgenMenuIndex = menuIndexFromDictItem( m.secondlayer.valuedict, m.plotdefaults.cellbodyvalue, h.displayedCellMgenMenu );
    end
    setPeeredAttributes( h.displayedCellMgenMenu, 'String', factornames, 'Value', currentMgenMenuIndex(1) );
end
