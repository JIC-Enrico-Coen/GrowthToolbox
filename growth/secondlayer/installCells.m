function [m,ok] = installCells( m, vxs, polys, varargin )
%[m,ok] = installCells( m, vxs, polys, ... )
%   Given a set of biological cells whose vertexes are VXS and whose
%   polygons are POLYS, install these as a cellular layer in M.
%
%   Options:
%
%   'add'   If true, add these cells to any existing cellular layer in M.
%           If false, delete the cellular layer from M before adding the
%           new cells. The default is false.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'add', false );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'add' );
    if ~ok, return; end
    
    if ~s.add
        m = leaf_deletebiocells( m );
    end
    
    if isVolumetricMesh(m)
        vxsPerFE = getNumVxsPerFE( m );
    else
        vxsPerFE = 3;
    end
    
    sl = struct( 'pts', vxs, 'cellvxs', polys );
    npts = size( sl.pts, 1 );
    
    sl.fe = zeros(npts,1);
    sl.febcs = zeros(npts,vxsPerFE);
    sl.bcerr = zeros(npts,1);
    sl.abserr = zeros(npts,1);
    for i=1:npts
        if (mod(i,20)==0)
            if teststopbutton(m)
                ok = false;
                return;
            end
        end
        [ sl.fe(i), sl.febcs(i,:), sl.bcerr(i), sl.abserr(i) ] = findFE( m, sl.pts(i,:) );
    end

    if ~s.add
        m.secondlayer = deleteSecondLayerCells( m.secondlayer );
        m.secondlayerstatic = newemptysecondlayerstatic();
    end
    
    numoldcells = length(m.secondlayer.cells);
    numoldvxs = length(m.secondlayer.vxFEMcell);
    numnewcells = size(sl.cellvxs,1);
    numcells = size(sl.cellvxs,1);
    for i=1:numnewcells
        cvxs = sl.cellvxs(i,:);
        cvxs = cvxs(~isnan(cvxs));
        m.secondlayer.cells(numoldcells+i).vxs = numoldvxs + cvxs(cvxs~=0);
    end
    m.secondlayer.vxFEMcell = [ m.secondlayer.vxFEMcell; sl.fe ];
    m.secondlayer.vxBaryCoords = [ m.secondlayer.vxBaryCoords; sl.febcs ];
    m.secondlayer.cell3dcoords = [ m.secondlayer.cell3dcoords; sl.pts ];

    if isVolumetricMesh(m)
        if ~isfield( m.secondlayer, 'surfaceVertexes' )
            m.secondlayer.surfaceVertexes = false(0,1);
        end
        m.secondlayer.surfaceVertexes = [ m.secondlayer.surfaceVertexes; false( length(m.secondlayer.vxFEMcell), 1 ) ];
    end
    m.secondlayer.cellcolor = [ m.secondlayer.cellcolor; ones( numcells, 3 ) ];
    m.secondlayer.side = [ m.secondlayer.side(:); true( numcells, 1 ) ];
    m.secondlayer.cloneindex = [ m.secondlayer.cloneindex(:); zeros( numcells, 1 ) ];
end
