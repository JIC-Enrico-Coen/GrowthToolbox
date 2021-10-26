function ok = isT4mesh( m )
    ok = isfield(m,'FEsets') && (length(m.FEsets) == 1) && isT4FE( m.FEsets.fe );
end
