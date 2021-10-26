function m = leaf_flatstrain( m )
%m = leaf_flatstrain( m )
%   Set the residual strains in the mesh to what they would be if the whole
%   mesh were flat.
%
%   Arguments: none.
%
%   Options: none.
%
%   Equivalent GUI operation: clicking the "Flat strain" button in the
%   "Simulation" panel.
%
%   Topics: Simulation.

    if isempty(m), return; end
    m = meshFlatStrain( m );
end
