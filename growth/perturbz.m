function m = perturbz(m,z,absolute,smoothing)
%m = perturbz(m,z,absolute,smoothing)
%
%   Implementation of leaf_perturbz.
%
%   m is the mesh, z is the magnitude of the random perturbation, absolute
%   is a boolean, and smoothing is a non-negative integer.

    if z==0, return; end
    numnodes = getNumberOfVertexes(m);
    if isVolumetricMesh(m)
        perturbation = rand(numnodes,3)-0.5;
        perturbation = scalevec( perturbation, -z/2, z/2 );
        if ~absolute
            d = Inf;
            for i=1:length(m.FEsets)
                numFEs = size( m.FEsets(i).fevxs, 1 );
                for j=1:numFEs
                    xx = m.FEnodes( m.FEsets(i).fevxs(j,:), : );
                    d = min( d, min( max(xx,[],1) - min(xx,[],1) ) );
                end
            end
            perturbation = perturbation * d;
        end
        % NOT IMPLEMENTED: smoothing.
        m.FEnodes = m.FEnodes + perturbation;
    else
        numnodes = size(m.nodes,1);
        newz = rand(numnodes,1)-0.5;
        if smoothing > 0
            nbs = cell(numnodes,1);
            for j=1:numnodes
                nce = m.nodecelledges{j};
                eis = nce(:,1);
                vxs = m.edgeends(eis,:);
                nbs{j} = vxs(vxs~=j);
            end
            for i=1:smoothing
                newz1 = newz;
                for j=1:numnodes
                    newz1(j) = (newz1(j) + sum( newz1(nbs{j}) ))/(length(nbs{j})+1);
                end
                newz = newz1;
            end
        end
        newz = scalevec( newz, -z/2, z/2 );
        m = addToNormal( m, newz, absolute );
    end
    m.saved = 0;
end
