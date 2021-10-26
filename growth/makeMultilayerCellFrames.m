function m = makeMultilayerCellFrames( m )
%m = makeMultilayerCellFrames( m )
%   For a multilayer mesh, calculate the frames of reference defined by the
%   polarising morphogens at every quadrature point of every FE.
%   The polarising morphogens are POLARISER and a fictitious morphogen
%   which is equal to i on the i'th layer of vertexes.  Its gradient on
%   each FE is the sum of the gradients of the shape functions for the top
%   vertexes, or equivalently, the gradient of the sum.  For the first-order
%   pentahedron and box elements, this is the gradient of the z
%   isoparametric coordinate.

    m = calcAllInterpolationData( m );
    
end

function m = calcAllInterpolationData( m )
    for fesi=1:length( m.FEsets )
        numfes = size( m.FEsets(fesi).fevxs, 1 );
        numvxs = size(m.FEsets(fesi).fe.canonicalVertexes,1);
        numdims = m.FEsets(fesi).fe.numdims;
        numquadpts = size(m.FEsets(fesi).fe.quadraturePoints,1);
        isograd = zeros( numdims, ... % Is this correct for 2D-in-3D elements?
                         numdims, ...
                         numquadpts, ...
                         numfes );
        gradNeuc = zeros( numvxs, ...
                          numdims, ...
                          numquadpts, ...
                          numfes );
        weightedJacobian = zeros( numquadpts, numfes );
        for i=1:numfes
            [isograd(:,:,:,i),gradNeuc(:,:,:,i),weightedJacobian(:,i)] = interpolationData( m.FEsets(fesi).fe, ...
                m.FEnodes( m.FEsets(fesi).fevxs(i,:), : ) );
        end
        m.FEsets(fesi).isograd = isograd;
        m.FEsets(fesi).gradNeuc = gradNeuc;
        m.FEsets(fesi).weightedJacobian = weightedJacobian;
    end
end
