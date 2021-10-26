function writeObjRaggedArray( fid, prefix, a )
    if isempty(a)
        return;
    end
    rowlengths = sum(isfinite(a),2);
    lengths = unique(rowlengths);
    for i=1:length(lengths)
        len = lengths(i);
        writeObjRaggedArray( fid, prefix, a( rowlengths==len, 1:len ) );
    end
end