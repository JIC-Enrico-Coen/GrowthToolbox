function centroid = mgenCentroid( m, v, method )
%c = mgenCentroid( m, v )
%   If v is a density function defined at the vertexes of the mesh m, find
%   the centroid of its distribution.
%
%   v may also be the name of a morphogen.
%
%   If v is everywhere zero, this returns NaN.

    if (nargin < 3) || Isempty(method)
        method = 'mid';
    end

    if ischar(v)
        mgenname = v;
        mgenindex = FindMorphogenIndex2( m, mgenname );
        if mgenindex==0
            centroid = nan(1,3);
            return;
        end
        v = m.morphogens(:,mgenindex);
    end
    vPerFE = perVertextoperFE( m, v, method );
    weights = vPerFE .* m.FEsets.fevolumes;
    if isVolumetricMesh( m )
        c = centroids( m.FEnodes, m.FEsets(1).fevxs );
    else
        c = centroids( m.nodes, m.tricellvxs );
    end
    
    centroid = sum( c .* weights, 1 )/sum(weights);
end
