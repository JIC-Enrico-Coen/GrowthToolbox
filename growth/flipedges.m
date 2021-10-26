function m = flipedges( m )
%m = flipedges( m )
%   Find every place where it would improve the mesh to flip an edge, and
%   flip it.
%
%   For foliate meshes only.

    if isVolumetricMesh( m )
        return;
    end

    lengthratio = 1;
    flipmaxangle = 0.3;
    anglethreshold = 0.95*pi/4;
    ANGLEMARGIN = 0.95;
    
    % Save the absolute positions of all the streamline vertexes.
    streamlinevxs = cell( 1, length(m.tubules.tracks) );
    for i=1:length(m.tubules.tracks)
        streamlinevxs{i} = baryToEuc( m, m.tubules.tracks(i).vxcellindex, m.tubules.tracks(i).barycoords );
    end
    
    numedges = size(m.edgeends,1);
    numflipedges = 0;
  % flippableEdges = find( eligibleEdges( m ) );
  % for i=1:length(flippableEdges)
  %     ei = flippableEdges(i);
    for ei=1:numedges
        % Never flip seam edges.
        if m.seams(ei), continue; end
        
        % Border edges can't be flipped.
        c2 = m.edgecells(ei,2);
        if c2==0, continue; end
        
        c1 = m.edgecells(ei,1);
        
        % Don't flip an edge if the exterior angle across the edge is
        % greater than a threshold.
        anglec1c2 = cellangle( c1, c2 );
        if anglec1c2 > flipmaxangle
            continue;
        end

        % Don't flip if the distribution of the polarising morphogens is
        % sufficiently non-flat.
        GRADFLATNESS_THRESHOLD = 0.2;
        gp = findPolGrad( m, [c1,c2] );
        ngp1 = norm(gp(1,:));
        ngp2 = norm(gp(2,:));
        if (ngp1 ~= 0) || (ngp2 ~= 0)
            ndgp = norm( gp(2,:) - gp(1,:) );
            if ndgp > min(ngp1,ngp2)*GRADFLATNESS_THRESHOLD
                continue;
            end
        end

        eends = m.edgeends(ei,:);
        e1vec = m.nodes( eends(1), : );
        e2vec = m.nodes( eends(2), : );
        oldedgevec = e1vec - e2vec;
        oldedgelengthsq = dot(oldedgevec,oldedgevec);
        cv1_1 = find( m.celledges(c1,:)==ei );
        v1 = m.tricellvxs( c1, cv1_1 );
        cv2_1 = find( m.celledges(c2,:)==ei );
        v2 = m.tricellvxs( c2, cv2_1 );
        % Check v1 and v2 are nonempty.
        v1a = m.tricellvxs( c1, mod(cv1_1,3)+1 );
        v2a = m.tricellvxs( c2, mod(cv2_1,3)+1 );
        
        % There must not already be an edge linking v1 and v2.
        nce1 = m.nodecelledges{v1};
        nce1 = nce1(1:2:end);
        testends = m.edgeends(nce1,:)==v2;
      % testends = any(testends,2);
      % badends = find(testends);
        if any(any(testends))
          % badedges = nce1(badends);
          % fprintf( 1, 'flipedges: an edge between %d and %d already exists.\n', ...
          %     v1, v2 );
          % badedges
          % badedgeends = m.edgeends(badedges,:)
            continue;
        end
        
        v1vec = m.nodes( v1, : );
        v2vec = m.nodes( v2, : );
        v1avec = m.nodes( v1a, : );
        v2avec = m.nodes( v2a, : );
        if false
            % The new edge must be significantly shorter than the old,
            % otherwise do nothing.
            newedgevec = v1vec - v2vec;
            newedgelengthsq = dot(newedgevec,newedgevec);
            if newedgelengthsq >= oldedgelengthsq*lengthratio
              % fprintf( 1, '%s: Edge length condition not met for edge %d: %.3f * %.3f >= %.3f.\n', ...
              %     mfilename(), ei, newedgelengthsq, lengthratio, oldedgelengthsq );
                continue;
            end
        end
        
        % The minimum of the new angles must exceed the minimum of the old,
        % otherwise do nothing.
        a1 = triangleAngles( [ v1vec; v1avec; v2avec ] );
        a2 = triangleAngles( [ v2vec; v2avec; v1avec ] );
        oldMinAngle = min( [ a1; a2 ] );
        if oldMinAngle > anglethreshold
            continue;
        end
        newa1 = triangleAngles( [ v1vec; v1avec; v2vec ] );
        newa2 = triangleAngles( [ v2vec; v2avec; v1vec ] );
        newMinAngle = min( [ newa1; newa2 ] );
        
        % None of the face angles of the tetrahedron formed by the old and
        % new cells should be greater than flipmaxangle.
        newc1normal = trinormal( m.nodes( [ v1 v1a v2 ], : ) );
        newc2normal = trinormal( m.nodes( [ v2 v2a v1 ], : ) );
        anglec1ac2a = vecangle( newc1normal, newc1normal );
        anglec1c1a = veccellangle( newc1normal, c1 );
        anglec1c2a = veccellangle( newc2normal, c1 );
        anglec2c1a = veccellangle( newc1normal, c2 );
        anglec2c2a = veccellangle( newc2normal, c2 );
        maxcellangle = max( [ anglec1ac2a, ...
                              anglec1c1a, anglec1c2a anglec2c1a, anglec2c2a ] );
        if maxcellangle > flipmaxangle
            continue;
        end

        if newMinAngle * ANGLEMARGIN <= oldMinAngle
          % fprintf( 1, '%s: no improvement in angle for edge %d: old %.3f new %.3f.\n', ...
          %     mfilename(), ei, min(oldAngles), min(newAngles) );
            continue;
        end
        
        % All hurdles passed.  Flip the edge.
      % fprintf( 1, 'Flipping edge %d oldma %f newma %f maxcellangle %f.\n', ...
      %     ei, oldMinAngle, newMinAngle, maxcellangle );
        m = flipedge( m, ei );
        numflipedges = numflipedges+1;
    end

    if numflipedges > 0
        % Compute the new relative positions of all the streamline vertexes.
        for i=1:length(m.tubules.tracks)
            vxs = streamlinevxs{i};
            for j=1:length( m.tubules.tracks(i).vxcellindex )
                [ m.tubules.tracks(i).vxcellindex(j), m.tubules.tracks(i).barycoords(j,:) ] = ...
                    findFE( m, vxs(j,:) );
            end
        end
        fprintf( 1, '%d edges flipped.\n', numflipedges );
        if ~validmesh( m )
            error('flipedge: Mesh validation failure');
        end
    end

function a = cellangle( cx, cy )
    if cy==0
        a = pi*4;
    else
        a = vecangle( m.unitcellnormals(cx,:), ...
                      m.unitcellnormals(cy,:) );
    end
end

function a = veccellangle( v, cy )
    if cy==0
        a = pi*4;
    else
        a = vecangle( v, ...
                      m.unitcellnormals(cy,:) );
    end
end
end
