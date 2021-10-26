function es = edgesense( m )
%es = edgesense( m )
%   Calculate an orientation for every edge of m.
%
%   The orientation is chosen to agree with that of the first of the
%   possibly two elements it belongs to. The result is an N*1 array of
%   booleans, one for each edge.
%
%   For foliate meshes only. Volumetric mehes return an empty array.

    if isVolumetricMesh(m)
        es = [];
    else
        ec1 = m.edgecells(:,1);
        ecvxs = m.tricellvxs(ec1,:);
        es = ((m.edgeends(:,1)==ecvxs(:,1)) & (m.edgeends(:,2)==ecvxs(:,2))) ...
             | ((m.edgeends(:,1)==ecvxs(:,2)) & (m.edgeends(:,2)==ecvxs(:,3))) ...
             | ((m.edgeends(:,1)==ecvxs(:,3)) & (m.edgeends(:,2)==ecvxs(:,1)));
    end
end
