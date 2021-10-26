function eraseFileContents( filename )
    fid = fopen( filename, 'w' );
    if fid ~= -1
        fclose( fid );
    end
end
