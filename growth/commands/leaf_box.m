function [m,ok] = leaf_box( m, varargin )
%[m,ok] = leaf_box( m, ... )
%   Create a box-shaped foliate mesh.

    if nargin==0
        m = [];
    end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, ...
        'size', [], 'xwidth', [], 'ywidth', [], 'zwidth', [], ...
        'centre', [0 0 0], ...
        'numdivs', [], 'xdivs', [], 'ydivs', [], 'zdivs', [], ...
        'divsize', [], 'edgeradius', 0, ...
        'layers', 0, 'thickness', 0, 'generalFE', false, ...
        'new', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'size', 'xwidth', 'ywidth', 'zwidth', 'centre', ...
        'numdivs', 'xdivs', 'ydivs', 'zdivs', 'divsize', 'edgeradius', ...
        'layers', 'thickness', 'generalFE', ...
        'new' );
    if ~ok, return; end
    
    if isempty( s.size )
        s.size = [ s.xwidth, s.ywidth, s.zwidth ];
    end
    if isempty( s.size )
        s.size = [ 2 2 2 ];
    end
    if length(s.size)==1
        s.size = repmat( s.size, 1, 3 );
    end
    
    if isempty( s.numdivs )
        s.numdivs = [ s.xdivs, s.ydivs, s.zdivs ];
    end
    if isempty( s.numdivs )
        s.numdivs = [ 4 4 4 ];
    end
    if length(s.numdivs)==1
        s.numdivs = repmat( s.numdivs, 1, 3 );
    end
    
    if ~isempty( s.divsize )
        s.numdivs = round( s.size./s.divsize );
    end
    
    if numel(s.edgeradius)==1
        s.edgeradius = s.edgeradius + [0 0 0];
    end
    s.edgeradius = min( s.edgeradius, min( s.size )/2 );
    
    [ok,handles,m,savedstate] = prepareForGUIInteraction( m );
    if ~ok
        return;
    end
    savedstate.replot = true;
    savedstate.install = true;
    if s.new
        m = [];
    elseif isempty(m)
        s.new = true;
    end
    
    p = [1 2 3;2 3 1;3 1 2];  p = [p;p];
    numfaces = size(p,1);
    f = [false false false true true true];
    numelements = zeros(1,numfaces);
    m1 = emptystructarray( [size(p,1),1], 'nodes', 'tricellvxs' );
    for i=1:numfaces
        m1(i) = submesh( s.size(p(i,1)), s.size(p(i,2)), s.size(p(i,3)), s.numdivs(p(i,1)), s.numdivs(p(i,2)), p(i,:), f(i) );
        numelements(i) = size(m1(i).tricellvxs,1);
    end
    cnumelements = [0 cumsum( numelements )];
    auxdata.boxfaces = char( zeros( cnumelements(end), 1 ) );
    facenames = 'ZXYzxy';
    for i=1:numfaces
        auxdata.boxfaces( (cnumelements(i)+1):cnumelements(i+1) ) = facenames(i);
    end
    
    vxs = { m1.nodes };
    tricellvxs = { m1.tricellvxs };
    offset = size( vxs{1}, 1 );
    for i=2:length(tricellvxs)
        tricellvxs{i} = tricellvxs{i} + offset;
        offset = offset + size( vxs{i}, 1 );
    end
    vxs = cell2mat( vxs(:) );
    tricellvxs = cell2mat( tricellvxs(:) );
    tic;
    [vxs,~,remap] = mergenodesprox( vxs, 0.01*min( s.size./s.numdivs ), false );
    toc;
    tricellvxs = remap(tricellvxs);
    [~,~,~,~,clumpindex1,~] = clumplinear( vxs(:,1) );
    [~,~,~,~,clumpindex2,~] = clumplinear( vxs(:,2) );
    [~,~,~,~,clumpindex3,~] = clumplinear( vxs(:,3) );
    auxdata.planes = [ clumpindex1 clumpindex2 clumpindex3 ];
    
    stripthickness = s.size ./ s.numdivs;
    numedgestrips = ceil( s.edgeradius ./ stripthickness );
    
    numvxs = size(vxs,1);
    if s.edgeradius > 0
        innermax = s.size/2 - s.edgeradius;

        allmax = repmat( innermax, numvxs, 1 );
        allmin = -allmax;
        base = vxs;
        base( vxs > allmax ) = allmax( vxs > allmax );
        base( vxs < allmin ) = allmin( vxs < allmin );
        
        vxs = base + (vxs-base).*(s.edgeradius./sqrt( sum( (vxs-base).^2, 2 ) ));
    end
    
    % Establish the curvature data. In corners the principal curvatures are
    % both 1/s.edgeradius. On edges, one is 1/s.edgeradius and one is zero.
    % Elsewhere, both are zero.
    % In corners, the principal axes can be arbitrary orthonormal tangents.
    % On edges, the first is parallel to the edge and the second
    % perpendicular. Elsewhere they  can be arbitrary orthonormal tangents.
    % Complication: this procedure allows for the edge radius to differ
    % for x, y, and z edges. This will make the corners more complicated,
    % because then they could be octants of an ellipsoid of any semi-axes.
    % What are the principal axes and curvatures of such a surface? But
    % perhaps it would be easier to calculate the curvature tensor
    % directly? How does the curvature tensor vary when a surface is
    % scaled?
    
    uniquecurvature = mean( 1./s.edgeradius );
    curvatures = zeros( 3, 3, numvxs );
    
    margin = 1;

    if all(s.edgeradius > 0)
        iscurvedx = [ true(1,numedgestrips(1)+margin), false(1,s.numdivs(1)-2*numedgestrips(1)-2*margin+1), true(1,numedgestrips(1)+margin) ]';
        iscurvedy = [ true(1,numedgestrips(2)+margin), false(1,s.numdivs(2)-2*numedgestrips(2)-2*margin+1), true(1,numedgestrips(2)+margin) ]';
        iscurvedz = [ true(1,numedgestrips(3)+margin), false(1,s.numdivs(3)-2*numedgestrips(3)-2*margin+1), true(1,numedgestrips(3)+margin) ]';

        curvedvxmap = [ iscurvedx(auxdata.planes(:,1)), ...
                        iscurvedy(auxdata.planes(:,2)), ...
                        iscurvedz(auxdata.planes(:,3)) ];
        curvedvxid = curvedvxmap * [4;2;1];

        xedges = curvedvxid==3;
        yedges = curvedvxid==5;
        zedges = curvedvxid==6;
        corners = curvedvxid==7;

        reducedvxs = max( abs( vxs ) + (-s.size/2 + s.edgeradius), 0 );
        reducedvxs(vxs<0) = -reducedvxs(vxs<0);
        reducedvxs = reducedvxs./s.edgeradius;
        
        cc = reducedvxs(zedges,2);
        if ~isempty(cc)
            ss = reducedvxs(zedges,1);
            zz = zeros( size(cc) );
            oo = ones( size(cc) );
            rotmat = reshape( [ cc -ss zz, ss cc zz, zz zz oo ]', 3, 3, [] );
            curvatures(:,:,zedges) = pagemtimes( pagemtimes( rotmat, [ uniquecurvature 0 0; 0 0 0; 0 0 0 ] ), pagetranspose( rotmat ) );
        end

        cc = reducedvxs(xedges,3);
        if ~isempty(cc)
            ss = reducedvxs(xedges,2);
            zz = zeros( size(cc) );
            oo = ones( size(cc) );
            rotmat = reshape( [ cc -ss zz, ss cc zz, zz zz oo ]', 3, 3, [] );
            rotmat = rotmat( [3 1 2], [3 1 2], : );
            curvatures(:,:,xedges) = pagemtimes( pagemtimes( rotmat, [ 0 0 0; 0 uniquecurvature 0; 0 0 0 ] ), pagetranspose( rotmat ) );
        end

        cc = reducedvxs(yedges,1);
        if ~isempty(cc)
            ss = reducedvxs(yedges,3);
            zz = zeros( size(cc) );
            oo = ones( size(cc) );
            rotmat = reshape( [ cc -ss zz, ss cc zz, zz zz oo ]', 3, 3, [] );
            rotmat = rotmat( [2 3 1], [2 3 1], : );
            curvatures(:,:,yedges) = pagemtimes( pagemtimes( rotmat, [ 0 0 0; 0 0 0; 0 0 uniquecurvature ] ), pagetranspose( rotmat ) );
        end

        corner_x = shiftdim( reducedvxs(corners,1), -2 );
        corner_y = shiftdim( reducedvxs(corners,2), -2 );
        corner_z = shiftdim( reducedvxs(corners,3), -2 );
        corner_xy = sqrt( corner_x.^2 + corner_y.^2 );
        
        zz = zeros( size( corner_x ) );
        oo = ones( size( corner_x ) );

        cp = corner_xy;
        sp = corner_z;
        rp = [ cp zz -sp;
               zz  oo  zz;
               sp zz cp ];
        
        ct = corner_x./corner_xy;
        st = corner_y./corner_xy;
        ct(corner_xy==0) = 1;
        st(corner_xy==0) = 0;
        
        rt = [ ct st zz;
               -st ct zz;
               zz zz oo ];
        
%         ct = shiftdim( reducedvxs(corners,1), -2 );
%         st = shiftdim( reducedvxs(corners,2), -2 );
%         sp = shiftdim( reducedvxs(corners,3), -2 );
%         cp = sqrt( 1-sp.^2 );
%         zz = zeros( size( ct ) );
%         rp = [ cp zz sp;
%                zz zz zz;
%                -sp zz cp ];
%         rt = [ ct st zz;
%                -st st zz;
%                zz zz zz ];
        r = pagemtimes( rt, rp );
        curvatures(:,:,corners) = pagemtimes( pagemtimes( r, diag([0 uniquecurvature uniquecurvature]) ), pagetranspose( r ) );
%         curvatures(:,:,corners) = repmat( [1 0 0; 0 1 0; 0 0 0], 1, 1, sum(corners) );
    end
    
    auxdata.curvatures = curvatures;
    
    
    
    newm = struct( 'nodes', vxs, 'tricellvxs', tricellvxs );
    newm.nodes = newm.nodes + repmat( s.centre, numvxs, 1 );
    m = setmeshfromnodes( newm, m, s.layers, s.thickness );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    m.meshparams.type = regexprep( mfilename(), '^leaf_', '' );
    if isfield( m, 'auxdata' )
        m.auxdata = defaultFromStruct( auxdata, m.auxdata );
    else
        m.auxdata = auxdata;
    end
    
    m = concludeGUIInteraction( handles, m, savedstate );
end

function m = submesh( uwidth, vwidth, wwidth, udivs, vdivs, axisperm, flip )
    m = leaf_rectangle( [], 'xwidth', uwidth, 'ywidth', vwidth, 'centre', [0 0 0], ...
        'xdivs', udivs, 'ydivs', vdivs, ...
        'fetype', '', 'new', true );
    
    m = struct( 'nodes', m.nodes, 'tricellvxs', m.tricellvxs );
    if flip
        m.nodes(:,3) = -wwidth/2;
        m.nodes(:,2) = -m.nodes(:,2);
    else
        m.nodes(:,3) = wwidth/2;
    end
    m.nodes(:,axisperm) = m.nodes;
end

