function ok = plotToVRML( ax, filename )
%ok = plotToVRML( ax, filename )
%   Write to a VRML file whatever is currently plotted.
    
    ok = false;
    if ~ishghandle( ax )
        fprintf( 1, '%s: Invalid axes handle.\n', mfilename() );
        return;
    end
    
    axc = get( ax, 'Children' );
    fprintf( 1, '%s: %d children found.\n', mfilename(), length(axc) );
    
    % Open the output file.
    fid = fopen( filename, 'w' );
    if fid==-1
        fprintf( 1, '%s: Cannot open file %d for writing.\n', mfilename(), filename );
        return;
    end
    
    cameraparams = getCameraParams( theaxes );
    [~,centre] = getAxesBbox( ax );

    writeVRMLpreamble( fid );
    writeVRMLViewpoints( fid, cameraparams, 1, centre )
    
    for i=1:length(axc)
        c = axc(i);
        ctype = get( c, 'Type' );
        fprintf( 1, 'Child %d has type %s\n', i, ctype );
        switch ctype
            case 'Patch'
                writePatchToVRML( fid, c );
            case 'Line'
                writeLineToVRML( fid, c );
            case 'Surface'
                writeSurfaceToVRML( fid, c );
        end
    end
    
    fclose( fid );
    
    ok = true;
end

function writePatchToVRML( fid, p )
    % Write the polygons only.
    % Don't assume solidity (but could be checked).
    
    % The raw patch properties are:
%         FaceColor: 'interp'
%         FaceAlpha: 0.8000
%         EdgeColor: [0 0 0]
%         LineStyle: 'none'
%             Faces: [144x4 double]
%          Vertices: [288x3 double]

    openShape( m.plotdata.pervertex, thecolor, creaseAngle );
end

function writeLineToVRML( fid, lines, thickness )
    % Write the lines as cylinders of some thickness.
    % Don't assume solidity (but could be checked).
    
    % The raw line properties are:
%               Color: [0.2000 0.2000 0.2000]
%           LineStyle: '-'
%           LineWidth: 2
%              Marker: 'none'
%          MarkerSize: 6
%     MarkerFaceColor: 'none'
%               XData: [1x6912 double]
%               YData: [1x6912 double]
%               ZData: [1x6912 double]

% NaN divides separate lines
% ZData is empty for a 2D plot.

    x = lines.XData;
    y = lines.YData;
    z = lines.ZData;
    datalength = max( [ length(x) length(y) length(y) ] );
    if length(x) < datalength
        x(datalength) = 0;
    end
    if length(y) < datalength
        y(datalength) = 0;
    end
    if length(z) < datalength
        z(datalength) = 0;
    end
    nans = isnan(x) | isnan(y) | isnan(z);
    x(nans) = NaN;
    y(nans) = NaN;
    z(nans) = NaN;
    pairstarts = ~isnan(x(1:(end-1)) & ~isnan(x(2:end));
    xyz = [ x(:) y(:) z(:) ];
    linestarts = xyz(pairstarts,:);
    lineends = xyz(pairstarts+1,:);
    
    writeVRMLCylinderFromTo( fid, linestarts(i,:), lineends(i,:), thickness );
end

function writeVRMLCylinderFromTo( fid, from, to, thickness )
end

function writeVRMLCylinder( fid, radius, height, side, bottom, top, transform )
% Cylinder {
%     radius 1.0
%     height 2.0
%     side TRUE
%     bottom TRUE
%     top TRUE
% }
    if ~isempty( transform )
        % Open a transform node.
    end
    
    % Write a cylinder.
    
    if ~isempty( transform )
        % Close the transform node
    end
end

function writeSurfaceToVRML( fid, lines )
    % Should be very similar to writing a patch.
    % Don't assume solidity (but can be checked more easily than a general
    % patch).
    
    % The raw surface properties are:
%        EdgeColor: [0 0 0]
%        LineStyle: '-'
%        FaceColor: 'flat'
%     FaceLighting: 'flat'
%        FaceAlpha: 1
%            XData: [21x21 double]
%            YData: [21x21 double]
%            ZData: [21x21 double]
%            CData: [21x21 double]

end
