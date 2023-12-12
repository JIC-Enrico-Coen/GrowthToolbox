function has = hasSecondLayer( m )
    has = ~isempty(m) && isfield( m, 'secondlayer' ) && isfield( m.secondlayer, 'cells' ) && ~isempty( m.secondlayer.cells );
end
