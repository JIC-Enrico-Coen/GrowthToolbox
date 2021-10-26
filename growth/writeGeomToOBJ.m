function ok = writeGeomToOBJ( g, file )
%ok = writeGeomToOBJ( g, file )

    fid = openfilewrite( file, 'obj' );
    if fid==-1
        ok = false;
        return;
    end
    
    if ~isempty( g.vxs )
        fprintf( fid, 'v %g %g %g\n', g.vxs' );
    end
    
    if ~isempty( g.facevxs )
        fprintf( fid, '\n' );
        vxsPerFace = size( g.facevxs,2) - sum( isnan(g.facevxs), 2 );
        numsizes = unique( vxsPerFace );
        for i=1:length(numsizes)
            sz = numsizes(i);
            formatstring = [ 'f', repmat( ' %g', 1, sz ), '\n' ];
            fprintf( fid, formatstring, g.facevxs( vxsPerFace==sz, 1:sz )' + 1 );
        end
    end
    
    if ~isempty( g.vxcolor )
        fprintf( fid, '\n' );
        fprintf( fid, 'vc %g %g %g\n', g.color(g.vxcolor+1,:)' );
    end
    
    ok = fclose(fid)==0;
end