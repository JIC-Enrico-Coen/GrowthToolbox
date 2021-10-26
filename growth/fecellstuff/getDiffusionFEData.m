function dd = getDiffusionFEData( dd, fe, nodecoords, cellvertexes, constDiff, varyingDiff, fixedDfs )
%dd = getDiffusionFEData( dd, fe, nodecoords, cellvertexes, conductivity, fixednodes )
%   Calculate all the information about the mesh that is required for
%   diffusion calculations and is independent of the current morphogen
%   values and the time step.
%
%   So long as the mesh geometry does not change, this information can be
%   reused and not recomputed.  In particular, in a single iteration of the
%   simulation, this information can be used for all of the diffusible
%   morphogens.
%
%   See also: clearDiffusionFEData().

    if dd.clean
        return;
    end
    dd = clearDiffusionFEData();
    
    startdd = tic();
    
    numnodes = size(nodecoords,1);
    numFEs = size(cellvertexes,1);
    numvxsPerFE = size(fe.canonicalVertexes,1);
    varyingDfs = eliminateVals( numnodes, fixedDfs );
    numVarying = length(varyingDfs);
    numFixed = length(fixedDfs);
    usesparse = false;
    if usesparse
        C = sparse(zeros(numnodes,numnodes));
        dd.C22 = sparse(zeros(numVarying,numVarying));
        if constDiff
            Hc = sparse(zeros(numnodes,numnodes));
            dd.H21c = sparse(zeros(numVarying,numFixed));
            dd.H22c = sparse(zeros(numVarying,numVarying));
        end
        if varyingDiff
            dd.intgradNgradN = zeros( numvxsPerFE, numvxsPerFE, numFEs );
        end
    else
        C = zeros(numnodes,numnodes);
        dd.C22 = zeros(numVarying,numVarying);
        if constDiff
            Hc = zeros(numnodes,numnodes);
            dd.H21c = zeros(numVarying,numFixed);
            dd.H22c = zeros(numVarying,numVarying);
        end
        if varyingDiff
            dd.intgradNgradN = zeros( numvxsPerFE, numvxsPerFE, numFEs );
        end
    end
    dd.cellvolume = zeros(numFEs,1);
    
    numvxs = size(fe.canonicalVertexes,1);
    numquadpts = size(fe.quadraturePoints,1);
    for fei=1:numFEs
        vxcoords = nodecoords( cellvertexes(fei,:), : );
        [~,gradNeuc,weightedJacobians] = fe.interpolationData( vxcoords );
        NN = reshape( fe.shapequadproducts * weightedJacobians, numvxs, numvxs );
        gradNeucRep = repmat( permute( gradNeuc, [1,2,4,3] ), [1,1,numvxs,1] );
        gradNgradN = permute( sum( gradNeucRep .* permute( gradNeucRep, [3,2,1,4] ), 2 ), [1,3,4,2] );
        intgradNgradN = reshape( reshape( gradNgradN, [], numquadpts ) * weightedJacobians, ...
                                 numvxs, numvxs );
        dd.cellvolume(fei) = sum(weightedJacobians);
        
        renumber = cellvertexes(fei,:);
        C(renumber,renumber) = C(renumber,renumber) + NN;
        if constDiff
            Hc(renumber,renumber) = Hc(renumber,renumber) + intgradNgradN;
        end
        if varyingDiff
            dd.intgradNgradN(:,:,fei) = intgradNgradN;
        end
    end
    dd.C22 = C(varyingDfs,varyingDfs);
    if constDiff
        dd.H21c = Hc(varyingDfs,fixedDfs);
        dd.H22c = Hc(varyingDfs,varyingDfs);
    end
    dd.clean = true;
    
    enddd = toc(startdd);
    fprintf( 1, '%s: Elapsed time is %g seconds.\n', mfilename(), enddd );
end
