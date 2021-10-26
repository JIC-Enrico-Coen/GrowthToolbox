function m = updateMgenElasticity( m )
% NEVER USED
    m.cellstiffness = IsotropicStiffnessMatrix( m.cellbulkmodulus, m.cellpoisson, m.globalProps.plasticGrowth );
end
