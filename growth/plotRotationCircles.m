function [m,h] = plotRotationCircles( m, ...
              selcc, selptsmid, selptsA, selptsB, ...
              rotations, rotscale, decorscale, s )
    % If we are not plotting the rotation circles, return.
    if ~s.drawrotations
        return;
    end
    
%     global gDefaultPlotOptions
%     s = defaultFromStruct( s, gDefaultPlotOptions, ...
%                            { 'arrowthickness', ...
%                              'crossthickness', ...
%                              'arrowheadsize', ...
%                              'arrowheadratio', ...
%                              'rotarrowcolor' } );
    
    theaxes = m.pictures(1);
    if isempty(theaxes) || ~ishghandle(theaxes)
        return;
    end
    full3d = usesNewFEs(m);

    % Calculate the gradients for the selected FEs.
    % Store these in polgrads.
    % Observe which of these are zero and so are to be drawn as circles.
    % Observe which are frozen and so are to be drawn in a different
    % colour.
    
    rotationColor = [0 0 0];
%     rotations = m.outputs.rotations(selcc,:);
    rotsizes = sqrt(sum(rotations.^2,2));
    nz = rotsizes > 0;
    rotsizes = rotsizes(nz);
    rotaxes = rotations(nz,:);
    mask = selcc & nz;
    if ~any(mask)
        return;
    end
    
    rotarcmin = pi/6;
    rotarcmax = 2*pi;
    rotsizes = rotsizes*rotscale*((rotarcmax-rotarcmin)/max(abs(rotsizes))) + rotarcmin;
    
    if full3d
        h = plotRots( selptsmid(mask,:) );
        h.Tag = 'rotations';
    else
        hA = [];
        hB = [];
        % If we are plotting gradients on the A side:
        if any( s.sidegrad=='A' )
            hA = plotRots( selptsA(mask,:) );
            hA.Tag = 'rotationsA';
        end

        % If we are plotting gradients on the B side:
        if any( s.sidegrad=='B' )
            hB = plotRots( selptsB(mask,:) );
            hB.Tag = 'rotationsB';
        end
        h = [ hA, hB ];
    end
    m.plothandles.rotations = h;

function h = plotRots( points )
    h = plotcircles( ...
        'centre', points, ...  % Centres of FEs selected according to sparsity, offset according to A/B side.
        'radius', decorscale/3, ... % Fixed size depending on sparsity, as for gradient arrows.
        'normal', rotaxes, ...  % Cell normals for selected FEs.
        'startvec', [0 1 0], ... % [sign(rotsizes) zeros(length(rotsizes),2)], ...  % +X or -X according to sign of rotation.
        'midangle', 0, ... % Stet.
        'arc', rotsizes, ...  % Data, scaled to +/- 4pi/3.
        'arrowsize', 0.5, ... % Default.
        'arrowratio', 0.5, ... % Default.
        'resolution', 36, ... % Default.
        'minangle', 0.5, ... % Default.
        'minradius', 0, ...
        ...
        'LineStyle', '-', ...
        'Color', rotationColor, ...
        'LineWidth', s.arrowthickness, ...
        'Parent', theaxes );
        % 'LineSmoothing', 'on' );  % LineSmoothing is deprecated.
end

end
