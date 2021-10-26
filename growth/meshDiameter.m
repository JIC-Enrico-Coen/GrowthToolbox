function d = meshDiameter( m )
    mn = min(m.nodes,[],1);
    mx = max(m.nodes,[],1);
    d = max( abs( mx - mn ) );
end
