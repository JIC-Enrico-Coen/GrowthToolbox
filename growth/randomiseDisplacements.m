function d = randomiseDisplacements( m )
    if usesNewFEs( m )
        meshsize = max( max(m.FEnodes,[],1) - min(m.FEnodes,[],1) );
        meshsize = meshsize / getNumberOfFEs( m )^(1/3);
    else
        meshsize = max( max(m.nodes,[],1) - min(m.nodes,[],1) );
        meshsize = meshsize / getNumberOfFEs( m )^(1/2);
    end
    % amplitude1 = m.globalDynamicProps.thicknessAbsolute * m.globalProps.perturbInitGrowthEstimate;
    amplitude = meshsize * m.globalProps.perturbInitGrowthEstimate;
    if usesNewFEs( m )
        numdfs = numel(m.FEnodes);
    else
        numdfs = numel(m.prismnodes);
    end
    if amplitude ~= 0
        if m.globalProps.resetRand
            rand('twister',5489);
        end
        if usesNewFEs( m )
            d = amplitude * rand( numdfs, 1 );
        else
            d = amplitude * rand( numdfs, 1 );
        end
    else
        d = zeros( numdfs, 1 );
    end
end
