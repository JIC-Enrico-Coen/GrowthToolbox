function m = setmeshgeomfromnodes( m, layers, thickness )
%m = setmeshgeomfromnodes( m )
%   Given a mesh containing only nodes and tricellvxs,
%   construct the rest of its geometrical and topological information.

% If it has both nodes and prismnodes, use the validity flags, if present,
% to determine their validity.  If the flags are not present, assume both
% are valid.

    if nargin < 2
        layers = 0;
    end
    if nargin < 3
        thickness = 0;
    end
    
    global gGlobalProps;

    m.globalProps.trinodesvalid = true;
    m.globalProps.prismnodesvalid = false;

    m = makeedges( m );
    m = fixOrientations( m );
    m = makeVertexConnections(m);
    m.edgesense = edgesense( m );
    m.edgecellindex = edgecellindex( m );
    m = setMeshVertexNormals( m );
    m = makeedgethreshsq( m );
    m = makeAreasAndNormals( m );
    m.globalDynamicProps.previousArea = m.globalDynamicProps.currentArea;
    m = setlengthscale( m );
    m.globalProps.initialArea = m.globalDynamicProps.currentArea;
    m.globalProps.bendunitlength = sqrt( m.globalProps.initialArea );
    m = makebendangles( m );
    m.initialbendangle = m.currentbendangle;
    m.seams = false( size(m.edgeends,1), 1 );

    if thickness==0
        m.globalProps.thicknessRelative = gGlobalProps.thicknessRelative;
    else
        m.globalProps.thicknessRelative = thickness;
    end
    m.globalProps.thicknessArea = gGlobalProps.thicknessArea;
    m = setThickness( m );
    
    m = makeprismsvalid( m, layers, m.globalDynamicProps.thicknessAbsolute );
    m.displacements = [];
end

function m = makeedges( m )
%   Construct m.edgeends, m.edgecells, and m.celledges
%   from m.tricellvxs.

    [m.edgeends,m.celledges,m.edgecells,~] = connectivityTriMesh(size(m.nodes,1),m.tricellvxs);
end

function m = makeprismsvalid( m, layers, thickness )
%m = makeprismsvalid( m, layers, thickness )
%    Convert 2Dmesh to set of prisms.

% If layers > 0 then a new-style multilayer mesh should be created.

    if layers > 0
        m = makemultilayer( m, layers, thickness );
        return;
    end
    
    m.globalDynamicProps.thicknessAbsolute = thickness;

    if m.globalDynamicProps.thicknessAbsolute==0
        m = setThickness( m );
    end

    m.prismnodes = ...
        reshape( ...
            [ m.nodes(:,1:2)'; ...
              m.nodes(:,3)' - m.globalDynamicProps.thicknessAbsolute/2;
              m.nodes(:,1:2)'; ...
              m.nodes(:,3)' + m.globalDynamicProps.thicknessAbsolute/2 ], ...
          3, size(m.nodes,1)*2 )';
    %if m.globalProps.rectifyverticals
        m = rectifyVerticals( m );
    %end
    if size(m.prismnodes,1) ~= 2*size(m.nodes,1)
        fprintf( 1, 'makeprismsvalid: bad sizes %d %d\n', ...
            size(m.prismnodes,1), size(m.nodes,1) );
        error(' ');
    end
    m.globalProps.prismnodesvalid = true;
end
