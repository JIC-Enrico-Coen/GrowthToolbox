function has = hasNonemptySecondLayer( m )
    has = hasSecondLayer( m ) && ~isempty( m.secondlayer.cells ) && ~isempty( m.secondlayer.vxFEMcell );
end
