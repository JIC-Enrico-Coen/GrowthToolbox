function [ft,unitFaceNormals,newFaceTensions] = faceTension( m )
%[ft,faceNormals,newFaceTensions] = faceTension( m )
%   Calculate the tension normal to each  face of m.
    [values,components,frames,selectedCpts] = getMeshTensorValues( m, 'residualstressrate', 'parallel', m.cellFrames );
    % values is the tension or compression in each element.
    % It should correspond to the first column of frames.
    
    numFaces = getNumberOfFaces(m);
    
    tensionDirections = permute( frames(:,selectedCpts,:), [1 3 2] )';
    % tensionDirections is an N*3 array of the tension direction in each
    % of the N elements.
    
    innerFacesMap = m.FEconnectivity.facefes(:,2) ~= 0;
    faceTensionsDir1 = tensionDirections( m.FEconnectivity.facefes(:,1), : );
    faceTensionsDir2 = zeros( numFaces, 3 );
    faceTensionsDir2( innerFacesMap, : ) = tensionDirections( m.FEconnectivity.facefes(innerFacesMap,2), : );
    
    faceTensions1 = values( m.FEconnectivity.facefes(:,1), : );
    faceTensions2 = zeros( numFaces, 1 );
    faceTensions2( innerFacesMap, : ) = values( m.FEconnectivity.facefes(innerFacesMap,2), : );
    
    aa = vecangle( faceTensionsDir1, faceTensionsDir2 );
    flip = aa > pi/2;
    faceTensionsDir2(flip,:) = -faceTensionsDir2(flip,:);
    
    faceTensionsDir = (faceTensionsDir1 + faceTensionsDir2)/2;
    faceTensions = (faceTensions1 + faceTensions2)/2;
    
    faceVec12 = m.FEnodes( m.FEconnectivity.faces(:,2), : ) - m.FEnodes( m.FEconnectivity.faces(:,1), : );
    faceVec13 = m.FEnodes( m.FEconnectivity.faces(:,3), : ) - m.FEnodes( m.FEconnectivity.faces(:,1), : );
    faceNormals = cross( faceVec12, faceVec13 );
    faceNormalLengths = sqrt(sum(faceNormals.^2,2));
    unitFaceNormals = faceNormals ./ faceNormalLengths;
    unitFaceNormals( isnan(unitFaceNormals) ) = 0;
    
%     ftUsingTotalTensor = faceNormals' * stressTensors * faceNormals;
    stressTensors = m.outputs.residualstrain .* m.cellbulkmodulus;
    interiorFaceIndexes = find( innerFacesMap );
    numInteriorFaces = sum( innerFacesMap );
    foo1 = stressTensors( m.FEconnectivity.facefes( innerFacesMap, : )', : );
    foo2 = reshape( foo1, 2, [], 6 );
    foo3 = shiftdim( mean( foo2, 1 ), 1 );
    stressMatrixPerInteriorFace = reshape( foo3( :, [1 6 5 6 2 4 5 4 3] )', 3, 3, numInteriorFaces );
    
    tic;
    newFaceTensionsOLD = zeros( numFaces, 1 );
    for fii=1:length(interiorFaceIndexes)
        fi = interiorFaceIndexes(fii);
        newFaceTensionsOLD(fi) = unitFaceNormals(fi,:) * stressMatrixPerInteriorFace(:,:,fii) * unitFaceNormals(fi,:)';
        xxxx = 1;
    end
    newFaceTensionsOLD(~innerFacesMap) = 0;
    toc;
    
    tic;
    foo4 = sum( permute( unitFaceNormals(innerFacesMap,:), [2 3 1] ) .* stressMatrixPerInteriorFace, 1 );
    foo5 = shiftdim( foo4, 1 );
    foo6 = dot( foo5', unitFaceNormals(innerFacesMap,:), 2 );
    newFaceTensions = zeros( numFaces, 1 );
    newFaceTensions(innerFacesMap) = foo6;
    toc;
    
    tensionerror = max(abs(newFaceTensions - newFaceTensionsOLD))

    tensionAngles = vecangle( faceTensionsDir, faceNormals );
    tensionCosAngles = cos( tensionAngles );
    tensionCosAnglesSq = tensionCosAngles.^2;
    
    % The factor of cos(tensionAngles)^2 is applied to get the normal
    % component of the tension.
    ft = faceTensions .* tensionCosAnglesSq;
    
    % There is no tension at the surface.
    ft(~innerFacesMap) = 0;
    newFaceTensions(~innerFacesMap) = 0;
    
%     figure;plot( ft, newFaceTensions-ft, '.' );
    xxxx = 1;
end
