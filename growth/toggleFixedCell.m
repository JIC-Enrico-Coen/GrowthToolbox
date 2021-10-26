function m = toggleFixedCell( m, ci )
    m.celldata(ci) = fixCell( m.celldata(ci) );
    m.saved = 0;
end
