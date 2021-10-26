function forcepixelunits( figname )
    try
        f = openfig(figname);
    catch e
        fprintf( 1, 'Cannot open figure %s:\n    %s\n', figname, e.message );
        return;
    end
    ch = findall(f); 
    set(f,'Units','pixels'); 
    for k = 1:length(ch) 
        if isprop(ch(k),'Units') 
            set(ch(k),'Units','pixels'); 
        end 
    end 
    hgsave(f,figname);
    close( f );
end
