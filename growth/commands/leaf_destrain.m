function m = leaf_destrain( m )
%m = leaf_destrain( m )
%   Remove all residual strain from the mesh.
%
%   Equivalent GUI operation: clicking the "De-strain" button on the
%   "Simulation" panel.
%
%   Topics: Simulation.

    if isempty(m), return; end
    m = meshZeroStrain( m );
end
