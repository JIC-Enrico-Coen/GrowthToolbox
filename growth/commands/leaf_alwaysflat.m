function m = leaf_alwaysflat( m, flat )
%m = leaf_alwaysflat( m, flat )
%   If FLAT is true, force the mesh to never bend out of the XY plane.  The
%   mesh will be flattened if it is not already flat, by setting the Z
%   coordinate of every node to zero.
%   If FLAT is false, allow the mesh to bend out of the XY plane.  If the
%   mesh happens to be flat, it will not actually bend unless it is
%   perturbed out of the XY plane, e.g. by adding a random Z displacement
%   with the leaf_perturbz command.
%
%   A flat mesh is still allowed to vary in thickness.
%
%   Example:
%       m = leaf_alwaysflat( m, true );
%
%   Equivalent GUI operation: clicking the "Always flat" checkbox on the
%   "Mesh editor" panel.
%
%   When leaf_alwaysflat turns off flatness, it also turns off twoD.
%
%   Topics: Mesh editing, Simulation.
%
%   See also: leaf_twoD.

    if isempty(m), return; end
    if isVolumetricMesh( m )
        return;
    end
    m.globalProps.alwaysFlat = flat ~= 0;
    if isempty( m.globalInternalProps.flataxes )
        m.globalInternalProps.flataxes = getFlatAxes( m );
    end
    if m.globalProps.alwaysFlat
        m = flattenMesh( m, false );
    else
        m.globalProps.twoD = false;
    end
    saveStaticPart( m );
end
