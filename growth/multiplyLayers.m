function m1 = multiplyLayers( m, nlayers )
%m = multiplyLayers( m, nlayers )
%   Replace the mesh of m by nlayers copies, stacked up and with the B
%   surface  of one layer glued to the A surface of the next.

    if nlayers <= 1
        m1 = m;
        return;
    end

    offsets = (1:nlayers) - (nlayers+1)/2;
    nvxs = size(m.nodes,1);
    nfems = size(m.tricellvxs,1);
    newnodes = repmat( m.nodes, nlayers, 1 );
    newprismnodes = repmat( m.prismnodes, nlayers, 1 );
    newtricellvxs = repmat( m.tricellvxs, nlayers, 1 );
    verticals = m.prismnodes(2:2:end,:) - m.prismnodes(1:2:end,:);
    for i=1:nlayers
        newnodes( ((i-1)*nvxs+1):(i*nvxs), : ) = ...
            m.nodes + verticals*offsets(i);
        newprismnodes( ((i-1)*2*nvxs+1):(i*2*nvxs), : ) = ...
            m.prismnodes + reshape( repmat( verticals'*offsets(i), 2, 1 ), 3, [] )';
        newtricellvxs( ((i-1)*nfems+1):(i*nfems), : ) = ...
            m.tricellvxs + nvxs*(i-1);
    end
    if true
%         m.nodes = newnodes;
%         m.prismnodes = newprismnodes;
%         m.tricellvxs = newtricellvxs;
%         m = rmfield( m, { 'edgeends', 'edgecells', 'celledges', 'nodecelledges' } );
%         m.morphogens = repmat( m.morphogens, nlayers, 1 );
%         m.gradpolgrowth = repmat( m.gradpolgrowth, nlayers, 1 );
%         m.morphogenclamp = repmat( m.morphogenclamp, nlayers, 1 );
        newmesh = struct( 'nodes', newnodes, 'prismnodes', newprismnodes, 'tricellvxs', newtricellvxs );
        [m1,ok] = setmeshfromnodes( newmesh, m );
    else
        m.nodes = newnodes;
        m.prismnodes = newprismnodes;
        m.tricellvxs = newtricellvxs;
        % m = rmfield( m, { 'edgeends', 'edgecells', 'celledges', 'nodecelledges' } );
        newmesh = struct( 'nodes', newnodes, 'prismnodes', newprismnodes, 'tricellvxs', newtricellvxs );
        newmesh.morphogens = repmat( m.morphogens, nlayers, 1 );
        newmesh.gradpolgrowth = repmat( m.gradpolgrowth, nlayers, 1 );
        [m1,ok] = setmeshfromnodes( newmesh );
    end
    ndfPerLayer = nvxs*3;
    df1 = (repmat( (2:2:(2*nvxs))', 1, 3 )*3 + repmat( [-2 -1 0], nvxs, 1 ))';
    df1 = repmat( df1(:), 1, nlayers-1 ) + repmat( (2*ndfPerLayer)*(0:(nlayers-2)), ndfPerLayer, 1 );
    df2 = df1 + ndfPerLayer*2 - 3;
    m1.globalDynamicProps.stitchDFs = [ df1(:), df2(:) ];
end
