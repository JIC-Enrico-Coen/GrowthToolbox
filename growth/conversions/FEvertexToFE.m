function perFE = FEvertexToFE( m, perFEvertex, method )
%perFE = FEvertexToFE( m, perFEvertex, method )
%   Convert a value per FEvertex to a value per FE.
%   Since perFE is defined at different places than perFEvertex is,
%   there will necessarily be a certain amount of blurring involved.
%   perFEvertex can also be a morphogen index or a morphogen name, or a
%   list of these.  If none of the specified morphogens exist, the empty
%   array is returned.
%
%   method can be 'min', 'max', 'mid', 'ave', empty, or not supplied.  The
%   last four are synonymous.  This determines whether the value for the
%   FE is the minimum, the maximum, or the average of the values for
%   the vertexes of the FE.  The default is 'mid'.
%
%   perFEvertex can be a matrix of any shape whose first dimension is
%   the number of FEvertexes. perFE will be a matrix of corresponding
%   shape whose first dimension is the number of FEs.
%
%   This works for both foliate and volumetric meshes.

    if nargin < 3
        method = 'mid';
    end
    
    numFEvertex = getNumberOfVertexes( m );
    if (size(perFEvertex,1) ~= numFEvertex) || iscell(perFEvertex) || ischar(perFEvertex)
        mgens = FindMorphogenIndex( m, perFEvertex );
        perFEvertex = m.morphogens(:,mgens);
    end
    numFE = getNumberOfFEs( m );
    shapeFEvertex = size(perFEvertex);
    itemshape = shapeFEvertex(2:end);
    perFEvertex = reshape( perFEvertex, numFEvertex, [] );

    if isVolumetricMesh( m )
        perFE = perVertextoperPolygon( m.FEsets.fevxs, perFEvertex, method );
    else
        perFE = perVertextoperPolygon( m.tricellvxs, perFEvertex, method );
    end

    perFE = reshape( perFE, [numFE,itemshape] );
end
