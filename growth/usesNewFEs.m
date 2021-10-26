function uses = usesNewFEs( m )
    uses = ~isempty(m) && ~isfield( m, 'nodes' ); % isfield( m, 'FEnodes' ) && ~isempty(m.FEnodes);
end
