function status = writemeshmsr( filedir, filename, m, varargin )
%status = writemeshmsr( filedir, filename, m )
%    Write the mesh to a file in MSR format.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, ...
            'surface', false, ...
            'throughfaces', true, ...
            'mesh', true, ...
            'cells', true, ...
            'cellcolor', m.secondlayer.cellcolor );

    fullfilename = fullfile( filedir, filename );
    if ~endsWithM(fullfilename,'.msr')
        fullfilename = strcat(fullfilename,'.msr');
    end
    fid = fopen(fullfilename,'w');
    if fid==0
        fprintf( 1, 'Cannot write to file %s.\n', fullfilename );
        status = 0;
        return;
    end
    MSRMajorVersion = 1;
    MSRMinorVersion = 2;
    fprintf( fid, 'MSR_VERSION = %d.%d\n', MSRMajorVersion, MSRMinorVersion );
    fprintf( fid, 'ORIGINALDATA = PATH %s\n', enquote( getModelDir( m ) ) );
    fprintf( fid, 'ALGORITHM = ''GFtbox %d''\n', GFtboxRevision() );
    
    lengthunit = lower( m.globalProps.distunitname );
    switch lengthunit
        case 'mm'
            scale = 0.001;
        case 'cm'
            scale = 0.01;
        case { 'm', 'metre', 'metres' }
            scale = 1;
        case 'micron'
            scale = 0.000001;
        case { 'in', 'inch' }
            scale = 0.0254;
        otherwise
            scale = 1;
    end
    fprintf( fid, 'SCALE = %.6g %.6g %.6g\n', scale, scale, scale );
    timeunit = lower( m.globalProps.timeunitname );
    switch timeunit
        case { 'sec', 'second' }
            timescale = 1/3600;
        case { 'min', 'minute' }
            timescale = 1/60;
        case { 'hr', 'hour' }
            timescale = 1;
        case { 'd', 'day' }
            timescale = 24;
        otherwise
            timescale = 1;
    end
    numnodes = size(m.nodes,1);
    
    fprintf( fid, 'TIME = %g\n', m.globalDynamicProps.currenttime * timescale );
    
    objectcount = 0;
    if s.mesh
        objectcount = objectcount+2;
    end
    if s.cells
        objectcount = objectcount+1;
    end
    fprintf( fid, '\nOBJECTCOUNT = %d\n\n', objectcount );
    
    if isempty(m.globalProps.modelname)
        modelname = 'untitled';
    else
        modelname = m.globalProps.modelname;
    end
    fprintf( fid, 'OBJECT = %s\n', enquote(modelname) );
    fprintf( fid, 'VERTCOUNT = %d\n', size(m.nodes,1) );
    fprintf( fid, 'VERT = %g %g %g\n', m.nodes' );
    
    fprintf( fid, '\nEDGECOUNT = %d\n', size(m.edgeends,1) );
    fprintf( fid, 'EDGE = %d %d\n', m.edgeends'-1 );
    
    fprintf( fid, '\nFACECOUNT = %d\n', size(m.tricellvxs,1) );
    fprintf( fid, 'FACE = %g %g %g\n', m.tricellvxs'-1 );
    
    fwrite( fid, 'VERTMGENNAMES =' );
    ss = enquote( m.mgenIndexToName );
    fprintf( fid, ' %s', ss{:} );
    fwrite( fid, char(10) );
    fprintf( fid, [ 'VERTMGEN =', ...
                    repmat( ' %g', 1, size(m.morphogens,2) ), '\n' ], ...
                  m.morphogens' );
    
    fprintf( fid, '\nFACEGROWTHDT = %g\n', m.globalProps.timestep );
    resultantstrainPerFE = (m.outputs.actualstrain.A + m.outputs.actualstrain.B)/2;
    if m.globalProps.timestep > 0
        resultantstrainPerFE = resultantstrainPerFE*m.globalProps.timestep;
    end
    [components,frames] = tensorsToComponents( resultantstrainPerFE, m.cellFrames, true );
    fprintf( fid, 'FACEGROWTH = %g %g %g %g %g\n', ...
        [ components(:,[1 2])'; permute( frames(:,1,:), [1,3,2] ) ] );


    fprintf( fid, '\nOBJECT = %s\n', enquote( [ modelname, '-solid' ] ) );
    fprintf( fid, 'VERTCOUNT = %d\n', size(m.prismnodes,1) );
    fprintf( fid, 'VERT = %g %g %g\n', m.prismnodes' );
    
    aa = (m.edgeends-1)*2;
    aa = [ aa, aa+1 ];
    totalEdges = size(aa,1)*3 + numnodes;
    fprintf( fid, '\nEDGECOUNT = %d\n', totalEdges );
    fprintf( fid, '\n# A side: %d edges\n', size(aa,1) );
    fprintf( fid, 'EDGE = %d %d\n', aa(:,[1 2])' );
    fprintf( fid, '\n# B side: %d edges\n', size(aa,1) );
    fprintf( fid, 'EDGE = %d %d\n', aa(:,[3 4])' );
    fprintf( fid, '\n# Through edges: %d edges\n', numnodes );
    fprintf( fid, 'EDGE = %d %d\n', [ 0:2:(2*(numnodes-1)); 1:2:(2*numnodes) ] );
    fprintf( fid, '\n# Diagonal through edges: %d edges\n', size(aa,1) );
    fprintf( fid, 'EDGE = %d %d\n', aa(:,[2 3])' );

    tt = (m.tricellvxs-1)'*2;
    totalFaces = (size(tt,2) + size(aa,1))*2;
    fprintf( fid, '\nFACECOUNT = %d\n', totalFaces );
    fprintf( fid, '\n# A side: %d faces\n', size(tt,2) );
    fprintf( fid, 'FACE = %d %d %d\n', tt );
    fprintf( fid, '\n# B side: %d faces\n', size(tt,2) );
    fprintf( fid, 'FACE = %d %d %d\n', tt+1 );
    if s.throughfaces
        fprintf( fid, '\n# Through faces: %d faces\n', size(aa,1)*2 );
        throughFaces = reshape( aa( :, [1 2 3 2 3 4] )', 3, [] );
        fprintf( fid, 'FACE = %d %d %d\n', throughFaces );
    end

    if s.cells && hasNonemptySecondLayer( m )
        fprintf( fid, '\nOBJECT = %s\n', enquote( [ modelname '-cells' ] ) );
        fprintf( fid, 'VERTCOUNT = %d\n', size(m.secondlayer.cell3dcoords,1) );
        fprintf( fid, 'VERT = %g %g %g\n', m.secondlayer.cell3dcoords' );

        fprintf( fid, '\nEDGECOUNT = %d\n', size(m.secondlayer.edges,1) );
        fprintf( fid, 'EDGE = %d %d\n', m.secondlayer.edges(:,[1 2])'-1 );

        fprintf( fid, '\nFACECOUNT = %d\n', length(m.secondlayer.cells) );
        for i=1:length(m.secondlayer.cells)
            fwrite( fid, 'FACE =' );
            fprintf( fid, ' %g', m.secondlayer.cells(i).vxs'-1 );
            fwrite( fid, char(10) );
        end
        
        havecellcolor = (size( s.cellcolor, 1 )==length(m.secondlayer.cells)) ...
            && (size( s.cellcolor, 2 )==3) && (length(size( s.cellcolor ))==2);
        if havecellcolor
            fwrite( fid, char(10) );
            fprintf( fid, 'FACECOLOUR =  %g %g %g\n', s.cellcolor' );
        end
    end
    
    fclose( fid );
end

function s = enquote( s )
    if iscell(s)
        for i=1:numel(s)
            s{i} = enquote( s{i} );
        end
    else
        s = [ '''', regexprep( s, '''', '''''' ), '''' ];
    end
end
