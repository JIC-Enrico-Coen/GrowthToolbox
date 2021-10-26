function borderCells = borderingCells( m, cis )
    borderEdges = m.celledges( cis, : );
    borderCells = reshape( m.edgecells(borderEdges,:), 1, [] );
    borderCells = borderCells(borderCells>0);
end
