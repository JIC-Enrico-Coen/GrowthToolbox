function m = splitnode( m, v1, cp1, bc1, cp2, bc2, e1, e2 )
%m = splitnode( m, v1, cp1, bc1, cp2, bc2, e1, e2 )
%   Split node vi of mesh m.  The new points are at barycentric coordinates
%   of bc1 in cell cp1 and bc2 in cell cp2.  e1 and e2 are the edges of vi
%   which are to be split.  e2 is zero if and only if v1 is on the edge of
%   the mesh.  If cp1==0, then bc1 is ignored and the first new point
%   coincides with the old point.  If cp2==0 then bc2 is ignored and the
%   second new point coincides with the old point.
%
%   For foliate meshes only.

    % 1. Find the indexes of all the relevant components of the mesh.
    v2 = size(m.nodes,1)+1;
    v1a = otherend( m, v1, e1 );
    if e2
        v2a = otherend( m, v1, e2 );
    end
    pv1b = v1*2;
    pv1a = pv1b-1;
    pv2b = v2*2;
    pv2a = pv2b-1;
    c1 = size(m.tricellvxs,1)+1; 
    e3 = size(m.edgeends,1) + 1;
    e1a = e3+1;
    if e2
        c2 = c1+1;
        e2a = e1a+1;
    else
        c2 = 0;
    end
    ch = m.nodecelledges{v1};
    cellnbd = ch(2,:);
    cellnbd = cellnbd(cellnbd ~= 0);
    fullcellnbd = [cellnbd c1];
    if e2
        fullcellnbd = [fullcellnbd c2];
    end
    [ch1,ch2] = splitchain( ch, e1, e2 );
    ca = ch1(2);
    cb = ch1(size(ch1,2));
    cc = ch2(2);
    cd = ch2(size(ch2,2));
    cv2 = ch2(2,:);
    ev2 = ch2(1,:);
    % Note that cells c1 and c2 will get vertexes [v1 v2 v1a] and [v2 v1
    % v2a].  These must be consistent with the orientation of the mesh.

    % These are all the components of m that must be updated:
    % Per-node data:            Update or create for:
    %   nodes                   v1 v2                       DONE
    %   prismnodes              v1 v2                       DONE
    %   morphogens              v2                          DONE
    %   morphogenclamp          v2                          DONE
    %   globalProps.fixedDFmap  v2                          DONE
    %   nodecelledges           v1 v2 v1a v2a               DONE
    % Per-edge data:
    %   edgeends                e3 e1a e2 ev2               DONE
    %   edgecells               e3 e1a e2a e1 e2            DONE
    %   seamedges               ?                           Not done
    % Per-cell data:
    %   tricellvxs              c1 c2, cv2                  DONE
    %   celledges               c1 c2 cb cd                 DONE
    %   gradpolgrowth           fullcellnbd                 DONE
    %   celldata                fullcellnbd                 DONE
    %   unitcellnormals         fullcellnbd                 DONE
    %   effectiveGrowthTensor   fullcellnbd                 DONE
    
    % 2. Obtain the interpolation stencils.
    if cp1
        [weights1,nodes1,p1] = butterfly3( m, cp1, bc1 )
      % [nodes1,weights1] = interpolationStencil( m, cp1, bc1 );
      % p1 = weights1 * m.nodes(nodes1,:);
    else
        nodes1 = v1;
        weights1 = 1;
        p1 = m.nodes(v1,:);
    end
    if cp2
        [weights2,nodes2,p2] = butterfly3( m, cp2, bc2 )
      % [nodes2,weights2] = interpolationStencil( m, cp2, bc2 );
      % p2 = weights2 * m.nodes(nodes2,:);
    else
        nodes2 = v1;
        weights2 = 1;
        p2 = m.nodes(v1,:);
    end
    pnodes1b = nodes1*2;
    pnodes1a = pnodes1b-1;
    pnodes2b = nodes2*2;
    pnodes2a = pnodes2b-1;

    % 3. Insert the new nodes into m.nodes and m.prismnodes.
    m.nodes(v1,:) = p1;
    m.nodes(v2,:) = p2;
    
    x1 = weights1 * m.prismnodes(pnodes1a,:);
    x2 = weights2 * m.prismnodes(pnodes2a,:);
    m.prismnodes(pv1a,:) = x1;
    m.prismnodes(pv2a,:) = x2;
    x1 = weights1 * m.prismnodes(pnodes1b,:);
    x2 = weights2 * m.prismnodes(pnodes2b,:);
    m.prismnodes(pv1b,:) = x1;
    m.prismnodes(pv2b,:) = x2;
    % We ought to adjust the prismnode values to be perpendicular to the
    % surface.
    
    % 4. Update fixedDFmap.  The new nodes both have the same
    % fixed DFs as the original node.
    m.fixedDFmap([pv2a(:); pv2b(:)],:) = m.fixedDFmap([pv1a(:); pv1b(:)],:);

    % 5. Estimate values for all the per-node data: morphogens,
    % morphogenclamp.
    x1 = weights1 * m.morphogens(nodes1,:);
    x2 = weights2 * m.morphogens(nodes2,:);
    m.morphogens(v1,:) = x1;
    m.morphogens(v2,:) = x2;

    x1 = weights1 * m.morphogenclamp(nodes1,:);
    x2 = weights2 * m.morphogenclamp(nodes2,:);
    m.morphogenclamp(v1,:) = x1;
    m.morphogenclamp(v2,:) = x2;
    
    % 6. Create the new cells.
    m.tricellvxs(c1,:) = [ v1 v2 v1a ];
    m.celledges(c1,:) = [ e1a e1 e3 ];
    if e2
        m.tricellvxs(c2,:) = [ v2 v1 v2a ];
        m.celledges(c2,:) = [ e2a e2 e3 ];
    end

    % 7. Split the neighbours of v1.  Create the neighbour lists for the
    % new nodes.  Update the edges and cells that should now have v2
    % instead of v1.
    cv2nz = cv2(cv2 ~= 0);
    if ~isempty(cv2nz)
        foo = m.tricellvxs(cv2nz,:);
        foo( foo==v1 ) = v2;
        m.tricellvxs(cv2nz,:) = foo;
    end

    foo = m.edgeends(ev2,:);
    foo( foo==v1 ) = v2;
    m.edgeends(ev2,:) = foo;

    if e2
        ch1 = [ ch1, e2a, c2, e3, c1 ];
    else
        ch1 = [ e3, c1, ch1 ];
    end
    ch2 = [ ch2, e1a, c1, e3, c2 ];
    m.nodecelledges{v1} = ch1;
    m.nodecelledges{v2} = ch2;
    
    if cd
        cde = m.celledges( cd, : );
        cde( cde==e1 ) = e1a;
        m.celledges( cd, : ) = cde;
    end
    if e2 && cb
        cbe = m.celledges( cb, : );
        cbe( cbe==e2 ) = e2a;
        m.celledges( cb, : ) = cbe;
    end
    
    % 8. Create the new edges.
    m.edgeends( [e1a e3], : ) = [ [v2 v1a]; [v1 v2] ];
    m.edgecells( [e1 e1a e3], : ) = [ [c1 ca]; [c1 cd]; [c1 c2] ];
    if e2
        m.edgeends( [e2 e2a], : ) = [ [v2 v2a]; [v1 v2a] ];
        m.edgecells( [e2 e2a], : ) = [ [c2 cc]; [c2 cb] ];
    end
    % Need to decide what to do with seam edges.
    
    % 9. Update the neighbour lists for v1a and v2a: where v1a had edge
    % e1, it must now have e1 c1 e1a, and where v2a had edge e2, it must
    % now have e2 c2 e2a.
    ch1a = m.nodecelledges{v1a};
    e1ei = find( ch1a(1,:)==e1 );
  % ch1a = [ ch1a(1:(e1ei-1)), e1, c1, e1a, ch1a((e1ei+1):end) ];
    ch1a = [ [ ch1a(1:(e1ei-1)), e1, e1a, ch1a(1,(e1ei+2):end) ]; ...
             [ ch1a(2:(e1ei-1)), c1, ch1a(2,(e1ei+1):end) ] ];
    m.nodecelledges{v1a} = ch1a;
    if e2
        ch2a = m.nodecelledges{v2a};
        e2ei = find( ch2a(1:2:end)==e2 ) * 2 - 1;
      % ch2a = [ ch2a(1:(e2ei-1)), e2, c2, e2a, ch2a((e2ei+1):end) ];
        ch2a = [ [ ch2a(1,1:(e2ei-1)), e2, e2a, ch2a(1,(e2ei+2):end) ]; ...
                 [ ch2a(2,1:(e2ei-1)), c2, ch2a(2,(e2ei+1):end) ] ];
        m.nodecelledges{v2a} = ch2a;
    end
    
    % 10. Create the remaining data.
    m.unitcellnormals( fullcellnbd, : ) = unitcellnormal( m, fullcellnbd );
    m = generateCellData( m, fullcellnbd );
    m.effectiveGrowthTensor(fullcellnbd,:) = 0;
    if ~isempty( m.directGrowthTensors )
        m.directGrowthTensors(fullcellnbd,:) = 0;
    end
    m = calcPolGrad( m, fullcellnbd );  % THIS NEEDS TO BE CHANGED: if the gradients
                                        % are frozen they will not be
                                        % recalculated, but they still need
                                        % adjustment.
    
    splitnode_valid = validmesh(m)
end

