function [ft,faceNormals] = faceTension( m )
%ft = faceTension( m )
%   Calculate the tension normal to each  face of m.
    [values,components,frames,selectedCpts] = getMeshTensorValues( m, 'residualgrowthrate', 'parallel', m.cellFrames );
    
    values = values .* m.cellbulkmodulus;
    
    % values is the tension or compression in each element.
    % It should correspond to the first column of frames.
    
    tensionDirections = permute( frames(:,selectedCpts,:), [1 3 2] )';
    % tensionDirections is an N*3 array of the tension direction in each
    % of the N elements.
    
    innerFaces = m.FEconnectivity.facefes(:,2) ~= 0;
    faceTensionsDir1 = tensionDirections( m.FEconnectivity.facefes(:,1), : );
    faceTensionsDir2 = zeros( getNumberOfFaces(m), 3 );
    faceTensionsDir2( innerFaces, : ) = tensionDirections( m.FEconnectivity.facefes(innerFaces,2), : );
    
    faceTensions1 = values( m.FEconnectivity.facefes(:,1), : );
    faceTensions2 = zeros( getNumberOfFaces(m), 1 );
    faceTensions2( innerFaces, : ) = values( m.FEconnectivity.facefes(innerFaces,2), : );
    
    aa = vecangle( faceTensionsDir1, faceTensionsDir2 );
    flip = aa > pi/2;
    faceTensionsDir2(flip,:) = -faceTensionsDir2(flip,:);
    
    faceTensionsDir = (faceTensionsDir1 + faceTensionsDir2)/2;
    faceTensions = (faceTensions1 + faceTensions2)/2;
    
    faceVec12 = m.FEnodes( m.FEconnectivity.faces(:,2), : ) - m.FEnodes( m.FEconnectivity.faces(:,1), : );
    faceVec13 = m.FEnodes( m.FEconnectivity.faces(:,3), : ) - m.FEnodes( m.FEconnectivity.faces(:,1), : );
    faceNormals = cross( faceVec12, faceVec13 );
%     faceNormals = faceNormals ./ sqrt( sum( faceNormals.^2, 2 ) );
%     faceNormals( isnan(faceNormals) ) = 0;
    
    tensionAngles = vecangle( faceTensionsDir, faceNormals );
    tensionCosAngles = cos( tensionAngles );
    
%     faceNormalLengths = sqrt( sum( faceNormals.^2, 2 ) ); % Twice the face areas.
%     unitFaceNormals = faceNormals ./ faceNormalLengths;
%     unitFaceNormals( isnan(unitFaceNormals) ) = 0;
%     normalFaceTensions = faceTensions .* tensionCosAngles;
    
    % The factor of cos(tensionAngles) is applied to get the normal
    % component of the tension.
    ft = faceTensions .* tensionCosAngles;
    
    % There is no tension at the surface.
    ft(~innerFaces) = 0;
    
    if nargout >= 2
        faceNormals = faceNormals ./ sqrt( sum( faceNormals.^2, 2 ) );
        faceNormals( isnan(faceNormals) ) = 0;
    end
end
