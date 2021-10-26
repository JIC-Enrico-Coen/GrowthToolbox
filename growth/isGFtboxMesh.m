function is = isGFtboxMesh( m )
    is = isfield( m, 'morphogens' ) && isfield( m, 'globalProps' );
end
