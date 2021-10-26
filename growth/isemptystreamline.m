function empty = isemptystreamline( s )
    empty = false( length(s), 1 );
    for i=1:length(s)
        empty(i) = isempty( s(i).vxcellindex );
    end
end
