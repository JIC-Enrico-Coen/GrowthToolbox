function m = splitSecondLayerEdges( m )
%m = splitSecondLayerEdges( m )
%   Split edges of the second layer that are longer than a certain amount.
%   NOT COMPATIBLE WITH VOLUMETRIC MESHES.  Needs m.unitcellnormals.
%   But it only needs that in order to do the lateral offset.  Another
%   problem is that cells on the surface of a volumetric mesh are not held
%   to the surface by subdivision.

    if ~hasNonemptySecondLayer( m ), return; end

    edgethreshold = m.secondlayer.splitThreshold;
    edgethresholdsq = edgethreshold*edgethreshold;
    numedges = size(m.secondlayer.edges,1);
    edgevecs = m.secondlayer.cell3dcoords( m.secondlayer.edges(:,1), :) ...
                - m.secondlayer.cell3dcoords( m.secondlayer.edges(:,2), :);
    edgelensqs = sum(edgevecs.*edgevecs,2)';
    splitmap = edgelensqs > edgethresholdsq;
    edgestosplit = find(splitmap);
    if isempty(edgestosplit)
        return;
    end
  % edgestosplit
    numvx = size(m.secondlayer.cell3dcoords,1);
  % perturbationSize = 1/(2*sqrt(3));
    perturbationSize = 0; % 0.7/(2*sqrt(3));
    for ei=edgestosplit
        v1 = m.secondlayer.edges(ei,1);
        v2 = m.secondlayer.edges(ei,2);
        p1 = m.secondlayer.cell3dcoords(v1,:);
        p2 = m.secondlayer.cell3dcoords(v2,:);
        p = (p1+p2)*0.5;
        numvx = numvx+1;
        newvi = numvx;
        numedges = numedges+1;
        newei = numedges;
        fe1 = m.secondlayer.vxFEMcell(v1);
        fe2 = m.secondlayer.vxFEMcell(v2);
        if perturbationSize ~= 0
            edgevec = p2-p1;
            cn1 = m.unitcellnormals( fe1, : );
            cn2 = m.unitcellnormals( fe2, : );
            cn = (cn1+cn2)*0.5;
            perturbation = cross(edgevec,cn)*perturbationSize;
            if rand(1) < 0.5
                perturbation = -perturbation;
            end
            p = p + perturbation;
        end
        m.secondlayer.cell3dcoords(newvi,:)= p;
        if fe1==fe2
            m.secondlayer.vxBaryCoords(newvi,:) = cellBaryCoords( m, fe1, p );
            m.secondlayer.vxFEMcell(newvi) = fe1;
        else
            [ m.secondlayer.vxFEMcell(newvi), ...
              m.secondlayer.vxBaryCoords(newvi,:), ...
              err ] = findFE( m, p, 'hint', [fe1 fe2] );
          % err
        end
        m.secondlayer.edges(ei,2) = newvi;
        m.secondlayer.edges(newei,:) = ...
            [newvi,v2,m.secondlayer.edges(ei,[3 4])];
        if isfield( m.secondlayer, 'generation' )
            m.secondlayer.generation(newei) = m.secondlayer.generation(ei);
        end
        m.secondlayer.edgepropertyindex(newei) = m.secondlayer.edgepropertyindex(ei);
        m.secondlayer.interiorborder(newei) = false;
        c1 = m.secondlayer.edges(ei,3);
        c2 = m.secondlayer.edges(ei,4);
        if c1 > 0
            [m.secondlayer.cells(c1).vxs,m.secondlayer.cells(c1).edges] = ...
                insertvertex( ...
                    m.secondlayer.cells(c1).vxs, ...
                    m.secondlayer.cells(c1).edges, ...
                    newei, v1, v2, newvi, true );
        end
        if c2 > 0
            [m.secondlayer.cells(c2).vxs,m.secondlayer.cells(c2).edges] = ...
                insertvertex( ...
                    m.secondlayer.cells(c2).vxs, ...
                    m.secondlayer.cells(c2).edges, ...
                    newei, v1, v2, newvi, false );
        end
    end
    [ok,m.secondlayer] = checkclonesvalid( m.secondlayer );
    if ~ok
        fprintf( 1, 'Invalid second layer in %s.\n', mfilename() );
        % error( mfilename() );
    end
end

function [vxs,edges] = insertvertex( vxs, edges, newei, v1, v2, newvi, forwards )
    v1i = find( vxs==v1 );
    v2i = find( vxs==v2 );
    % Check v2i is next after v1i.
    if forwards
        if v2i ~= (mod(v1i,length(vxs))+1)
            complain('insertvertex: invalid v2i: %d %d', v1i, v2i );
            vxs
            edges
            v1
            v2
            newvi
            xxxx = 1;
        end
    else
        if v1i ~= (mod(v2i,length(vxs))+1)
            complain('insertvertex: invalid v2i: %d %d', v2i, v1i );
            vxs
            edges
            v1
            v2
            newvi
            xxxx = 1;
        end
    end
    if forwards
        vxs = [ vxs(1:v1i), newvi, vxs((v1i+1):end) ];
        edges = [ edges(1:v1i), newei, edges((v1i+1):end) ];
    else
        vxs = [ vxs(1:v2i), newvi, vxs((v2i+1):end) ];
        edges = [ edges(1:(v2i-1)), newei, edges(v2i:end) ];
    end
end
