function m = addtrianglestrip( m, is, js )
    numcells = size( m.tricellvxs, 1 );
    nis = length(is);
    njs = length(js);
    numnewcells = nis + njs - 2;
    m.tricellvxs( (numcells+1):(numcells+numnewcells), : ) = ...
        [ [ is(1:(nis-1)), is(2:nis), js(1:(nis-1)) ], ...
          [ is(2:njs), js(2:njs), js(1:(njs-1)) ] ...
        ];
end
