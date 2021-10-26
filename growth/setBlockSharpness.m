function m = setBlockSharpness( m )
%m = setBlockSharpness( m )
%   m is assumed ot be a volumetric rectangular block.
%   This procedure sets m.sharpedges and m.sharpvxs.

    locorner = min( m.FEnodes,[],1);
    hicorner = max( m.FEnodes,[],1);
    step = [0 0 0];
    [~,~,step(1),~,~,~] = clumplinear( m.FEnodes(:,1) );
    [~,~,step(2),~,~,~] = clumplinear( m.FEnodes(:,2) );
    [~,~,step(3),~,~,~] = clumplinear( m.FEnodes(:,3) );
    eps = step/2;
    v_xlo = m.FEnodes(:,1) <= locorner(1) + eps(1);
    v_xhi = m.FEnodes(:,1) >= hicorner(1) - eps(1);
    v_ylo = m.FEnodes(:,2) <= locorner(2) + eps(2);
    v_yhi = m.FEnodes(:,2) >= hicorner(2) - eps(2);
    v_zlo = m.FEnodes(:,3) <= locorner(3) + eps(3);
    v_zhi = m.FEnodes(:,3) >= hicorner(3) - eps(3);
    vxcornerness = v_xlo + v_xhi + v_ylo + v_yhi + v_zlo + v_zhi;
    m.sharpedges = all( vxcornerness( m.FEconnectivity.edgeends ) > 1, 2 );
    m.sharpvxs = vxcornerness > 2;
end
