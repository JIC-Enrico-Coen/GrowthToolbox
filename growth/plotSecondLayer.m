function m = plotSecondLayer( m, theaxes )
%m = plotSecondLayer( m, theaxes )
%   Draw the second layer.

    if ~hasNonemptySecondLayer(m)
        return;
    end

    full3d = isVolumetricMesh( m );
    numcells = length( m.secondlayer.cells );
    ph = [];
    
    clipbio = m.plotdefaults.doclipbio;
    if isempty( clipbio )
        clipbio = m.plotdefaults.doclip;
    end
            
    visNodeMap = [];
    visCellMap = [];
    if ~clipbio
%         visCellMap = m.secondlayer.visible.cells;
        visCellMap = true( length(m.secondlayer.cells), 1 );
    elseif isempty( m.visible )
        visNodeMap = true( size(m.secondlayer.vxFEMcell) );
    elseif full3d
        visNodeMap = m.visible.elements( m.secondlayer.vxFEMcell );
    else
        visNodeMap = m.visible.cells( m.secondlayer.vxFEMcell );
    end
    
    if ~isempty(visNodeMap)
        % Set visCellMap from visNodeMap.
%         renumberNodes = zeros( length(visNodeMap), 1 ); % 1:length(visNodeMap);
%         renumberNodes(visNodeMap) = (1:sum(visNodeMap))';
        visCellMap = true( numcells, 1 );
        for ci=1:numcells
            cellnodes = m.secondlayer.cells(ci).vxs;
            visCellMap(ci) = all( visNodeMap(cellnodes) );
        end
%     else
%         % Set visNodeMap from visCellMap.
%         if all(visCellMap)
%             visNodeMap = true( size(m.secondlayer.vxFEMcell) );
%         else
%             visNodeMap = false( size(m.secondlayer.vxFEMcell) );
%             visNodeMap( unique( cell2mat( { m.secondlayer.cells.vxs } ) ) ) = true;;
% %             for ci=1:numcells
% %                 cellnodes = m.secondlayer.cells(ci).vxs;
% %                 visNodeMap(cellnodes) = true;
% %             end
%         end
    end
    
    
    
    
    
    haveSecondCell = m.secondlayer.edges(:,4) > 0;
    Aside = full3d || any(m.plotdefaults.sidebio=='A');
    Bside = (~full3d) && any(m.plotdefaults.sidebio=='B') ;
    
    acellmap = visCellMap & (m.secondlayer.side | Aside);
    bcellmap = (~full3d) & visCellMap & (m.secondlayer.side | Bside);
    aedgemap1 = acellmap(m.secondlayer.edges(:,3));
    bedgemap1 = bcellmap(m.secondlayer.edges(:,3));
    aedgemap2 = false(size(aedgemap1));
    aedgemap2( haveSecondCell ) = acellmap(m.secondlayer.edges(haveSecondCell,4));
    bedgemap2 = false(size(bedgemap1));
    bedgemap2( haveSecondCell ) = bcellmap(m.secondlayer.edges(haveSecondCell,4));
    aedgemap = aedgemap1 | aedgemap2;
    bedgemap = bedgemap1 | bedgemap2;
    anodemap = false( size( m.secondlayer.vxFEMcell, 1 ), 1 );
    anodemap( m.secondlayer.edges(aedgemap,[1 2]) ) = true;
    bnodemap = false( size( m.secondlayer.vxFEMcell, 1 ), 1 );
    bnodemap( m.secondlayer.edges(bedgemap,[1 2]) ) = true;
    abnodemap = anodemap | bnodemap;
    renumberNodesA = zeros( length(anodemap), 1 );
    renumberNodesA(anodemap) = (1:sum(anodemap))';
    renumberNodesB = zeros( length(bnodemap), 1 );
    renumberNodesB(bnodemap) = (1:sum(bnodemap))';
    renumberNodesAB = zeros( length(abnodemap), 1 );
    renumberNodesAB(abnodemap) = (1:sum(abnodemap))';
    
    % visCellMap: boolean map listing the cells to be drawn.
    % acellmap: boolean map listing the cells to be drawn on the A side.
    % bcellmap: boolean map listing the cells to be drawn on the B side.
    % aedgemap: boolean map listing the edges to be drawn on the A side.
    % bedgemap: boolean map listing the edges to be drawn on the B side.
    % anodemap: boolean map listing the nodes to be drawn on the A side.
    % bnodemap: boolean map listing the nodes to be drawn on the B side.
    % abnodemap: boolean map listing the nodes to be drawn on either side.
    
    % A cell is drawn if all of its nodes are visible.
    % An edge is drawn if it is an edge of a cell to be drawn.
    % A node is drawn if it is a node of an edge to be drawn.
    % Note that a node or edge might be visible, but not drawn, because no
    % cell it belongs to has all of its nodes visible, and therefore those
    % cells are not drawn.

    
    visCellIndexes = find(visCellMap);
    numviscells = length(visCellIndexes);
    
%     if ~isempty(m.plotdefaults.cellbodyvalue)
        m = getCellColors( m, m.plotdefaults.cellbodyvalue );
%     end
    
    h = guidata( m.pictures(1) );
    if nargin < 2
        theaxes = h.picture;
    end
    if full3d
        mids = m.FEnodes;
        offsets = m.plotdefaults.layeroffset;
%         offsets = 0.01; % TESTING
        if true || (offsets ~= 0)
            [~,vn] = biocellNormals( m );
            offsets = vn * offsets;
        end
    elseif ~m.plotdefaults.drawleaf
        mids = m.nodes;
        offsets = 0;
    else
        if m.plotdefaults.thick
            mids = 0.5 * (m.prismnodes( 2:2:end, : ) + ...
                          m.prismnodes( 1:2:end, : ));
        else
            mids = m.nodes;
        end
        offsets = (m.plotdefaults.thick*0.5 + m.plotdefaults.layeroffset) ...
                    * (m.prismnodes( 2:2:end, : ) - m.prismnodes( 1:2:end, : ));
    end
    if full3d
        c3dcoordsA0 = baryToGlobalCoords( ...
                        m.secondlayer.vxFEMcell(abnodemap), ...
                        m.secondlayer.vxBaryCoords(abnodemap,:), ...
                        m.FEnodes, ...
                        m.FEsets.fevxs );
        c3dcoordsA = offsets(abnodemap) + c3dcoordsA0;
        c3dcoordsB = [];
    elseif false && all(offsets(:)==0)
        c3dcoordsA = baryToGlobalCoords( ...
                        m.secondlayer.vxFEMcell(abnodemap), ...
                        m.secondlayer.vxBaryCoords(abnodemap,:), ...
                        mids, ...
                        m.tricellvxs );
    else
        c3dcoordsA = baryToGlobalCoords( ...
                        m.secondlayer.vxFEMcell(abnodemap), ...
                        m.secondlayer.vxBaryCoords(abnodemap,:), ...
                        mids-offsets, ...
                        m.tricellvxs );
        c3dcoordsB = baryToGlobalCoords( ...
                        m.secondlayer.vxFEMcell(abnodemap), ...
                        m.secondlayer.vxBaryCoords(abnodemap,:), ...
                        mids+offsets, ...
                        m.tricellvxs );
    end
    
    if m.plotdefaults.drawcellaniso
        % Find the cell shapes.
        [aniso,~,diameters,cellaxes,cellcentres] = leaf_cellshapes( m, visCellIndexes );
        % Apply the threshold.
        eligible = aniso > max( 0, m.plotdefaults.cellanisothreshold );
        aniso = aniso(eligible);
        if ~isempty(aniso)
            aniso = aniso/max(aniso);
            diameters = diameters(eligible,:);
            cellaxes = cellaxes(:,:,eligible);
            cellcentres = cellcentres(eligible,:);
            aecellmap = acellmap(visCellIndexes);
            aecellmap = aecellmap(eligible);
            becellmap = bcellmap(visCellIndexes);
            becellmap = becellmap(eligible);

            cellnormals = permute( cellaxes(:,3,:), [3, 1, 2] );
            meshthickness = sqrt( sum( (m.prismnodes( 2:2:end, : ) - m.prismnodes( 1:2:end, : )).^2, 2 ) );
            cellthickness = FEvertexToCell( m, meshthickness, visCellIndexes );
            cellthickness = cellthickness( eligible );
            cellthickness = (m.plotdefaults.thick*0.5 + m.plotdefaults.layeroffset) * cellthickness;
            cellnormals = cellnormals .* repmat( cellthickness, 1, 3 );

            % Get the major axis of every eligible cell.  These are unit vectors.
            majoraxes = permute( cellaxes(:,1,:), [3 1 2] );
            % Calculate the half-length of each line.
            semiaxislength = diameters(:,1) * m.plotdefaults.cellanisoratio/2;
            if m.plotdefaults.cellanisoproportional
                semiaxislength = semiaxislength .* aniso;
            end
            % Calculate the half-vector for each line.
            semiaxes = majoraxes .* repmat( semiaxislength, 1, 3 );
            % Calculate the start and end points of each line.
            if full3d || ~m.plotdefaults.drawleaf
                anisoCentres = cellcentres(aecellmap,:);
                starts = anisoCentres - semiaxes(aecellmap,:);
                ends = anisoCentres + semiaxes(aecellmap,:);
            else
                anisoCentresA = cellcentres(aecellmap,:) - cellnormals(aecellmap,:);
                anisoCentresB = cellcentres(becellmap,:) + cellnormals(becellmap,:);
                starts = [ anisoCentresA - semiaxes(aecellmap,:); anisoCentresB - semiaxes(becellmap,:) ];
                ends = [ anisoCentresA + semiaxes(aecellmap,:); anisoCentresB + semiaxes(becellmap,:) ];
            end
            % Draw the lines.
            nn = size(starts,1);
            xx = [ starts(:,1) ends(:,1) nan(nn,1) ]';
            yy = [ starts(:,2) ends(:,2) nan(nn,1) ]';
            zz = [ starts(:,3) ends(:,3) nan(nn,1) ]';
            anisohandle = line( xx(:), yy(:), zz(:), ...
                'Parent', m.pictures(1), ...
                'Color', m.plotdefaults.cellanisocolor, ...
                'LineWidth', m.plotdefaults.cellanisowidth );
        end
    end
    
    maxvxs= 0;
    cellIndexesToDraw = find( acellmap | bcellmap )';
    for ci = 1:length(cellIndexesToDraw)
        maxvxs = max( maxvxs, length( m.secondlayer.cells(cellIndexesToDraw(ci)).vxs ) );
    end
    facearray = NaN(numviscells,maxvxs);
    for ci = 1:length(cellIndexesToDraw)
        vci = cellIndexesToDraw(ci);
        facearray(ci,1:length( m.secondlayer.cells(vci).vxs )) = ...
            renumberNodesAB(m.secondlayer.cells(vci).vxs);
    end
    renumberCells= zeros( numcells, 1 );
    renumberCells(cellIndexesToDraw) = (1:length(cellIndexesToDraw))';
    if ~isempty(m.secondlayer.cellcolor)
        if m.plotdefaults.drawleaf
            vertices = [c3dcoordsA;c3dcoordsB];
            bsideoffset = size(c3dcoordsA,1);
            faces = [facearray(renumberCells(acellmap),:); facearray(renumberCells(bcellmap),:) + bsideoffset];
            perFaceColor = ...
                [m.secondlayer.cellcolor(acellmap,:); ...
                 m.secondlayer.cellcolor(bcellmap,:)];
        else
            vertices = c3dcoordsA;
            faces = facearray;
            perFaceColor = m.secondlayer.cellcolor(acellmap,:);
        end
        [faceAlpha,faceVertexAlphaData,nontrivial] = getCellAlpha( m.plotdefaults.bioAalpha, m.plotdefaults.bioAemptyalpha, perFaceColor );
        if nontrivial
            ph = patch( ...
                    'Vertices', vertices, ...
                    'Faces', faces, ...
                    'FaceVertexCData', perFaceColor, ...
                    'FaceColor', 'flat', ...
                    'FaceAlpha', faceAlpha, ...
                    'FaceVertexAlphaData', faceVertexAlphaData, ...
                    'AlphaDataMapping', 'none', ...
                    'FaceLighting', m.plotdefaults.lightmode, ...
                    'AmbientStrength', m.plotdefaults.ambientstrength, ...
                    'UserData', struct( 'biocell', cellIndexesToDraw ), ...
                    'LineStyle', 'none', ...
                    'Parent', theaxes ...
                );
        else
            ph = [];
        end
        if ~isempty(m.plotdefaults.cellspacecolor)
            chainsA = getIntercellularSpaces( m, aedgemap | bedgemap );
            facesA = cellToRaggedArray( chainsA, NaN );
            if all(aedgemap==bedgemap)
                chainsB = chainsA;
                facesB = facesA;
            else
                chainsB = getIntercellularSpaces( m, bedgemap );
                facesB = cellToRaggedArray( chainsB, NaN );
            end
            if ~isempty(facesA)
                facesA(~isnan(facesA)) = renumberNodesA( facesA(~isnan(facesA)) );
                % I am assuming here that patch() does the right thing
                % with non-convex, non-planar 3D polygons.
                perFaceColor = repmat( m.plotdefaults.cellspacecolor, length(chainsA), 1 );
                [faceAlpha,faceVertexAlphaData,nontrivial] = getCellAlpha( m.plotdefaults.bioAalpha, m.plotdefaults.bioAemptyalpha, perFaceColor );
                if nontrivial
                    ph2 = patch( ...
                            'Vertices', c3dcoordsA, ...
                            'Faces', facesA, ...
                            'FaceVertexCData', perFaceColor, ...
                            'FaceColor', 'flat', ...
                            'FaceAlpha', faceAlpha, ...
                            'FaceVertexAlphaData', faceVertexAlphaData, ...
                            'AlphaDataMapping', 'none', ...
                            'FaceLighting', m.plotdefaults.lightmode, ...
                            'AmbientStrength', m.plotdefaults.ambientstrength, ...
                            'LineStyle', 'none', ...
                            'Parent', theaxes ...
                        );
                else
                    ph2 = [];
                end
            end
            if ~isempty(facesB)
                facesB(~isnan(facesB)) = renumberNodesB( facesB(~isnan(facesB)) );
                % I am assuming here that patch() does the right thing
                % with non-convex, non-planar 3D polygons.
                perFaceColor = repmat( m.plotdefaults.cellspacecolor, length(chainsB), 1 );
                [faceAlpha,faceVertexAlphaData] = getCellAlpha( m.plotdefaults.bioAalpha, m.plotdefaults.bioAemptyalpha, perFaceColor );
                if nontrivial
                    ph2 = patch( ...
                            'Vertices', c3dcoordsB, ...
                            'Faces', facesB, ...
                            'FaceVertexCData', repmat( m.plotdefaults.cellspacecolor, length(chainsB), 1 ), ...
                            'FaceColor', 'flat', ...
                            'FaceAlpha', faceAlpha, ...
                            'FaceVertexAlphaData', faceVertexAlphaData, ...
                            'AlphaDataMapping', 'none', ...
                            'FaceLighting', m.plotdefaults.lightmode, ...
                            'AmbientStrength', m.plotdefaults.ambientstrength, ...
                            'LineStyle', 'none', ...
                            'Parent', theaxes ...
                        );
                else
                    ph2 = [];
                end
            end
        end
    end
    
    if m.plotdefaults.bioAlinesize > 0
        renumberAnodes = 1:length(anodemap);
        renumberAnodes(anodemap) = 1:sum(anodemap);
        renumberBnodes = 1:length(bnodemap);
        renumberBnodes(bnodemap) = 1:sum(bnodemap);
        lineStyle = '-';
        
        plotMultipropertyLines( renumberAnodes(m.secondlayer.edges(aedgemap,[1 2])), ...
            c3dcoordsA, ...
            m.secondlayer.edgepropertyindex(aedgemap), ...
            m.secondlayer.indexededgeproperties, ...
            'Parent', theaxes, ...
            'LineStyle', lineStyle );
        if m.plotdefaults.drawleaf && ~isempty(c3dcoordsB)
            plotMultipropertyLines( renumberBnodes(m.secondlayer.edges(bedgemap,[1 2])), ...
                c3dcoordsB, ...
                m.secondlayer.edgepropertyindex(bedgemap), ...
                m.secondlayer.indexededgeproperties, ...
                'Parent', theaxes, ...
                'LineStyle', lineStyle );
        end
    end
    
    if m.plotdefaults.bioApointsize > 0
        if m.plotdefaults.drawleaf
            plotpts( theaxes, [c3dcoordsA;c3dcoordsB], ...
                'Color', m.plotdefaults.bioApointcolor, ...
                'LineStyle', 'none', ...
                'Marker', '.', ...
                'MarkerSize', m.plotdefaults.bioApointsize );
        else
            plotpts( theaxes, c3dcoordsA, ...
                'Color', m.plotdefaults.bioApointcolor, ...
                'LineStyle', 'none', ...
                'Marker', '.', ...
                'MarkerSize', m.plotdefaults.bioApointsize );
        end
    end
    set( ph, 'ButtonDownFcn', @cellButtonDownFcn );
    m.plothandles.secondlayerhandle = ph;
end

function [faceAlpha,faceVertexAlphaData,nontrivial] = getCellAlpha( singleFaceAlpha, emptyAlpha, perFaceColor )
    if isempty( emptyAlpha ) || (singleFaceAlpha == emptyAlpha)
        faceAlpha = singleFaceAlpha;
        faceVertexAlphaData = [];
        nontrivial = singleFaceAlpha > 0;
    else
        emptyfaces = all(perFaceColor==1,2);
        if ~any(emptyfaces)
            faceAlpha = singleFaceAlpha;
            faceVertexAlphaData = [];
            nontrivial = singleFaceAlpha > 0;
        elseif all(emptyfaces)
            faceAlpha = emptyAlpha;
            faceVertexAlphaData = [];
            nontrivial = emptyAlpha > 0;
        else
            faceAlpha = 'flat';
            faceVertexAlphaData = singleFaceAlpha + zeros( size(perFaceColor,1), 1 );
            faceVertexAlphaData( emptyfaces ) = emptyAlpha;
            nontrivial = true;
        end
    end
end

function ph = plotIntercellularSpaces( m, allowededges, theaxes )
    ph = [];
    chains = getIntercellularSpaces( m, allowededges );
    if isempty(chains)
        return;
    end
    faces = cellToRaggedArray( chains,NaN );
    
    % Draw the faces.  I am assuming here that patch() does the right thing
    % with non-convex, non-planar 3D polygons.
    perFaceColor = repmat( [1 0 0], length(chains), 1 );
    [faceAlpha,faceVertexAlphaData,nontrivial] = getCellAlpha( m.plotdefaults.bioAalpha, m.plotdefaults.bioAemptyalpha, perFaceColor );
    if nontrivial
        ph = patch( ...
                'Vertices', m.secondlayer.cell3dcoords, ...
                'Faces', faces, ...
                'FaceVertexCData', perFaceColor, ...
                'FaceColor', 'flat', ...
                'FaceAlpha', faceAlpha, ...
                'FaceVertexAlphaData', faceVertexAlphaData, ...
                'AlphaDataMapping', 'none', ...
                'FaceLighting', m.plotdefaults.lightmode, ...
                'AmbientStrength', m.plotdefaults.ambientstrength, ...
                'LineStyle', 'none', ...
                'Parent', theaxes ...
            );
    else
        ph = [];
    end
end

function m = getCellColors( m, cellbodyvalue )
% This procedure must set m.secondlayer.cellcolor, and may set
% m.secondlayer.colorscale.
%
% The cellbodyvalue argument can be any of:
%   the name of a cell factor
%   the index of a cell factor
%   a single real number per cell
%   a triple of real numbers (an RGB color) per cell.
%   a cell array of names of cell factors.
% The procedure begins by distinguishing these cases and setting the
% following variables.  Each variable that is not used is set to empty.
%   cellfactorname
%   cellfactorindex
%   cellfactorvalues
%   cellfactorcolors
% At the end of that process, either exactly one of cellfactorvalues or
% cellfactorcolors will be set, or the procedure will have returned early
% because of bad arguments, setting m.secondlayer.cellcolor to white
% everywhere.

    cellfactorname = [];
    cellfactorindex = [];
    cellfactorvalues = [];
    cellfactorcolors = [];
    numcells = length(m.secondlayer.cells);
    if iscell(cellbodyvalue) && (length(cellbodyvalue)==1)
        cellbodyvalue = cellbodyvalue{1};
    end
    if isempty( cellbodyvalue )
        m.secondlayer.cellcolor = ones(numcells,3);
        return;
    elseif ischar( cellbodyvalue )
        % Name of either a cell factor or a special-case pseudo-factor.
        cellfactorname = cellbodyvalue;
        switch cellfactorname
            case 'cellarea'
                cellfactorvalues = m.secondlayer.cellarea;
            case 'generation'
                m.secondlayer.cellcolor = ones(numcells,3);
                return;
                % Cell generations not implemented?
                % cellbodyvalue = m.secondlayer.generation(:);
            otherwise
                cellfactorindex = name2Index( m.secondlayer.valuedict, cellbodyvalue );
                if cellfactorindex==0
                    % Error: non-existent cell factor name
                    fprintf( 1, '%s: Unknown cell factor name "%s".\n', mfilename(), cellbodyvalue );
                    m.secondlayer.cellcolor = ones(numcells,3);
                    return;
                end
        end
    elseif isnumeric( cellbodyvalue )
        if numel(cellbodyvalue)==1
            cellfactorindex = cellbodyvalue;
            cellfactorname = index2Name( m.secondlayer.valuedict, cellfactorindex );
            if isempty(cellfactorname)
                % Error: non-existent cell factor index
                fprintf( 1, '%s: Unknown cell factor index "%d".\n', mfilename(), cellbodyvalue );
                m.secondlayer.cellcolor = ones(numcells,3);
                return;
            end
        end
        if isempty(cellfactorindex)
            % OBSOLETE: cellbodyvalue should contain only cell factor
            % names.
            xxxx = 1;
            % cellbodyvalue does not contain either a factor name or a
            % factor index.  It should therefore contain the actual
            % per-cell values or colors.
            if numel(cellbodyvalue)==numcells
                % Single value per cell
                cellfactorvalues = cellbodyvalue;
            elseif (size(cellbodyvalue,1)==numcells) && (size(cellbodyvalue,2)==3)
                % Color per cell
                cellfactorcolors = cellbodyvalue;
            else
                % Error: wrong number of values
                fprintf( 1, '%s: wrong number of values supplied: %d found, but %d values or %dx3 array expected.\n', ...
                    mfilename(), numel(cellbodyvalue), numel(cellbodyvalue) );
                m.secondlayer.cellcolor = ones(numcells,3);
                return;
            end
        end
    elseif iscell( cellbodyvalue )
        % Here we should convert the set of cell factors to a colour per
        % cell, and replace cellbodyvalue with that.
        backgroundcolor = [1 1 1];  % TEMPORARY -- how does cell background change with colour scheme?
        cellfactorindexes = FindCellFactorIndex( m, cellbodyvalue );
        cellfactorvalues = m.secondlayer.cellvalues(:,cellfactorindexes);
        cellfactorcolorinfo = m.secondlayer.cellcolorinfo(cellfactorindexes);
        if true
            poscolors = cellfactorcolorinfo;
            negcolors = [];
        else
            poscolors = reshape( [cellfactorcolorinfo.pos], 3, [] );
            negcolors = reshape( [cellfactorcolorinfo.neg], 3, [] );
        end
        m.secondlayer.cellcolor = combineColors( cellfactorvalues, poscolors, negcolors, ...
            m.secondlayer.cellvalue_plotpriority(cellfactorindexes), m.secondlayer.cellvalue_plotthreshold(cellfactorindexes), ...
            m.plotdefaults.multibrighten, [], backgroundcolor );
        xxxx = 1;
        return;
    else
        % Error: cellbodyvalue is neither a string nor numerical nor a cell array.
        fprintf( 1, '%s: cell value argument is neither a string nor numerical: class %s found.\n', ...
            mfilename(), class(cellbodyvalue) );
        m.secondlayer.cellcolor = ones(numcells,3);
        return;
    end
    if cellfactorindex > 0
        cellfactorvalues = m.secondlayer.cellvalues(:,cellfactorindex);
    end
    if isempty(cellfactorvalues) && isempty(cellfactorcolors)
        % Error: no valid data found
        fprintf( 1, '%s: no valid data found.\n', mfilename() );
        m.secondlayer.cellcolor = ones(numcells,3);
        return;
    end
    
    % We now have either cellfactorcolors or cellfactorvalues.  In the first
    % case, set cell colors from cellfactorcolors.
    
    if ~isempty(cellfactorcolors)
        m.secondlayer.cellcolor = cellbodyvalue;
        return;
    end
    
    % cellfactorvalues is nonempty.  We need to find the correct color
    % scale to translate these values to colors.
    if isempty(cellfactorindex)
        % Use a default color specification.
        colorinfo = m.secondlayer.customcellcolorinfo;
        xxxx = 1;
    else
        % User color specification for the cell factor.
        colorinfo = m.secondlayer.cellcolorinfo(cellfactorindex);
    end
    if isempty( colorinfo.autorange )
        colorinfo.autorange = true;
    end
    if isempty( colorinfo.issplit )
        colorinfo.issplit = false;
    end
    
    % Calculate the colors.
    if colorinfo.autorange || isempty( colorinfo.range )
        scrange = [ min(cellfactorvalues), max(cellfactorvalues) ];
        if isempty(scrange)
            scrange = [0 1];
        end
    else
        scrange = colorinfo.range;
    end
    if colorinfo.issplit
        scrange = extendToZero( scrange );
    end
    switch colorinfo.mode
        case { 'splitmono', 'posneg' }
            m.secondlayer.colorscale = posnegMap( scrange, [1 1 1;colorinfo.neg(:)'], [1 1 1;colorinfo.pos(:)'] );
            m.secondlayer.cellcolor = translateToColors( cellfactorvalues, scrange, m.secondlayer.colorscale );
        case { 'monochrome', 'minmax' }
            m.secondlayer.colorscale = posnegMap( [-1 1], [1 1 1;colorinfo.neg(:)'], [1 1 1;colorinfo.pos(:)'] );
            m.secondlayer.cellcolor = translateToColors( cellfactorvalues, scrange, m.secondlayer.colorscale );
        case 'rainbow'
            [m.secondlayer.colorscale,~] = rainbowMap( [0 1], false );
            m.secondlayer.cellcolor = translateToColors( cellfactorvalues, scrange, m.secondlayer.colorscale );
        case 'splitrainbow'
            [m.secondlayer.colorscale,~] = rainbowMap( [0 1], true );
            m.secondlayer.cellcolor = translateToColors( cellfactorvalues, scrange, m.secondlayer.colorscale );
        case 'custom'
            m.secondlayer.colorscale = colorinfo.colors;
            m.secondlayer.cellcolor = translateToColors( cellfactorvalues, scrange, m.secondlayer.colorscale );
        case 'indexed'
            indexvalues = mod( round(cellfactorvalues), size(colorinfo.colors,1) ) + 1;
            m.secondlayer.cellcolor = colorinfo.colors(indexvalues,:);
    end
end
