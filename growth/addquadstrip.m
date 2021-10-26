function m = addquadstrip( m, is, js )
    numcells = size( m.tricellvxs, 1 );
    striplength = length(is);
    numnewcells = (striplength-1)*2;
    m.tricellvxs( (numcells+1):(numcells+numnewcells), : ) = ...
        [ [ is(1:(striplength-1))', is(2:striplength)', js(1:(striplength-1))' ]; ...
          [ is(2:striplength)', js(2:striplength)', js(1:(striplength-1))' ] ...
        ];
end
