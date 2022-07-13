function ok = validVV( m )
%ok = validVV( m )
%   Test the VV layer of m for validity.

    vvlayer = m.secondlayer.vvlayer;
    ok = true;
    if isempty( vvlayer )
        return;
    end
    
    % Check sizes of arrays.
    numptsC = vvlayer.numptsC;
    numptsM = vvlayer.numptsM;
    numptsW = vvlayer.numptsW;
    numptsAll = numptsC+numptsM+numptsW;
    numEdgesWW = vvlayer.numEdgesWW;
    numEdgesMWM = vvlayer.numEdgesMWM;
    nummgens = length(vvlayer.mgendict.indexToName);

    checklengthInternal( 'vcells', numptsC );
    checksizeInternal( 'vvc', [numptsM,4] );
    checksizeInternal( 'vvcc', [numptsW,6] );
    checklengthInternal( 'cellwalls', numptsC );
    checksizeInternal( 'wallsegs', [numptsW,1] );
    checksizeInternal( 'vvptsWi', [numptsW,4] );
    checksizeInternal( 'vvptsMi', [numptsM,3] );
    checksizeInternal( 'nbW', [numptsW,4] );
    checklengthInternal( 'cellwallvxs', numptsC );
    checksizeInternal( 'cellW', [numptsC,1] );
    checksizeInternal( 'cellM', [numptsC,1] );
    checksizeInternal( 'edgeCM', [numptsM,2] );
    checksizeInternal( 'edgeCW', [numptsM,2] );
    checksizeInternal( 'edgeWM', [numptsM,2] );
    checksizeInternal( 'edgeMM', [numptsM,2] );
    checksizeInternal( 'Medgeedge', [numptsM,2] );
    checksizeInternal( 'edgeWW', [numEdgesWW,2] );
    checksizeInternal( 'edgeMWM', [numEdgesMWM,2] );
    checkvalueInternal( 'numEdgesCM', numptsM );
    checkvalueInternal( 'numEdgesMM', numptsM );
    checkvalueInternal( 'numEdgesWM', numptsM );
    checksizeInternal( 'vvptsC', [numptsC,3] );
    checksizeInternal( 'vvptsM', [numptsM,3] );
    checksizeInternal( 'vvptsW', [numptsW,3] );
    checksizeInternal( 'vxLengthsMM', [numptsM,1] );
    checksizeInternal( 'vxLengthsM', [numptsM,1] );
    checksizeInternal( 'vxLengthsW', [numEdgesWW,1] );
    checksizeInternal( 'vvpts', [numptsAll,3] );
    checksizeInternal( 'mgens', [numptsAll,nummgens] );
    checksizeInternal( 'mgenC', [numptsC,nummgens] );
    checksizeInternal( 'mgenM', [numptsM,nummgens] );
    checksizeInternal( 'mgenW', [numptsW,nummgens] );
    checksizeInternal( 'cellpolarity', [numptsC,3] );
%          mainvxs: [310x3 double]
%            edges: [3561x2 double]
%       mainvxsbcs: [310x3 double]
%       mainvxsFEM: [310x1 double]
%      plotoptions: [1x1 struct]
%               ax: [1x1 Axes]
%      plothandles: [1x1 struct]
%         mgendict: [1x1 struct]
    checksizeInternal( 'diffusion', [nummgens,5] );
    
    % Check connections.
    
    % Every edge reported in cellM must be reported in edgeCM and vice
    % versa.
    testEdgeCM = zeros(size(vvlayer.edgeCM));
    testEdgeCMi = 0;
    for i=1:numptsC
        newtestEdgeCMi = testEdgeCMi + length(vvlayer.cellM{i});
        range = (testEdgeCMi+1):newtestEdgeCMi;
        testEdgeCM( range, 1 ) = i;
        testEdgeCM( range, 2 ) = vvlayer.cellM{i};
        testEdgeCMi = newtestEdgeCMi;
    end
    s1 = testEdgeCM;
    s2 = vvlayer.edgeCM;
    conflicts = find( any( s1 ~= s2, 2 ) );
    if ~isempty(conflicts)
        ok = false;
        fprintf( 1, 'cellM is not consistent with edgeCM at items [%s ].\n', sprintf( ' %d', conflicts ) );
        fprintf( 1, '   %5d    %5d %5d    %5d %5d\n', [conflicts, s1(conflicts,:); s2(conflicts)]' );
    end
    
    % Every edge reported in cellW must be reported in edgeCW and vice
    % versa.
    testEdgeCW = zeros(size(vvlayer.edgeCW));
    testEdgeCWi = 0;
    for i=1:numptsC
        newtestEdgeCWi = testEdgeCWi + length(vvlayer.cellW{i});
        range = (testEdgeCWi+1):newtestEdgeCWi;
        testEdgeCW( range, 1 ) = i;
        testEdgeCW( range, 2 ) = vvlayer.cellW{i};
        testEdgeCWi = newtestEdgeCWi;
    end
    s1 = testEdgeCW;
    s2 = vvlayer.edgeCW;
    conflicts = find( any( s1 ~= s2, 2 ) );
    if ~isempty(conflicts)
        ok = false;
        fprintf( 1, 'cellW is not consistent with edgeCW at items [%s ].\n', sprintf( ' %d', conflicts ) );
        fprintf( 1, '   %5d    %5d %5d    %5d %5d\n', [conflicts, s1(conflicts,:); s2(conflicts)]' );
    end

    % Every edge between membrane vertexes (edgeMM) must join vertexes of the same
    % cell (edgeCM).
    edgeCells = sortrows(vvlayer.edgeCM(:,[2 1]));
    edgeCells = edgeCells(:,2);
    celledgeconnections = edgeCells(vvlayer.edgeMM);
    conflicts = find(celledgeconnections(:,1) ~= celledgeconnections(:,2));
    if ~isempty(conflicts)
        ok = false;
        fprintf( 1, 'Membrane connections between membranes of different cells at items [%s ].\n', sprintf( ' %d', conflicts ) );
        fprintf( 1, '   %5d    %5d %5d    %5d %5d\n', [ conflicts, celledgeconnections(conflicts,:), vvlayer.edgeMM(conflicts,:) ]' );
    end
    
    % For every edge between a membrane vertex and a wall vertex, the cell
    % the membrane belongs to must be a cell that the wall borders.

    % Every relationship reported in cellwalls must be reported in ...



    function checkvalueInternal( f, v )
        fv = vvlayer.(f);
        if fv ~= v
            ok = false;
            fprintf( 1, 'Field %s should have value %d, has value %d.\n', f, v, fv );
            return;
        end
    end

    function checklengthInternal( f, len )
        flen = length(vvlayer.(f));
        if flen ~= len
            ok = false;
            fprintf( 1, 'Field %s should have length %d, has length %d.\n', f, len, flen );
            return;
        end
    end

    function checksizeInternal( f, sz )
        fsz = size(vvlayer.(f));
        if any(fsz ~= sz)
            ok = false;
            fprintf( 1, 'Field %s should have size [%s ], has length [%s ].\n', ...
                f, sprintf( ' %d', sz ), sprintf( ' %d', fsz ) );
            return;
        end
    end
end
