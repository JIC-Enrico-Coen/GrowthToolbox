function printstrings( fid, strings )
    if iscell( strings )
        for i=1:length(strings)
            fprintf( fid, '%s\n', strings{i} );
        end
    else
        fwrite( fid, strings );
    end
end

