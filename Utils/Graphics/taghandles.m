function taghandles( hh, tag, digits )
    if length(hh)==1
        hh.Tag = tag;
    else
        for i=1:length(hh)
            hh(i).Tag = sprintf( '%s%0*d', tag, digits, i );
        end
    end
end