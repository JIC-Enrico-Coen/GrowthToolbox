function status = writemeshvrml( filedir, filename, m, bbox, cameraparams )
%status = writemeshvrml( filedir, filename, m, bbox, cameraparams )
%   Write the mesh to a file in VRML 97 format.  For foliate and volumetric meshes.
%
%   Limitations: Only the finite element mesh and the cellular layer are exported,
%   and without visible edges.  Other decorations, e.g. streamlines, tensor axes,
%   gradient arrows, etc. are not exported.  Edges of the finite elements and the
%   cells are not exported, only the faces. These limitations may at some point be
%   lifted.
%
%   Subject to those limitations, what is exported is what would be plotted by leaf_plot.
%   Thus if there is a clipping plane, the exported mesh will be clipped, the finite
%   elements and the cells will be coloured according to the selected plotting options,
%   etc.

    scaleParams = struct( 'sizescale', 1, 'thicknessscale', 1, 'allthickness', [], 'thickmin', 0 );
    maxnodes = max( m.nodes, [], 1 );
    minnodes = min( m.nodes, [], 1 );
    bboxsize = maxnodes - minnodes;
    centre = (minnodes + maxnodes)/2;
    if isinteractive(m)
        ud.bbdiam = max( bboxsize );
        vxthickness = sqrt( sum( (m.prismnodes(2:2:end,:) - m.prismnodes(1:2:end,:)).^2, 2 ) );
        ud.thickrange = [ min(vxthickness) max(vxthickness) ];
        ud.thickmin = 0;
        ud.guicolors.greenFore = [0.9 1 0.9];
        ud.guicolors.greenBack = [0.4 0.8 0.4];
        vrmlDialogResult = performRSSSdialogFromFile( ...
            findGFtboxFile( 'guilayouts/VRMLParamsLayout.txt' ), ...
            [], ud, @updateVRMLdialog );
        if isempty(vrmlDialogResult)
            % User cancelled.
            return;
        end
        scaleParams = setFromStruct( scaleParams, vrmlDialogResult.userdata, ...
            { 'sizescale', 'thicknessscale', 'allthickness', 'thickmin' } );
    end
    
    creaseAngle = 0.0;  % Radians.  0 makes all edges sharp, >= pi makes all edges smooth.
    
    prismnodes = m.prismnodes;
    nodes = m.nodes;
    scalesize = (scaleParams.sizescale > 0) && (scaleParams.sizescale ~= 1);
    if scalesize
        prismnodes = prismnodes * scaleParams.sizescale;
        nodes = nodes * scaleParams.sizescale;
        centre = centre * scaleParams.sizescale;
    end
    
    prismnodes = prismnodes - repmat( centre, size(prismnodes,1), 1 );
    nodes = nodes - repmat( centre, size(nodes,1), 1 );
    
    
    deltas = prismnodes( 2:2:end, : ) - nodes;
    scalethickness = (~isempty(scaleParams.thicknessscale)) ...
                     && (scaleParams.thicknessscale > 0) ...
                     && (scaleParams.thicknessscale ~= 1);
    if scalethickness
        deltas = deltas * scaleParams.thicknessscale;
    end
    
    halfthicks = sqrt(sum(deltas.^2,2));
    setthickness = (~isempty(scaleParams.allthickness)) ...
                   && (scaleParams.allthickness > 0);
    if setthickness
        deltas = deltas .* repmat( 1./halfthicks, 1, 3 ) * (scaleParams.allthickness/2);
        halfthicks(:) = scaleParams.allthickness/2;
    end
    
    minhalfthickness = scaleParams.thickmin/2;
    setminthickness = min( halfthicks ) < minhalfthickness;
    if setminthickness
        smallthicks = halfthicks < minhalfthickness;
        scaling = minhalfthickness./halfthicks(smallthicks);
        deltas(smallthicks,:) = deltas(smallthicks,:) .* repmat( scaling, 1, 3 );
    end
    
    if scalethickness || setthickness || setminthickness
        prismnodes = reshape( [ (nodes - deltas)'; (nodes + deltas)' ], 3, [] )';
    end
    
    indentUnit = '    ';
    indentString = '';
    linenumber = 0;
    itemstack = {};
    linestack = [];

    fullfilename = fullfile( filedir, filename );
    if ~endsWithM(fullfilename,'.wrl')
        fullfilename = strcat(fullfilename,'.wrl');
    end
    fid = fopen(fullfilename,'w');
    if fid==0
        fprintf( 1, 'Cannot write to file %s.\n', fullfilename );
        status = 0;
        return;
    end
    
    [mc,mcA,mcB] = meshColors( m );
    m = findVisiblePart( m );
    borderedgeindexes = find(m.visible.borderedges);
    isPerVertex = (isfield( m.plotdata, 'pervertex' ) && m.plotdata.pervertex) ...
                  || (isfield( m.plotdata, 'pervertexA' ) && m.plotdata.pervertexA) ...
                  || (isfield( m.plotdata, 'pervertexB' ) && m.plotdata.pervertexB);
    if isempty(mc)
        if isPerVertex
            mcA = mcA( m.visible.nodes, : );
            mcB = mcB( m.visible.nodes, : );
            mc = reshape( [mcA'; mcB'], 3, [] )';
        else
            bordercolorsA = mcA(m.visible.bordercells,:);
            bordercolorsB = mcB(m.visible.bordercells,:);
            mcA = mcA( m.visible.cells, : );
            mcB = mcB( m.visible.cells, : );
            bordercolors = reshape( [bordercolorsA';bordercolorsB'], 3, [] )';
            mc = [mcA; mcB; bordercolors];
        end
    else
        if isPerVertex
            mc = mc( m.visible.nodes, : );
            mc = reshape( [mc'; mc'], 3, [] )';
        else
            bordercolors = mc(m.visible.bordercells,:);
            mc = mc( m.visible.cells, : );
            bordercolors = reshape( [bordercolors';bordercolors'], 3, [] )';
            mc = [mc; mc; bordercolors];
        end
    end
    
    onecolor = true;
    thecolor = mc(1,:);
    for i=1:size(mc,2)
        if any(mc(:,i) ~= thecolor(i))
            onecolor = false;
            thecolor = [1 1 1];
            break;
        end
    end
    
    writeVRMLpreamble( fid );
    
    writeVRMLViewpoints( fid, cameraparams, scaleParams.sizescale, centre )
    
    
    
    openShape( isPerVertex, thecolor, creaseAngle, 1 );

    % Vertex coordinates.
    [pts,scaling,oldcentre,newcentre] = fitToBbox( prismnodes, bbox );
    writestring( sprintf( '# Mesh vertexes: %d items\n', size(pts,1) ) );
    writearray( '%f', 3, '', pts' );
    clear pts
        
    closearray( 'point' );
    closeitem( 'coord Coordinate' );
    openarray( 'coordIndex' );

    % Faces.
    bsidevxs = m.tricellvxs(m.visible.cells,:)*2;
    asidevxs = bsidevxs-1;
    writestring( sprintf( '# A side polygons: %d items\n', size(asidevxs,1) ) );
    writearray( '%d', 3, '-1', asidevxs(:,[1 3 2])' - 1 );
    writestring( '' );
    writestring( sprintf( '# B side polygons: %d items\n', size(bsidevxs,1) ) );
    writearray( '%d', 3, '-1', bsidevxs' - 1 );
    writestring( '' );
    linenumber = linenumber + size(asidevxs,1) + size(bsidevxs,1);
    
    if ~isempty(borderedgeindexes)
        writestring( sprintf( '# Border faces: %d\n', length(borderedgeindexes)*2 ) );
    end
    for beii=1:length(borderedgeindexes) % size(m.edgeends,1)
        i = borderedgeindexes(beii);
        c = m.visible.bordercells(beii);
        % find edge i in cell c
        cei = find( m.celledges(c,:)==i, 1 );
        vs = m.tricellvxs( c, othersOf3( cei ) );
        % vs contains the two ends of edge i, in positive order.  These
        % are the same vertexes as m.edgeends(i,:), but the latter
        % are in arbitrary order.
        bvs = vs*2 - 1;
        avs = bvs-1;
        fprintf( fid, '%s%d %d %d -1\n%s%d %d %d -1\n', ...
            indentString, avs(1), avs(2), bvs(2), ... % The A (bottom) side in negative order.
            indentString, avs(1), bvs(2), bvs(1) ); % The B (top) side in positive order.
        linenumber = linenumber+2;
    end
    
    closearray( 'coordIndex' );
    INDEXEDCOLOR = false;
    % Indexed color is not compatible with ZPrint.
    if INDEXEDCOLOR
        openarray( sprintf( '# colorIndex: %d items\n', size(mc,1) ) );
        fprintf( fid, '%d\n', 0:(size(mc,1)-1) );
        closearray( 'colorIndex' );
    else
        writefield( 'colorIndex []' );
    end
    if ~onecolor
        openitem( 'color Color' );
        openarray( 'color' );

        writestring( sprintf( '# Mesh vertex colours: %d items', size(mc,1) ) );
      % fprintf( fid, '%f %f %f \n', mc' );
        writearray( '%f', 3, '', mc' );
        linenumber = linenumber + size(mc,1);

        closearray( 'color' );
        closeitem( 'color Color' );
    end
    closeitem( 'geometry IndexedFaceSet' );
    closeitem( 'Shape' );
    
    if m.plotdefaults.drawsecondlayer && hasNonemptySecondLayer( m ) && (m.plotdefaults.bioAalpha > 0)
        INDEXEDCOLOR = false;

        numcells = length( m.secondlayer.cells );
        visNodeMap = m.visible.cells( m.secondlayer.vxFEMcell );
        renumberNodes = 1:length(visNodeMap);
        renumberNodes(visNodeMap) = 0:(sum(visNodeMap) - 1);
        visCellMap = true( numcells, 1 );
        for ci=1:numcells
            cellnodes = m.secondlayer.cells(ci).vxs;
            visCellMap(ci) = all( visNodeMap(cellnodes) );
        end
        visCellIndexes = find(visCellMap);
        layeroffset = m.plotdefaults.layeroffset;
        mids = 0.5 * (prismnodes( 2:2:end, : ) + ...
                      prismnodes( 1:2:end, : ));
        offsets = (0.5+layeroffset) * (prismnodes( 2:2:end, : ) - prismnodes( 1:2:end, : ));
        c3dcoordsMid = baryToGlobalCoords( ...
                            m.secondlayer.vxFEMcell(visNodeMap), ...
                            m.secondlayer.vxBaryCoords(visNodeMap,:), ...
                            mids, ...
                            m.tricellvxs );
        c3dcoordsOff = baryToGlobalCoords( ...
                            m.secondlayer.vxFEMcell(visNodeMap), ...
                            m.secondlayer.vxBaryCoords(visNodeMap,:), ...
                            offsets, ...
                            m.tricellvxs );
        if m.plotdefaults.cellsonbothsides
            c3dcoordsA = c3dcoordsMid - c3dcoordsOff;
            c3dcoordsB = c3dcoordsMid + c3dcoordsOff;
        else
            anodesmap = false( length(m.secondlayer.vxFEMcell), 1 );
            for ci=1:numcells
                cellnodes = m.secondlayer.cells(ci).vxs;
                a = m.secondlayer.side(ci);
                anodesmap( cellnodes ) = a;
            end
            bnodesmap = ~anodesmap;
            avisnodesmap = visNodeMap & anodesmap;
            bvisnodesmap = visNodeMap & bnodesmap;
            
            c3dcoordsA = c3dcoordsMid;
            c3dcoordsA(avisnodesmap,:) = c3dcoordsA(avisnodesmap,:) - c3dcoordsOff(avisnodesmap,:);
            c3dcoordsB = c3dcoordsMid;
            c3dcoordsB(bvisnodesmap,:) = c3dcoordsB(bvisnodesmap,:) + c3dcoordsOff(bvisnodesmap,:);
        end
        % Write all the vertexes
%         cellvxs = m.secondlayer.cell3dcoords;
%         for i=1:size(cellvxs,2)
%             cellvxs(:,i) = (cellvxs(:,i) - oldcentre(i))*scaling(i) + newcentre(i);
%         end
        isnonempty = ~isempty( c3dcoordsA ) || ~isempty( c3dcoordsB );
        if isnonempty
            writestring( '' );
            writestring( '# Clones' );
            openShape( ~INDEXEDCOLOR, thecolor, creaseAngle, m.plotdefaults.bioAalpha );
            if ~isempty( c3dcoordsA )
                writestring( '' );
                writestring( sprintf( '# A side biological cell vertexes: %d', size(c3dcoordsA,1) ) );
                writearray( '%f', 3, '', c3dcoordsA' );
            end
            if ~isempty( c3dcoordsB )
                writestring( '' );
                writestring( sprintf( '# B side biological cell vertexes: %d', size(c3dcoordsB,1) ) );
                writearray( '%f', 3, '', c3dcoordsB' );
            end

            closearray( 'point' );
            closeitem( 'coord Coordinate' );
            openarray( 'coordIndex' );

            numAsideVxs = size(c3dcoordsA,1);
            writestring( sprintf( '# Faces for bio cells: %d', length(visCellIndexes) ) );
            for ci=visCellIndexes(:)'
                cellvxs = m.secondlayer.cells(ci).vxs;
                side1indexes = renumberNodes( cellvxs );
                side2indexes = side1indexes + numAsideVxs;
                writestring( sprintf( '# Faces for bio cell %d', ci ) );
                writeface( side1indexes(end:-1:1) );
                writeface( side2indexes );
                for i=1:(length(side1indexes)-1)
                    j = i+1;
                    writeface( [side1indexes([i,j]),side2indexes([j,i])] );
                end
                writeface( [side1indexes([end,1]),side2indexes([1,end])] );
            end

            closearray( 'coordIndex' );

            if INDEXEDCOLOR
                openarray( 'colorIndex' );

                for ci=visCellIndexes(:)'
                    % print color index of cell twice + number of vertexes.
                    writestring( sprintf( '# Color indexes for bio cell %d', ci ) );
                    numfaces = 2 + length( m.secondlayer.cells(ci).vxs );
                    writeindent();
                    fprintf( fid, '%d ', repmat( ci-1, [1,numfaces] ) );
                    fprintf( fid, '\n' );
                end

                closearray( 'colorIndex' );
                openitem( 'color Color' );
                openarray( 'color' );
                colours = m.secondlayer.cellcolor(visCellMap,:);
                writestring( sprintf( '# Cell colors: %d', size(colours,1) ) );
                writearray( '%f', size(colours,2), '', colours' )
                closearray( 'color' );
                closeitem( 'color Color' );
            else
                openarray( 'colorIndex' );
                closearray( 'colorIndex' );
                openitem( 'color Color' );
                openarray( 'color' );
                colours = m.secondlayer.cellcolor(visCellMap,:);
                for ci=visCellIndexes(:)'
                    % print color of cell twice number of vertexes.
                    numfaces = 2*length( m.secondlayer.cells(ci).vxs );
                    writestring( sprintf( '# Colors for bio cell %d', ci ) );
                    writearray( '%f', size(colours,2), '', repmat( colours(ci,:), numfaces, 1 )' );
                end
                closearray( 'color' );
                closeitem( 'color Color' );
            end
            closeitem( 'geometry IndexedFaceSet' );
            closeitem( 'Shape' );
        end
    end
    
    status = fclose( fid )==0;
    
    function writeindent()
        fwrite( fid, indentString );
    end
    
    function writestring( s )
        if isempty(s)
            fwrite( fid, [ s, char(10) ] );
        else
            fwrite( fid, [ indentString, s, char(10) ] );
        end
        linenumber = linenumber+1;
    end
    
    function endline( s )
        fwrite( fid, [ s, char(10) ] );
        linenumber = linenumber+1;
    end
    
    function pushstack( s )
        itemstack{end+1} = s;
        linestack(end+1) = linenumber;
        indentString = repmat( indentUnit, 1, length(itemstack) );
    end

    function popstack( s )
        if ~strcmp( s, itemstack{end} )
            fprintf( 1, '** %s: item ''%d'' on line %d closed by ''%s'' on line %d.\n', ...
                itemstack{end}, linestack(end), s, linenumber );
        end
        itemstack = {itemstack{1:(end-1)}};
        linestack(end) = [];
        indentString = repmat( indentUnit, 1, length(itemstack) );
    end

    function openthing( s, bracket )
        % fwrite( 1, [ indentString, '>> ', s, ' ', bracket, char(10) ] );
        writeindent();
        fwrite( fid, [ s, ' ', bracket, char(10) ] );
        linenumber = linenumber+1;
        pushstack( s );
    end
    
    function openitem( s )
        openthing( s, '{' );
    end
    
    function openarray( s )
        openthing( s, '[' );
    end
    
    function writefield( s )
        writeindent();
        fwrite( fid, [ s, char(10) ] );
        linenumber = linenumber+1;
    end
    
    function writeface( f )
        writeindent();
        fprintf( fid, '%d ', f );
        endline( '-1' );
    end
    
    function writearray( fmt, perline, suffix, data )
        numdata = numel(data);
        numlines = numel(data)/perline;
        for ii=perline:perline:numdata
            writeindent();
            fprintf( fid, [fmt, ' '], data( (ii-perline+1):ii ) );
            fwrite( fid, [ suffix, char(10) ] );
        end
        linenumber = linenumber+numlines;
    end
    
    function closething( s, bracket )
        popstack( s )
        writeindent();
        fwrite( fid, [ bracket, char(10) ] );
        linenumber = linenumber+1;
        % fwrite( 1, [ indentString, '<< ', s, ' ', bracket, char(10) ] );
    end

    function closeitem( s )
        closething( s, '}' )
    end

    function closearray( s )
        closething( s, ']' )
    end

    function writeStdAppearance( thecolor )
        openitem( 'appearance Appearance' );
        openitem( 'material Material' );
        writefield( ['diffuseColor', sprintf( ' %g', thecolor ) ] );
        closeitem( 'material Material' );
        closeitem( 'appearance Appearance' );
    end

    function openShape( pervertex, thecolor, creaseAngle, alph )
        openitem( 'Shape' );
        writeStdAppearance( thecolor );
        openitem( 'geometry IndexedFaceSet' );
        writefield( 'solid TRUE' );
        writefield( 'convex FALSE' );
        writefield( ['creaseAngle ', sprintf( '%g', creaseAngle ), '  # Radians. 0 makes all edges sharp.'] );
        if alph < 1
            writefield( ['transparency ', sprintf( '%g', alph )] );
        end
        writefield( [ 'colorPerVertex ', boolchar(pervertex,'TRUE','FALSE') ] );
        openitem( 'coord Coordinate' );
        openarray( 'point' );
    end
end



% Functions to assist in extracting parameters from the VRMLparams
% dialog.

function t = getTextForButton( b )
    t = '';
    if isempty(b), return; end
    ud = get(b,'UserData');
    if isempty(ud) || ~isstruct(b) || ~isfield(b,'text')
        return;
    end
    h = ud.texthandle;
    t = get( h, 'String' );
end

function [d,ok] = getDoubleForButton( b )
    t = getTextForButton( b );
    if isempty(t)
        ok = false;
        return;
    end
    [d,ok] = getDoubleFromString( '', t );
end

