function writeObjArray( fid, prefix, a )
    if isempty(a)
        return;
    end
    formatString = [ '%s', repmat( ' %g', 1, size(a,2) ), '\n' ];
    for i=1:size(a,1)
        fprintf( fid, formatString, prefix, a(i,:) );
    end
end