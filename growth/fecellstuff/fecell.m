function c = fecell()
    tensorLength = 6;
    numVxs = 6;
    numQuadPoints = 6;
    numDims = 3;

    c.cellThermExpGlobalTensor = zeros( tensorLength, 1 ); % [2016 Jan] Should this be per quad point?
    
    c.eps0gauss = zeros( tensorLength, numQuadPoints ); % Perhaps numQuadPoints should be numVxs?
    c.gnGlobal = zeros( numDims, numVxs, numQuadPoints );
    c.displacementStrain = zeros( tensorLength, numQuadPoints ); % Perhaps numQuadPoints should be numVxs?
    c.residualStrain = zeros( tensorLength, numQuadPoints );
    c.actualGrowthTensor = zeros( tensorLength, numQuadPoints); % Perhaps numQuadPoints should be numVxs?
    c.fixed = 0;
    c.vorticity = repmat( eye(numDims), [1, 1, numQuadPoints] ); % Perhaps numQuadPoints should be numVxs?
    c.Glocal = zeros( numVxs, numDims );
    c.Gglobal = zeros( numVxs, tensorLength );
end

