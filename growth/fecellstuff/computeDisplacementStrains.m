function [cell,vorticity] = computeDisplacementStrains( cell, displacements )
%cell = computeDisplacementStrains( cell, displacements )
%   Set cell.displacementStrain equal to the strain at each Gauss point
%   resulting from the given displacements of the vertexes.

    SMALL_ROTATIONS_ASSUMED = false;
    numGaussPoints = size(cell.gnGlobal,3);
    vorticity = repmat( eye(3), [1, 1, 6] );
    for i=1:numGaussPoints
        ui = cell.gnGlobal(:,:,i) * displacements;
        if SMALL_ROTATIONS_ASSUMED || (max(abs(ui(:))) < 1e-3)
            e = 0.5*(ui + ui');
            if nargout > 0
                vort = 0.5*(ui-ui');
                vorticity(:,:,i) = eye(3) + vort; % [ vort(2,1), vort(1,3), vort(3,2) ];
            end
        else
            t = eye(3) + ui;
            [q,err] = extractRotation( t, 1e-5 );
            e = t*q' - eye(3);
            if nargout > 0
                vorticity(:,:,i) = q;
            end
        end
        cell.displacementStrain(:,i) = make6vector( e );
    end
    cell.vorticity = vorticity;
end
