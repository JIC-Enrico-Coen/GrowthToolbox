function m = leaf_twoD( m, twoD )
%m = leaf_2D( m, twoD )
%   If TWOD is true, force the mesh to never bend out of the XY plane and
%   never vary in thickness.  The mesh will be flattened if it is not
%   already flat, by setting the Z coordinate of every node to zero and
%   setting the thicknesss to be uniform.
%
%   If TWOD is false, allow the mesh to bend out of the XY plane.  If the
%   mesh happens to be flat, it will not actually bend unless it is
%   perturbed out of the XY plane, e.g. by adding a random Z displacement
%   with the leaf_perturbz command.
%
%   This differs from leaf_alwaysFlat, in that a mesh set flat by
%   leaf_alwaysFlat is still allowed to vary in thickness.
%
%   Example:
%       m = leaf_2D( m, true );
%
%   Equivalent GUI operation: clicking the "Always flat" checkbox on the
%   "Mesh editor" panel.
%
%   Topics: Mesh editing, Simulation.
%
%   See also: leaf_alwaysflat.

    if isempty(m), return; end
    if isVolumetricMesh( m )
        return;
    end
    m.globalProps.twoD = twoD ~= 0;
    if isempty( m.globalInternalProps.flataxes )
        m.globalInternalProps.flataxes = getFlatAxes( m );
    end
    if m.globalProps.twoD
        m = flattenMesh( m, true );
    end
    m.fixedDFmap(:,3) = true;
    saveStaticPart( m );
end
