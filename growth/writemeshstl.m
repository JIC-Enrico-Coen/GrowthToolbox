function status = writemeshstl( filedir, filename, m )
%status = writemeshstl( filedir, filename, m )
%    Write the mesh to a file in STL format.

    fullfilename = fullfile( filedir, filename );
    if ~endsWithM(fullfilename,'.stl')
        fullfilename = strcat(fullfilename,'.stl');
    end
    fid = fopen(fullfilename,'w');
    if fid==0
        fprintf( 1, 'Cannot write to file %s.\n', fullfilename );
        status = 0;
        return;
    end

    name = makeIFname( m.globalProps.modelname );
    fprintf( fid, 'solid %s\n', name );
    for i=1:size(m.tricellvxs,1)
        % Write the i'th finite element.
        iv = m.tricellvxs(i,:)*2;
        iv = [iv-1; iv];
        vxs = m.prismnodes( iv(:), : );
        writeface( fid, vxs( [2 4 6], : ) );
        writeface( fid, vxs( [1 5 3], : ) );
    end
    borderedges = find( m.edgecells(:,2)==0 );
    for i=1:length(borderedges)
        ei = borderedges(i);
        ec = m.edgecells(ei,1);
        ece = m.celledges( ec, : );
        ecv = m.tricellvxs( ec, : );
        eic = find( ece==ei, 1 );
        eic = mod(eic,3);
        vi1 = ecv(eic+1);
        vi2 = ecv(mod(eic+1,3)+1);
        iv = [vi1 vi2]*2;
        
        
        iv1 = 2*m.edgeends( borderedges(i), : );
        if any( sort(iv) ~= sort(iv1) )
            error('foo');
        end
        iv = [iv-1; iv];
        vxs = m.prismnodes( iv(:), : );
        writeface( fid, vxs( [1 2 3], : ) );
        writeface( fid, vxs( [3 2 4], : ) );
    end
    
    fprintf( fid, 'endsolid %s\n', name );
    fclose( fid );
end

function status = writemeshstlA( filedir, filename, m )
%status = writemeshstl( filedir, filename, m )
%    Write the mesh to a file in STL format.

    fullfilename = fullfile( filedir, filename );
    if ~endsWithM(fullfilename,'.stl')
        fullfilename = strcat(fullfilename,'.stl');
    end
    fid = fopen(fullfilename,'w');
    if fid==0
        fprintf( 1, 'Cannot write to file %s.\n', fullfilename );
        status = 0;
        return;
    end

    name = makeIFname( m.globalProps.modelname );
    fprintf( fid, 'solid %s\n', name );
    for i=1:size(m.tricellvxs,1)
        % Write the i'th finite element.
        iv = m.tricellvxs(i,:)*2;
        iv = [iv; iv-1];
        vxs = m.prismnodes( iv(:), : );
        writetetrahedron( fid, vxs, [2 4 6 1] );
        writetetrahedron( fid, vxs, [1 3 4 5] );
        writetetrahedron( fid, vxs, [1 5 4 6] );
    end
    
    fprintf( fid, 'endsolid %s\n', name );
    fclose( fid );
end

function writetetrahedron( fid, vxs, vi )
    writeface( fid, vxs( vi([1 2 3]), : ) );
    writeface( fid, vxs( vi([1 3 4]), : ) );
    writeface( fid, vxs( vi([4 2 1]), : ) );
    writeface( fid, vxs( vi([4 3 2]), : ) );
end

function writeface( fid, vxs )
    n = trinormal( vxs );
    n = n/norm(n);
    fprintf( fid, 'facet normal %g %g %g\n', n );
    fprintf( fid, 'outer loop\n' );
    fprintf( fid, 'vertex %g %g %g\n', vxs' );
    fprintf( fid, 'endloop\n' );
    fprintf( fid, 'endfacet\n' );
end
