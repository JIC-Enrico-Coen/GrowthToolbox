function handles = plotGrowthCrosses( m, selcc, selbc, selpts, sparsedistance, ...
                                      arrows, crosses, equalsize, scale, s )
% NO LONGER USED.
%
% Plot crosses or circles, with or without arrowsheads, at specified
% places.
%
% SELCC is a list of indexes of FEs (not necessarily distinct).
% SELBC is a list of corresponding barycentric coordinates within those
% FEs.
% SELPTS is a list of the 3D coordinates of those points.
% SPARSEDISTANCE is the radius within which the polarisation gradient will
% be averaged.
% ARROWS is a boolean to specify whether to draw arrowheads.
% CROSSES is a boolean to specify whether to draw transverse lines showing the
% minor growth.
% EQUALSIZE is a boolean specifying whether all principal directions should
% be drawn the same size, or in proportion to the growth rate.
% SCALE is a measure of the size the largest arrow should be.  SCALE
% defaults to m.globalDynamicProps.cellscale.
% S is a struct containing a set of plotting options for the arrows for
% thickness, head size, and color.

    global gDefaultPlotOptions
    
    if nargin < 6
        scale = m.globalDynamicProps.cellscale;
    end
    if nargin < 7
        s = struct();
    end
    s = defaultFromStruct( s, gDefaultPlotOptions, ...
                           { 'arrowthickness', ...
                             'crossthickness', ...
                             'arrowheadsize', ...
                             'arrowheadratio', ...
                             'highgradcolor', ...
                             'lowgradcolor', ...
                             'tensoroffset' } );
    
    THRESHOLDING = false;
    
    h = guidata( m.pictures(1) );
    theaxes = h.picture;

  % if maxCellGrowth==0
  %     return;
  % end

    quiverscale = scale*0.4;
  % quivermajorformat = { 'Color', [0 0 0.3], 'LineWidth', 2 };
  % quiverminorformat = { 'Color', [0 0 0.3], 'LineWidth', 1 };
    quivernoarrowtype = '-.';
    if arrows
        quiverarrowtype = '-';
    else
        quiverarrowtype = quivernoarrowtype;
    end
    
    % Find the cell centres.
  % cc = elementCentres( m, selcc );
    numselcells = length(selcc);
    
    % Find the unit gradient vectors and the cells with zero or low gradients.
    AVERAGING = true;
    if AVERAGING
        unitgrad = zeros( length(selcc), 3, size(m.gradpolgrowth,3) );
        for i=1:length(selcc)
            unitgrad(i,:,:) = avpolgrad( m, selcc(i), selpts(i,:), sparsedistance );
        end
    else
        unitgrad = m.gradpolgrowth(selcc,:,:);
    end
    lowgrad = m.polfrozen; % gradnorm < m.globalProps.mingradient;
    circles = false( numselcells, size(m.gradpolgrowth,3) );
    for layer = 1:size(m.gradpolgrowth,3)
        for sci=1:numselcells
            ci = selcc(sci);
            n = norm(unitgrad(sci,:,layer));
            if n > 0
                unitgrad(sci,:,layer) = unitgrad(sci,:,layer)/n;
            else
                unitgrad(sci,:,layer) = findunitperp( m.unitcellnormals(ci,:) );
                circles(sci,layer) = true;
            end
        end
    end
    if THRESHOLDING
        circles = circles | lowgrad;
    end

    if crosses
        % Find the unit vectors perpendicular to the gradients.
        crossgrad = cross( unitgrad(:,:,layer), m.unitcellnormals(selcc,:), 2 );
    end

    majorlength = [];
    minorlength = [];
    if equalsize && ~crosses
        majorvec = unitgrad*quiverscale;
    else
        % Scale the vectors according to the magnitude of the
        % morphogen-specified growth.
        
        % First calculate the growth rates.
        ka_mgens = FindMorphogenRole( m, 'KAPAR', 'KAPER' );
        mgenvaluesA = getEffectiveMgenLevels( m, ka_mgens, m.tricellvxs(selcc,:)' );
        cellGrowthA = sum( reshape( mgenvaluesA, 3, [], 2 ), 1 ) / 3;
        kb_mgens = FindMorphogenRole( m, 'KBPAR', 'KBPER' );
        mgenvaluesB = getEffectiveMgenLevels( m, kb_mgens, m.tricellvxs(selcc,:)' );
        cellGrowthB = sum( reshape( mgenvaluesB, 3, [], 2 ), 1 ) / 3;
        cellGrowth = (cellGrowthA + cellGrowthB)/2;
        clear ka_mgens kb_mgens mgenvaluesA mgenvaluesB cellGrowthA cellGrowthB
        cellGrowth = abs( reshape( cellGrowth, [], 2 ) );
        maxCellGrowth = max(cellGrowth(:));
        
        % Now scale by growth rate.
        majorlength = cellGrowth(:,1);
        if crosses
            minorlength = cellGrowth(:,2);
            if THRESHOLDING
                for i=find(circles)'
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
        majorvec = zeros( numselcells, 3 );
        for i=1:3
            majorvec(:,i) = unitgrad(:,i) .* majorlength;
        end
        if crosses
            minorvec = zeros( numselcells, 3 );
            for i=1:3
                minorvec(:,i) = crossgrad(:,i) .* minorlength;
            end
        end
    end
    
% Now do the plotting.

    % Array to store all the plot handles in. This is not actually used.
    handles = [];
    
    
    % Draw the isotropic growth circles.
    if any(circles(:)) && crosses
        circlecentres = selpts(circles,:);
        circlemajors = majorvec(circles,:);
        circleminors = minorvec(circles,:);
        h = plot3circle( ...
            circlecentres, circlemajors, circleminors, 12, ...
            quivernoarrowtype, ...
            'Parent', theaxes, ...
            'Color', s.highgradcolor, ...
            'LineWidth', s.arrowthickness );
        % handles(circles,1) = h;
    end

    % Draw the major axes.
    if isempty(majorlength)
        havemajors = ~circles;
    else
        havemajors = (~circles) & (majorlength ~= 0);
    end
    sel_lowgrad = lowgrad(selcc(:),:);
    havemajorshigh = havemajors & ~sel_lowgrad;
    havemajorslow = havemajors & sel_lowgrad;
    FORE = 1;
    AFT = 1;
    if any(havemajorshigh)
        handles_havemajorshigh = myquiver3( ...
             selpts(havemajorshigh,:), ...
             majorvec(havemajorshigh,:), ...
             m.unitcellnormals(selcc(havemajorshigh),:), ...
             s.arrowheadsize, s.arrowheadratio, FORE, AFT, ...
             'LineStyle', quiverarrowtype, ...
             'Parent', theaxes, ...
             'Color', s.highgradcolor, ...
             'LineWidth', s.arrowthickness );
             % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
    end
    if any(havemajorslow)
        handles_havemajorslow = myquiver3( ...
             selpts(havemajorslow,:), ...
             majorvec(havemajorslow,:), ...
             m.unitcellnormals(selcc(havemajorslow),:), ...
             s.arrowheadsize, s.arrowheadratio, FORE, AFT, ...
             'LineStyle', quiverarrowtype, ...
             'Parent', theaxes, ...
             'Color', s.lowgradcolor, ...
             'LineWidth', s.arrowthickness );
             % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
    end
           
    if crosses
        haveminors = (~circles) & (minorlength ~= 0);
        haveminorshigh = haveminors & ~lowgrad;
        haveminorslow = haveminors & lowgrad;
        if any(haveminorshigh)
            % Draw the minor axes.
            handles_haveminorshigh4 = myquiver3( ...
                selpts(haveminorshigh,:), ...
                minorvec(haveminorshigh,:), ...
                m.unitcellnormals(selcc(haveminorshigh),:), ...
                0, 0, FORE, AFT, ...
                'LineStyle', quiverarrowtype, ...
            'Parent', theaxes, ...
            'Color', s.highgradcolor, ...
            'LineWidth', s.crossthickness );
             % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
        end
        if any(haveminorslow)
            % Draw the minor axes.
            handles_haveminorslow4 = myquiver3( ...
                selpts(haveminorslow,:), ...
                minorvec(haveminorslow,:), ...
                m.unitcellnormals(selcc(haveminorslow),:), ...
                0, 0, FORE, AFT, ...
                'LineStyle', quiverarrowtype, ...
            'Parent', theaxes, ...
            'Color', s.lowgradcolor, ...
            'LineWidth', s.crossthickness );
             % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
        end
    end
end

