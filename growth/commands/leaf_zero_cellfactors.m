function m = leaf_zero_cellfactors( m )
%m = leaf_zero_cellfactors( m )
%   Set all cellular values to zero everywhere.

    if isempty(m), return; end
    if isempty(m.secondlayer)
        return;
    end
    m.secondlayer.cellvalues(:) = 0;
end
