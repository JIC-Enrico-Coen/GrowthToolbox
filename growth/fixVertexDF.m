function handles = fixVertexDF( handles, vxs, x, y, z )
%handles = fixVertexDF( handles, vxs, x, y, z )
%   Fix or unfix the degrees of freedom of a vertex.

    output = handles.output;
    handles = updateSelection( handles, [], [], vxs, 'tog' );
    isSel = ismember( vxs, handles.mesh.selection.highlightedVxList );
    vxsIn = vxs( isSel );
    vxsOut = vxs( ~isSel );
    if ~isempty( vxsIn )
        dfs = '';
        if x
            dfs = [ dfs 'x' ];
        end
        if y
            dfs = [ dfs 'y' ];
        end
        if z
            dfs = [ dfs 'z' ];
        end
        attemptCommand( handles, false, false, ...
            'fix_vertex', ...
            'vertex', vxsIn, 'dfs', dfs );
        handles = guidata( output );
    end
    if ~isempty( vxsOut )
        attemptCommand( handles, false, false, ...
            'fix_vertex', ...
            'vertex', vxsOut, 'dfs', '' );
        handles = guidata( output );
    end
end
