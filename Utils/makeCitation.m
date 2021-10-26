function s = makeCitation( citerecord, isbibtex )
    articlefields = { 'author', 'title', 'journal', 'year', 'volume', 'number', 'pages', 'url', 'note' };
    bibtex.article = articlefields;
    type = citerecord.type;
    if isfield( bibtex, type )
        fields = bibtex.(type);
        if isbibtex
            s = [ '@', type, '{ ', citerecord.id, ',', char(10) ];
            for i=1:length(fields)
                f = fields{i}; 
                if isfield( citerecord, f ) && ~isempty(citerecord.(f))
                    s = [ s, '    ', f, ' = "', citerecord.(f), '",', char(10) ];
                end
            end
            s = [ s, '}' ];
        else
            fns = fieldnames(citerecord);
            for i=1:length(fns)
                fn = fns{i};
                citerecord.(fn) = regexprep( citerecord.(fn), '[{}]', '' );
            end
            s = regexprep( citerecord.author, ' and ', ', ' );
            if nonempty( citerecord, 'title' )
                s = [ s, ', "', citerecord.title, '"' ];
            end
            if nonempty( citerecord, 'journal' )
                s = [ s, ', ', citerecord.journal ];
            end
            if nonempty( citerecord, 'year' )
                s = [ s, ', ', citerecord.year ];
            end
            if nonempty( citerecord, 'volume' )
                s = [ s, ', vol.', citerecord.volume ];
            end
            if nonempty( citerecord, 'number' )
                s = [ s, ', no.', citerecord.number ];
            end
            if nonempty( citerecord, 'url' )
                s = [ s, ', ', citerecord.url ];
            end
            s = [ s, '.' ];
            if nonempty( citerecord, 'note' )
                s = [ s, char(10), char(10), citerecord.note, '.' ];
            end
        end
    end
end

function ne = nonempty( s, field )
    ne = isfield( s, field ) && ~isempty(s.(field));
end
