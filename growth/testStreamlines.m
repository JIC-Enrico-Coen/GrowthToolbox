function m = testStreamlines( whichtests )
    global HEMISPHERE
    HEMISPHERE = true;
    if HEMISPHERE
        m = leaf_icosahedron([],'refinement',0);
        scaling = [1 1 0.5];
        m.nodes = m.nodes .* repmat( scaling, size(m.nodes,1), 1 );
        m.prismnodes = m.prismnodes .* repmat( scaling, size(m.prismnodes,1), 1 );
    else
        m = leaf_circle([],'rings',4);
    end
    m.morphogens(:,6) = 1 - (m.nodes(:,1).^2 + m.nodes(:,2).^2);
%     m = calcPolGrad(m);
    m = leaf_plotoptions( m, ...
        'drawedges',2, ...
        'drawlegend', false, ...
        'drawgradients', true, ...
        'thick', true, ...
        'streamlinethick', 3, ...
        'streamlinemiddotsize',15, ...
        'streamlineenddotsize',30, ...
        'streamlineoffset', 1, ...
        'streamlineoffset', -1, ...
        'azimuth', 0, ...
        'elevation', 70 );
    m = setMeshVertexNormals( m );
    m.edgesense = edgesense( m );
    m.edgecellindex = edgecellindex( m );
    
    NUM_TESTS = 14;
    if nargin < 1
        whichtests = 1:NUM_TESTS;
    end
    for i=whichtests
        m = doTest( m, i );
    end
    
    
%     [m,s1] = addStreamline( m, false, [0.2 0.9 0] );
%     % [m,s1] = addStreamline( m, false, [0.125,0,0] );
%     [m,s2] = addStreamline( m, false, s1(end,1), s1(end,2:4) );
%     m = leaf_plot( m );
end

function m = doTest( m, t )
    global HEMISPHERE
    
    m.tubules.tubuleparams.plus_growthrate = 0.1;

    switch t
        case 1
            for i=1:10
                m = leaf_createStreamlines( m, 'downstream', true, 'startpos', [randn(1,2)*0.25, 0], 'length', abs(randn(1)*1.27) );
            end
        case 2
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [0.8 0.37 0], 'length', 1.8 );
        case 3
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [0.1926 -0.3337 0], 'length', 0.5376 );
        case 4
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [0.1573 -0.4579 0], 'length', 0.1285 );
        case 5
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [0 0.7387 0], 'length', 3 );
        case 6
            m = leaf_createStreamlines( m, 'downstream', false, 'elementindex', 32, 'barycoords', [1 0 0], 'length', 3 );
        case 7
            m = leaf_createStreamlines( m, 'downstream', false, 'elementindex', 50, 'barycoords', [1 0 0], 'length', 3 );
        case 8
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [0.1926 0.3337 0], 'length', 0.2 );
            m = leaf_growStreamlines( m, 'length', 1 );
        case 9
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [0.1926 -0.3337 0], 'length', 2 );
        case 10
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [0.1926 0.4337 0], 'length', 1 );
        case 11
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [0.8149 0.1851 0], 'length', 10 );
        case 12
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [0.4596 0 0.5404], 'length', 3 );
        case 13
            m = leaf_createStreamlines( m, 'downstream', false, 'startpos', [-0.19 -0.205 0], 'length', 3 );
        case 14
%             startpos = [0.2523 0.143565 0];
%             startpos = [0.2 0 0];
%             delta = [0 0.1 0];
%             startpos = [ startpos; startpos-delta; startpos+delta ];
            numstreamlines = 10;
            startpos = 0.3*(2*rand(numstreamlines,2) - 1);
            startpos(end,3) = 0;
            if HEMISPHERE
                for i=1:size(startpos,1)
                    startpos(i,3) = sqrt(1 - startpos(i,1)^2 - startpos(i,1)^2 );
                end
            end
            dirbc = randomDirectionBC(size(startpos,1));
            for i=1:size(startpos,1)
                m = leaf_createStreamlines( m, 'downstream', true, 'startpos', startpos(i,:), 'directionbc', dirbc(i,:), 'length', 10 );
            end
        otherwise
    end
    m = leaf_plot( m );
end

function dirbc = randomDirectionBC( n )
    dirbc = randn(n,3);
    dirbc = dirbc - repmat( mean(dirbc,2), 1, size(dirbc,2) );
    dirbc = dirbc ./ repmat( sqrt(sum(dirbc.^2,2)), 1, size(dirbc,2) );
end
