function is = isNonemptySecondLayer( s )
    is = ~isempty( s ) ...
         && isfield( s, 'cells' ) ...
         && ~isempty( s.cells ) ...
         && isfield( s, 'vxFEMcell' ) ...
         && ~isempty( s.vxFEMcell );
end
