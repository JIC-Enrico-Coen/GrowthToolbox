function is = isNonemptySecondLayer( s )
    is = ~isempty( s ) && ~isempty( s.cells )&& ~isempty( s.vxFEMcell );
end
