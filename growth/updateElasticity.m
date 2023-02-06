function m = updateElasticity( m )
%     if usesNewFEs( m )
%         numelements = size(m.FEsets(1).fevxs,1);
%     else
%         numelements = size( m.tricellvxs, 1 );
%     end

    if isfield( m, 'cellbulkmodulus' )
        m.globalProps.D = IsotropicStiffnessMatrix( ...
            m.cellbulkmodulus, m.cellpoisson, m.globalProps.plasticGrowth );
        m.globalProps.C = IsotropicComplianceMatrix( ...
            m.cellbulkmodulus, m.cellpoisson, m.globalProps.plasticGrowth );
    else
        m.globalProps.D = IsotropicStiffnessMatrix( ...
            m.globalProps.bulkmodulus, m.globalProps.poissonsRatio, m.globalProps.plasticGrowth );
        m.globalProps.C = IsotropicComplianceMatrix( ...
            m.globalProps.bulkmodulus, m.globalProps.poissonsRatio, m.globalProps.plasticGrowth );
    end
    m.cellstiffness = m.globalProps.D; % IsotropicStiffnessMatrix( m.cellbulkmodulus, m.cellpoisson );
    if size(m.cellstiffness,3)==1
        m.cellstiffness = repmat( m.cellstiffness, 1, 1, getNumberOfFEs(m) );
    end
end
