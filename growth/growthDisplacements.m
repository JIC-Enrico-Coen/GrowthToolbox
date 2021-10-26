function [m,U,G,K,F] = growthDisplacements( m )
%[m,U,G,K,F] = growthDisplacements( m )
%   Calculate plastic growth.

    numnodes = size(m.nodes,1);
    numcells = size(m.tricellvxs,1);
    dfsPerNode = 3;
    dfsPerCell = 6;
    numgfDFs = numcells*dfsPerCell;
    numDFs = numnodes*dfsPerNode;
    K = zeros( numgfDFs, numDFs );
    F = zeros( numgfDFs, 1 );

    m = makeMeshGrowthTensors( m );
    for ci = 1:numcells
        trivxs = m.tricellvxs(ci,:);
        cellvxDFs = trivxs*3;
        cellvxDFs = reshape( [ cellvxDFs-2; cellvxDFs-1; cellvxDFs ], 1, [] );
        oneCellMatrix = gradOpLinear( m.nodes( trivxs, : ) );
        growthDFs = (ci-1)*6+(1:6);
        K( growthDFs, cellvxDFs ) = oneCellMatrix( [1 5 9 8 7 4], : );
        gt1 = m.celldata(ci).Gglobal * m.globalProps.timestep;
        F( growthDFs ) = sum(gt1,1)/size(gt1,1);
    end

    triangleFixedDFs = find(m.fixedDFmap(1:2:end,:)') | find(m.fixedDFmap(2:2:end,:)');
    if ~isempty(triangleFixedDFs)
        renumber = eliminateVals( size(K,2), triangleFixedDFs );
        K = K(:,renumber);
    end
    cgmaxiter = size(K,1); % size(K,1)*40;
    tol = 0.001;
    [UC,cgflag,cgrelres,cgiter] = lsqr(K,F,tol,cgmaxiter);
  % cgflag
  % cgrelres
  % cgiter
  % cgmaxiter
  % U3 = reshape( U, 3, [] )'
  % Fcheck = (K*U)'
    G = reshape( K*UC, 6, [] )';
    if ~isempty(triangleFixedDFs)
        U = insertFixedDFS( UC, renumber, numDFs, m.globalDynamicProps.stitchDFs, [], [], [], [], [] );
        U = reshape(U, dfsPerNode, numnodes )';
    else
        U = reshape(UC, dfsPerNode, numnodes )';
    end
end
