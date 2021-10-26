function s = makeCitations( citerecords, isbibtex )
    s = '';
    if ~isempty( citerecords )
        s = makeCitation( citerecords{1}, isbibtex );
    end
    if isbibtex
        recordsep = [ char(10) char(10) ];
    else
        recordsep = [ char(10) char(10) char(10) ];
    end
    for i=2:length(citerecords)
        s = [ s, recordsep, makeCitation( citerecords{i}, isbibtex ) ];
    end
end