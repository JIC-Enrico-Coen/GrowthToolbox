function perFace = perVertextoperFace( m, perFEvertex, method, faces )
%perFace = perVertextoperFace( m, perFEvertex, method, faces )
%   Given a quantity that is defined for each vertex, calculate an
%   equivalent quantity per face.
%
%   The per-vertex quantity can be a vector.  If m has numVx vertexes and
%   numFEs finite elements, then perVx has size  [numVxs,K] for some K, and
%   perFE has size [numFEs,K]. 
%
%   Note that this is an approximation: some smoothing is unavoidable in
%   the calculation.  The function perFEtoperVertex translates the other
%   way, but these two functions are not inverses.  Converting back and
%   forth will have the side-effect of spreading out the distribution of
%   the quantity.

    if nargin < 3
        method = 'mid';
        wholemesh = true;
    elseif ~ischar(method)
        faces = method;
        method = 'mid';
        wholemesh = false;
    else
        wholemesh = true;
    end
    

    if isVolumetricMesh( m )
        if wholemesh
            faces = true( size(m.FEconnectivity.faces,1), 1 );
        end
        perFace = perVertextoperPolygon( m.FEconnectivity.faces, perFEvertex, method, faces );
    else
        if wholemesh
            faces = true( size(m.tricellvxs,1), 1 );
        end
        perFace = perVertextoperPolygon( m.tricellvxs, perFEvertex, method, faces );
    end
end

