function handles = locateVertexDF( handles, vxs, x, y, z )
%handles = locateVertexDF( handles, vxs, x, y, z )
%   

    output = handles.output;
    handles = updateSelection( handles, [], [], vxs, 'replace' );
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
            'locate_vertex', ...
            'vertex', vxs, 'dfs', dfs );
    handles = guidata( output );
end
