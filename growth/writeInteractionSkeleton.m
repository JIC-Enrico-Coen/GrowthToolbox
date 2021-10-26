function ok = writeInteractionSkeleton( fullname, m )
    ok = true;
    [pathname, filename, ext] = fileparts(fullname);
    if exist( fullname, 'file' )
        rewriteInteractionSkeleton( m, filename, pathname, '' );
        return;
    end
    fid = fopen( fullname, 'w' );
    if fid == -1
        errordlg( ...
            { [ 'Cannot create file ', filename, ext ], ...
              [ 'in ' pathname ] }, ...
            'Interaction function' );
        ok = false;
        return;
    end
    
    generateInteractionFunction( fid, m );
    fclose( fid );
    m.rewriteIFneeded = false;

    m = resetInteractionHandle( m, '' );
end
