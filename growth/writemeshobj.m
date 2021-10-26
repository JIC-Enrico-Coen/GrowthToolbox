function ok = writemeshobj( filedir, filename, m, varargin )
%writemesh( mesh, filedir, filename, surface, minimal )
%    Write the mesh to a file in extended OBJ format.
% If minimal is true (default is false), then only the nodes and cells will
% be written, otherwise everything in the mesh is written.
% If surface and minimal are both true, the resulting file should be a
% standard OBJ file, readable by any software that reads OBJ files.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, ...
            'surface', false, ...
            'minimal', false, ...
            'throughfaces', true, ...
            'mesh', true, ...
            'cells', true, ...
            'cellcolor', m.secondlayer.cellcolor, ...
            'bbox', [] );
%     ok = checkcommandargs( mfilename(), s, 'exact', ...
%         'surface', 'minimal', 'throughfaces', 'mesh', 'cells', 'bbox' );
%     if ~ok, return; end
    
    fullfilename = fullfile( filedir, filename );
    if ~endsWithM(fullfilename,'.obj')
        fullfilename = strcat(fullfilename,'.obj');
    end
    
    if isVolumetricMesh( m )
        g = meshTo3DModel( m );
        ok = writeGeomToOBJ( g, fullfilename );
        return;
    end
    
    
    fid = fopen(fullfilename,'w');
    if fid==0
        fprintf( 1, 'Cannot write to file %s.\n', fullfilename );
        ok = false;
        return;
    end
    
    m = makeTRIvalid( m );
    
    fprintf( fid, '# File written by Growth Toolbox at %s.\n', ...
        datestr(clock) );
    fprintf( fid, '# Mesh iteration %d, time stamp %.3f.\n\n', ...
        m.globalDynamicProps.currentIter, m.globalDynamicProps.currenttime );
    
    mc = meshColors(m);
    mcheader = '';
    mcprefix = '';
    if ~isempty(mc)
        if m.plotdata.pervertex
            mcheader = 'Vertex colors';
            mcprefix = 'vc';
        else
            mcheader = 'Face colors';
            mcprefix = 'fc';
        end
    end
    numMgens = size(m.morphogens,2);
    mgeninfo = m.morphogens;
    maxmgens = max(mgeninfo,[],1);
    notzeros = find(maxmgens ~= 0);
    mgeninfo(:,notzeros) = mgeninfo(:,notzeros) ./ ...
        repmat( maxmgens(notzeros), size(m.morphogens,1), 1 );
    
    vxcount = 0;
    facecount = 0;
    newvxcount = vxcount;
    newfacecount = facecount;
    if s.mesh
        
        if s.surface
            % Vertex positions.
            pts = fitToBbox( m.nodes, s.bbox );
            writearray( fid, pts, 'v', '%f %f %f' );
            newvxcount = newvxcount + size(pts,1);

            % Faces.
%             writemesharray( fid, m, 'tricellvxs', 'f', '%d %d %d' );
            writearray( fid, m.tricellvxs + vxcount, 'f', '%d %d %d', 0, 'tricellvxs' )
            newfacecount = newfacecount + size(m.tricellvxs,1);

            % Vertex or face colours.
            if ~isempty(mc)
                writearray( fid, mc, mcprefix, '%f %f %f', 0, mcheader );
            end

            if ~s.minimal
                % Morphogen names.
                writeMgenNames( fid, m.mgenIndexToName );

                % Morphogen values.
                mgenfmt = [ '%f', repeatString( ' %f', numMgens-1 ) ];
                writearray( fid, mgeninfo, 'm', mgenfmt, 0, 'Morphogens' );
            end
        else
            % Vertex positions.
            pts = fitToBbox( m.prismnodes, s.bbox );
            writearray( fid, pts, 'v', '%f %f %f' );
            newvxcount = newvxcount + size(pts,1);

            % Faces.
            if s.throughfaces
                throughedges = 1:size(m.edgecells,1);
            else
                throughedges = find(m.edgecells(:,2)==0);
            end
            throughcells = m.edgecells(throughedges,1);
            bsidevxs = m.tricellvxs*2;
            asidevxs = bsidevxs-1;
            writearray( fid, asidevxs(:,[1 3 2]) + vxcount, 'f', '%d %d %d', 0, 'A side' );
            newfacecount = newfacecount + size(asidevxs,1);
            writearray( fid, bsidevxs + vxcount, 'f', '%d %d %d', 0, 'B side' );
            newfacecount = newfacecount + size(bsidevxs,1);
            if ~isempty(throughedges)
                if s.throughfaces
                    fprintf( fid, '# Through faces\n' );
                else
                    fprintf( fid, '# Rim faces\n' );
                end
                for i=throughedges(:)' % size(mesh.edgeends,1)
                    c = m.edgecells(i,1);
                    % find edge i in cell c
                    cei = find( m.celledges(c,:)==i, 1 );
                    vs = m.tricellvxs( c, othersOf3( cei ) );
                    % vs contains the two ends of edge i, in positive order.  These
                    % are the same vertexes as mesh.edgeends(i,:), but the latter
                    % are in arbitrary order.
                    bvs = vs*2 + vxcount;
                    avs = bvs-1 + vxcount;
                    fprintf( fid, 'f %d %d %d\nf %d %d %d\n', ...
                        avs(1), avs(2), bvs(2), ... % The A (bottom) side in negative order.
                        avs(1), bvs(2), bvs(1) ); % The B (top) side in positive order.
                end
                newfacecount = newfacecount + 2*numel(throughedges);
            end

            % Vertex or face colours.
            if ~isempty(mc) && ~isempty(mcprefix)
                if m.plotdata.pervertex
                    mc = reshape( [mc'; mc'], 3, [] )';
                else
                    throughcolors = mc(throughcells,:);
                    throughcolors = reshape( [throughcolors';throughcolors'], 3, [] )';
                    mc = [mc; mc; throughcolors];
                end
                writearray( fid, mc, mcprefix, '%f %f %f', 0, 'Vertex colors' );
            end

            if ~s.minimal
                % Morphogen names.
                writeMgenNames( fid, m.mgenIndexToName );

                % Morphogen values.
                mgeninfo = reshape( [mgeninfo'; mgeninfo'], numMgens, [] )';
                mgenfmt = [ '%f', repeatString( ' %f', numMgens-1 ) ];
                writearray( fid, mgeninfo, 'm', mgenfmt, 0, 'Morphogens' );
            end
        end
    end
    
    vxcount = newvxcount;
    facecount = newfacecount;
    
    if s.cells && hasNonemptySecondLayer( m )
        writearray( fid, m.secondlayer.cell3dcoords, 'v', '%f %f %f', 0, 'Cell vertexes' );
        newvxcount = newvxcount + size(m.secondlayer.cell3dcoords,1);
        for i=1:length(m.secondlayer.cells)
            fwrite( fid, 'f' );
            fprintf( fid, ' %d', m.secondlayer.cells(i).vxs + vxcount );
            fwrite( fid, char(10) );
        end
        fprintf( fid, 'vc %f %f %f\n', rand( length(m.secondlayer.cell3dcoords), 3 ) );
    end
    
    vxcount = newvxcount;
    facecount = newfacecount;
    
    if ~s.minimal
        globFields = fieldnames( m.globalProps );
        for i=1:length(globFields)
            if isnumeric( m.globalProps.(globFields{i}) )
                writeGlobalProp( fid, m, globFields{i} );
            end
        end
        fprintf( fid, '\n' );

        writemesharray( fid, m, 'celllabel', 'celllabel', '%d', 1 );
        morphogenFormat = [ '%f', repmat( ' %f', 1, size(m.morphogens,2)-1 ) ];;
        writemesharray( fid, m, 'morphogens', 'g', morphogenFormat );
        writemesharray( fid, m, 'morphogenclamp', 'gcl', morphogenFormat );
    end

    ok = fclose(fid)==0;
    if ~ok
        fprintf( 1, 'Could not close file %s after writing mesh.\n', ...
            fullfilename );
    end
end

function writeMgenNames( fid, names )
    fprintf( fid, '# Morphogen names\nmn' );
    for i=1:length(names)
        fprintf( fid, ' %s', names{i} );
    end
    fprintf( fid, '\n\n' );
end

function writeGlobalProp( fid, mesh, globField )
    if isfield( mesh.globalProps, globField )
        fprintf( fid, '%s', globField );
        fprintf( fid, ' %f', mesh.globalProps.(globField) );
        fprintf( fid, '\n' );
    end
end

function writearray( fid, array, name, fmt, indexed, message )
    if (nargin<4) || isempty(fmt)
        fmt = '%f';
    end
    if (nargin<5) || isempty(indexed)
        indexed = 0;
    end
    if (nargin<6) || isempty(message)
        message = [ '# ', name ];
    end
    fprintf( fid, '# %s\n', message );
    if indexed
        fprintf( fid, [ name, ' %d ', fmt, '\n' ], [ (1:size(array,1))', array ]' );
    else
        fprintf( fid, [ name, ' ', fmt, '\n' ], array' );
    end
    fprintf( fid, '\n' );
end

function writemesharray( fid, mesh, field, name, fmt, indexed, message )
    if isfield( mesh, field )
        if (nargin<4) || isempty(name)
            name = field;
        end
        if (nargin<5) || isempty(fmt)
            fmt = '%f';
        end
        if (nargin<6) || isempty(indexed)
            indexed = 0;
        end
        if (nargin<7) || isempty(message)
            message = name;
        end
        writearray( fid, mesh.(field), name, fmt, indexed, message )
    end
end

