function gradhandles = plotPolGrad( m, ...
              selcc, selfaces, selbc, selptsmid, selptsA, selptsB, ...
              sparsedistance, crosses, equalsize, scale, s, facecamera, maxsurfangle )
          
    gradhandles = [];
    if isempty(selcc)
        return;
    end
    if ~exist( 'facecamera', 'var' )
        facecamera = false;
    end
    
    full3d = isVolumetricMesh(m);
    [wantPol1Surface,wantPol1Volume] = getSurfaceVolumeFlags( s.drawgradients );
    wantPol1 = wantPol1Surface || wantPol1Volume;
    if full3d
        [wantPol2Surface,wantPol2Volume] = getSurfaceVolumeFlags( s.drawgradients2 );
        [wantPol3Surface,wantPol3Volume] = getSurfaceVolumeFlags( s.drawgradients3 );
    else
        wantPol2Surface = false;
        wantPol2Volume = false;
        wantPol3Surface = false;
        wantPol3Volume = false;
    end
    wantPol2 = wantPol2Surface || wantPol2Volume;
    wantPol3 = wantPol3Surface || wantPol3Volume;
    % If we are not plotting the gradients, return.
    if ~(wantPol1 || wantPol2 || wantPol3)
        return;
    end
    

    global gDefaultPlotOptions
    s = defaultFromStruct( s, gDefaultPlotOptions, ...
                           { 'arrowthickness', ...
                             'crossthickness', ...
                             'arrowheadsize', ...
                             'arrowheadratio', ...
                             'highgradcolor', ...
                             'lowgradcolor' } );
    
    handles = guidata( m.pictures(1) );
    theaxes = handles.picture;
    

                         
                         
    % Calculate the gradients for the selected FEs.
    % Store these in polgrads.
    % Observe which of these are zero and so are to be drawn as circles.
    % Observe which are frozen and so are to be drawn in a different
    % colour.
    
    if wantPol1 || wantPol3
        [majorvec1,minorvec1,selzero1] = calculateGradientPlotData( m.gradpolgrowth );
    else
        majorvec1 = [];
        minorvec1 = [];
        selzero1 = false(length(selcc),1);
    end
    if wantPol2 || wantPol3
        [majorvec2,minorvec2,selzero2] = calculateGradientPlotData( m.gradpolgrowth2 );
    else
        majorvec2 = [];
        minorvec2 = [];
        selzero2 = false(length(selcc),1);
    end
    if wantPol3
        thirdvec = cross( majorvec1, majorvec2, 2 );
        len1 = sqrt(sum(majorvec1.^2,2));
        len2 = sqrt(sum(majorvec2.^2,2));
        len3 = sqrt(sum(thirdvec.^2,2));
        scaling = sqrt(len1.*len2)./len3;
        thirdvec = thirdvec .* repmat( scaling, 1, 3 );
    else
        thirdvec = [];
    end
    
    % We should then have bitmaps of selcc:
    %   selzero, where circles are required.
    %   selfluid, where one colour is required.
    %   selfrozen, where the other colour is required.
    % Both circles and arrows can take either colour.
    % These may be drawn on the A side, the B side, or both.
    
    % We also need majorvec and minorvec.
    
    % Everything should also be masked to the visible cells by this point.
%     if size(m.polfrozen,2)==1
%         polfrozen = repmat( m.polfrozen(selcc,:), 1, 2 );
%     else
        polfrozen = m.polfrozen(selcc,:);
%     end
    
%     fluidcircles = selzero & ~polfrozen;
%     frozencircles = selzero & polfrozen;

    polfrozen2 = polfrozen; % m.polfrozen2 IS NOT IMPLEMENTED

    fluidarrows1 = (~selzero1) & ~polfrozen;
    frozenarrows1 = (~selzero1) & polfrozen;
    fluidarrows2 = (~selzero2) & ~polfrozen2;
    frozenarrows2 = (~selzero2) & polfrozen2;
    
    decoroffset = m.plotdefaults.gradientoffset * scale;
    
    gradhandles = [];
    if full3d
        if wantPol1
            hh = plotgradientarrowsindexed( 'pol1', frozenarrows1(:,1)+1, selptsmid, 1, [s.highgradcolor;s.lowgradcolor], majorvec1, minorvec1, true, facecamera, maxsurfangle, decoroffset );
            gradhandles = [ gradhandles, hh ];
        end
        if wantPol2
            hh = plotgradientarrowsindexed( 'pol2', frozenarrows2(:,1)+1, selptsmid, 1, [s.highgradcolor2;s.lowgradcolor2], majorvec2, minorvec2, true, facecamera, maxsurfangle, decoroffset );
            gradhandles = [ gradhandles, hh ];
        end
        if wantPol3
            hh = plotgradientarrowsindexed( 'pol3', frozenarrows2(:,1)+1, selptsmid, 1, [s.highgradcolor3;s.lowgradcolor3], thirdvec, [], false, facecamera, maxsurfangle, decoroffset );
            gradhandles = [ gradhandles, hh ];
        end
    else
        if wantPol1
            if any( s.sidegrad=='A' )
                hh = plotgradientarrowsindexed( 'pol1A', frozenarrows1(:,1)+1, selptsA, 1, [s.highgradcolor;s.lowgradcolor], majorvec1, minorvec1, true, facecamera, maxsurfangle, decoroffset );
                gradhandles = [ gradhandles, hh ];
            end

            if any( s.sidegrad=='B' )
                layer = min(size(fluidarrows1,2),2);
                hh = plotgradientarrowsindexed( 'pol1B', frozenarrows1(:,1)+1, selptsB, layer, [s.highgradcolor;s.lowgradcolor], majorvec1, minorvec1, true, facecamera, maxsurfangle, -decoroffset );
                gradhandles = [ gradhandles, hh ];
            end
        end
        if wantPol2
            if any( s.sidegrad=='A' )
                hh = plotgradientarrowsindexed( 'pol2A', frozenarrows2(:,1)+1, selptsA, 1, [s.highgradcolor2;s.lowgradcolor2], majorvec2, minorvec2, true, facecamera, maxsurfangle, decoroffset );
                gradhandles = [ gradhandles, hh ];
            end

            if any( s.sidegrad=='B' )
                layer = min(size(fluidarrows2,2),2);
                hh = plotgradientarrowsindexed( 'pol2B', frozenarrows1(:,1)+1, selptsB, layer, [s.highgradcolor2;s.lowgradcolor2], majorvec2, minorvec2, true, facecamera, maxsurfangle, -decoroffset );
                gradhandles = [ gradhandles, hh ];
            end
        end
    end

function hh = plotgradientarrowsindexed( tag, colorindexes, points, index, colors, majorvec, minorvec, arrows, faceCamera, maxsurfangle, decoroffset )
    if isempty(points)
        return;
    end
    if full3d
        if faceCamera
            cp = getCameraParams( m.pictures(1) );
            normals = cp.CameraTarget - cp.CameraPosition;
            normals = normals/norm(normals);
            normals = repmat( normals, size(points,1), 1 );
        else
            normals = trinormals( m.FEnodes, m.FEconnectivity.faces( selfaces, : ) );
            % Need to reverse the normals whenever the face is oriented
            % for an invisible FE.
            selfacefes = m.FEconnectivity.facefes( selfaces, : );
            visselfaces = selfacefes;
            visselfaces( selfacefes > 0 ) = m.visible.elements( visselfaces( visselfaces > 0 ) );
            visselfaces = visselfaces==1;
            check = all( sum(visselfaces,2) == 1 );
            selfacefe = selfacefes(:,1);
            selfacefe( visselfaces(:,2) ) = selfacefes( visselfaces(:,2), 2 );
            wrongnormals = (m.FEconnectivity.facefes( selfaces, 1 )==selfacefe) ~= m.FEconnectivity.facefeparity( selfaces );
            normals(wrongnormals,:) = -normals(wrongnormals,:);
            xxxx = 1;
        end
    else
        normals = m.unitcellnormals(selcc,:);
    end
    points = points + normals*decoroffset;
    if arrows
        arrowheadsize = s.arrowheadsize;
        arrowheadratio = s.arrowheadratio;
    else
        arrowheadsize = 0;
        arrowheadratio = 0;
    end
    majornormals = findPerpVector( majorvec, normals );
    if ~isinf(maxsurfangle)
        surfangle = vecangle( majornormals, normals );
        obtuse = surfangle > pi/2;
        surfangle(obtuse) = pi - surfangle(obtuse);
        surfangleok = surfangle < maxsurfangle;
        if crosses
            % Plot gradient transversals.
            minornormals = findPerpVector( minorvec, normals );
            surfangle = vecangle( majornormals, normals );
            obtuse = surfangle > pi/2;
            surfangle(obtuse) = pi - surfangle(obtuse);
            surfangleok = surfangleok & (surfangle < maxsurfangle);
        end
        if ~any(surfangleok)
            return;
        end
        majorvec = majorvec(surfangleok,:,:);
        if crosses
            minorvec = minorvec(surfangleok,:,:);
        end
        majornormals = majornormals(surfangleok,:,:);
        points = points(surfangleok,:,:);
    end

    FORE = 1;
    AFT = 1;
    selectedmajor = any( majorvec ~= 0, 2 );
    hh = myquiver3( ...
         points(selectedmajor,:), ...
         majorvec(selectedmajor,:), ...
         majornormals(selectedmajor,:), ...
         arrowheadsize, arrowheadratio, FORE, AFT, ...
         'LineStyle', '-', ...
         'Color', colors, ...
         'ColorIndex', colorindexes(selectedmajor,:), ...
         'LineWidth', s.arrowthickness, ...
         'Parent', theaxes );
         % 'LineSmoothing', 'on' );  % LineSmoothing is deprecated.
    taghandles( hh, tag, 3 );
    if crosses
        % Plot gradient transversals.
        minornormals = minornormals(surfangleok,:,:);
        selectedminor = any( majorvec ~= 0, 2 );
        hh2 = myquiver3( ...
             points(selectedminor,:), ...
             minorvec(selectedminor,:), ...
             minornormals(selectedminor,:), ...
             0, 0, FORE, AFT, ...
             'LineStyle', '-', ...
             'Color', colors, ...
             'ColorIndex', colorindexes(selectedminor,:), ...
             'LineWidth', s.arrowthickness, ...
             'Parent', theaxes );
         % 'LineSmoothing', 'on' );  % LineSmoothing is deprecated.
        taghandles( hh2, [tag 'trans'], 3 );
        hh = [ hh hh2 ];
    end
end

function [majorvec,minorvec,selzero] = calculateGradientPlotData( gradients )
% This is responsible for constructing:
%   majorvec
%   minorvec
%   selzero

    majorvec = [];
    minorvec = [];
    selzero = [];
    
    if isempty( m.cellFrames )
        m = makeCellFrames( m );
    end
    
    THRESHOLDING = false;
    quiverscale = scale*0.4;
    
    % Find the unit gradient vectors and the cells with zero or low gradients.
    AVERAGING = false;
    if AVERAGING
        numselcells = length(selcc);
        unitgrad = zeros( numselcells, 3, size(gradients,3) );
        for i=1:numselcells
            unitgrad(i,:,:) = avpolgrad( m, selcc(i), selptsmid(i,:), sparsedistance );
        end
    else
        unitgrad = gradients(selcc,:,:);
    end
    norms = sqrt( sum( gradients(selcc,:,:).^2, 2 ) );
    maxnorm = max(norms(:));
    nz = norms>0;
    % Normalise unitgrad.
    for i=1:size( unitgrad, 3 )
        unitgrad(nz(:,i),:,i) = unitgrad(nz(:,i),:,i) ./ repmat( norms(nz(:,i),:,i), 1, 3 );
    end
    if maxnorm > 0
        norms = norms/max(norms(:));
    end
%     if size(norms,2)==1
%         norms = repmat( norms, 1, 2 );
%     end
    if s.scalegradients
        unitgrad = unitgrad .* repmat( norms, 1, 3 );
    end
    selzero = squeeze(norms==0);
    if THRESHOLDING
        selzero = selzero | lowgrad;
    end

    if crosses
        % Find the unit vectors perpendicular to the gradients.
        crossgrad = cross( unitgrad(:,:,1), m.unitcellnormals(selcc,:), 2 );
        numlayers = size(unitgrad,3);
        for i=2:numlayers
            crossgrad(:,:,i) = cross( unitgrad(:,:,i), m.unitcellnormals(selcc,:), 2 );
        end
    end

    minorlength = [];
    if equalsize && ~crosses
        majorvec = unitgrad*quiverscale;
    else
        % Scale the vectors according to the magnitude of the
        % morphogen-specified growth.
        
        % First calculate the growth rates.
        ka_mgens = FindMorphogenRole( m, 'KAPAR', 'KAPER' );
        cellGrowthA = sum( ...
            reshape( getEffectiveMgenLevels( m, ka_mgens, m.tricellvxs(selcc,:)' ), ...
                3, [], 2 ), 1 ) / 3;
        kb_mgens = FindMorphogenRole( m, 'KBPAR', 'KBPER' );
        cellGrowthB = sum( ...
            reshape( getEffectiveMgenLevels( m, kb_mgens, m.tricellvxs(selcc,:)' ), ...
                3, [], 2 ), 1 ) / 3;
        cellGrowth = (cellGrowthA + cellGrowthB)/2;
        clear ka_mgens kb_mgens cellGrowthA cellGrowthB
        cellGrowth = abs( reshape( cellGrowth, [], 2 ) );
        maxCellGrowth = max(cellGrowth(:));
        
        % Now scale by growth rate.
        majorlength = cellGrowth(:,1);
        if crosses
            minorlength = cellGrowth(:,2);
            if THRESHOLDING
                for i=find(selzero)'
                    % When the gradient is low, growth is isotropic even if
                    % the par and perp values differ.
                    majorlength(i) = (majorlength(i) + minorlength(i))/2;
                    minorlength(i) = majorlength(i);
                end
            end
        end
        if equalsize
            maxLinGrowth = max(majorlength,minorlength);
            if maxLinGrowth > 0
                majorlength = majorlength./maxLinGrowth;
            end
        elseif maxCellGrowth > 0
            majorlength = majorlength/maxCellGrowth;
        end
        if crosses
            if equalsize
                if maxLinGrowth > 0
                    minorlength = minorlength./maxLinGrowth;
                end
            elseif maxCellGrowth > 0
                minorlength = minorlength/maxCellGrowth;
            end
        end
        majorlength = majorlength*quiverscale;
        if crosses
            minorlength = minorlength*quiverscale;
        end
        majorvec = unitgrad .* repmat( majorlength, 1, size(unitgrad,2), size(unitgrad,3) );
        if crosses
            minorvec = crossgrad .* repmat( minorlength, 1, size(crossgrad,2), size(crossgrad,3) );
        end
    end
    
    if ~isempty(m.growthangleperFE) && (size( majorvec, 3 ) > 1)
        majorvec(:,:,1) = rotateVecAboutVec( majorvec(:,:,1), m.unitcellnormals, m.growthangleperFE(:,1) );
        secondindex = min( size(m.growthangleperFE,2), 2 );
        majorvec(:,:,2) = rotateVecAboutVec( majorvec(:,:,2), m.unitcellnormals, m.growthangleperFE(:,secondindex) );
    end
end

end
