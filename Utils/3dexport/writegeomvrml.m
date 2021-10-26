function status = writegeomvrml( g, filename, cameraparams, recentre )
%status = writegeomvrml( g, filename, cameraparams, recentre )
%   Export the geometry to VRML 97 format.

    if isempty(g)
        return;
    end
    if nargin < 4
        recentre = true;
    end
    vxs = g.vxs;
    facevxs = g.facevxs;
    facevxs(:,end+1) = -1;
    facevxs = reshape( facevxs', 1, [] );
    facevxsnans = facevxs == -1;
    if any(facevxsnans)
        dropnans = [false, facevxsnans(1:(end-1)) & facevxsnans(2:end)];
        facevxs(dropnans) = [];
        facevxsnans = facevxs == -1;
    end
    
    creaseAngle = 1.0;  % radians
    
    maxvxs = max( vxs, [], 1 );
    minvxs = min( vxs, [], 1 );
    
    if recentre
        centre = (minvxs + maxvxs)/2;
        vxs = vxs - repmat( centre, size(vxs,1), 1 );
    else
        centre = [0 0 0];
    end
    
    indentUnit = '    ';
    indentString = '';
    linenumber = 0;
    itemstack = {};
    linestack = [];

    fid = fopen(filename,'w');
    if fid==0
        fprintf( 1, 'Cannot write to file %s.\n', filename );
        status = 0;
        return;
    end
    
    mc = g.color;
    pervertex = ~isempty( g.vxcolor );
    
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
    writeVRMLViewpoints( fid, cameraparams, 1, centre )
    openShape( pervertex, thecolor, creaseAngle );

    % Vertex coordinates.
    writestring( sprintf( '# Mesh vertexes: %d items\n', size(vxs,1) ) );
    writearray( '%f', 3, '', vxs' );
    clear vxs
        
    closearray( 'point' );
    closeitem( 'coord Coordinate' );
    openarray( 'coordIndex' );

    % Faces.
    writestring( sprintf( '# Polygons: %d items\n', sum(facevxsnans) ) );
    ends = [0 find(facevxsnans)];
    for i=1:(length(ends)-1)
        fwrite( fid, '           ' );
        fprintf( fid, ' %d', facevxs( (ends(i)+1):ends(i+1) ) );
        fprintf( fid, '\n' );
    end
    
    linenumber = linenumber + 2;
    
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
        itemstack = itemstack(1:(end-1));
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

    function writeStdAppearance( color )
        openitem( 'appearance Appearance' );
        openitem( 'material Material' );
        writefield( ['diffuseColor', sprintf( ' %g', color ) ] );
        closeitem( 'material Material' );
        closeitem( 'appearance Appearance' );
    end

    function openShape( pervertex, color, creaseAngle )
        openitem( 'Shape' );
        writeStdAppearance( color );
        openitem( 'geometry IndexedFaceSet' );
        writefield( 'solid TRUE' );
        writefield( 'convex FALSE' );
        writefield( ['creaseAngle ', sprintf( '%g', creaseAngle ), '  # radians'] );
        writefield( [ 'colorPerVertex ', boolchar(pervertex,'TRUE','FALSE') ] );
        openitem( 'coord Coordinate' );
        openarray( 'point' );
    end
end

