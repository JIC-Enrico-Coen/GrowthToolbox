function cis = cellneighbours( m, ci )
    cis = othercell( m, ci, m.celledges( ci, : ) );
end
