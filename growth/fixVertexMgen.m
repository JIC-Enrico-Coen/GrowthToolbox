function handles = fixVertexMgen( handles, vi )
%handles = fixVertexMgen( handles, vi )
%   Fix or unfix a morphogen at a vertex.

    output = handles.output;
    handles = establishInteractionMode( handles, ...
        handles.mesh.globalProps.displayedGrowth );
    handles = updateSelection( handles, [], [], vi, 'tog' );
    attemptCommand( handles, false, false, ... % WARNING: Does not always need redraw.
        'fix_mgen', ...
        handles.mesh.globalProps.displayedGrowth, ...
        'vertex', vi, ...
        'fix', ismember( vi, handles.mesh.selection.highlightedVxList ) );
    handles = guidata( output );
end
