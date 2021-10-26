function m = updateElasticity( m )
%     if usesNewFEs( m )
%         numelements = size(m.FEsets(1).fevxs,1);
%     else
%         numelements = size( m.tricellvxs, 1 );
%     end

    m.globalProps.D = IsotropicStiffnessMatrix( ...
        m.globalProps.bulkmodulus, m.globalProps.poissonsRatio, m.globalProps.plasticGrowth );
    m.cellstiffness = m.globalProps.D; % IsotropicStiffnessMatrix( m.cellbulkmodulus, m.cellpoisson );
    m.globalProps.C = IsotropicComplianceMatrix( ...
        m.globalProps.bulkmodulus, m.globalProps.poissonsRatio, m.globalProps.plasticGrowth );
    if size(m.cellstiffness,3)==1
        m.cellstiffness = repmat( m.cellstiffness, 1, 1, getNumberOfFEs(m) );
    end
end
