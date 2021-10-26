function vispts = visiblePoint( vxs, faces, pts )
%vispts = visiblePoint( vxs, faces, pts, pti )
%   vxs is a list of points in 3D space.
%   faces is a list of triples of indexes into vxs, specifying a list of
%   triangles.
%   pts is a set of points in 3D space.
%   The result is a bitmap specifying for each of the points in pts,
%   whether it is visible when looking in the +Z direction from infinitely
%   far away (i.e. if it is not occluded by any of the faces).
%
%   PTS can be a list of indexes into vxs.  In this case, the same
%   computation is carried out for those elements of VXS, except that a
%   face that a given point is a vertex of is never considered to occlude
%   that point.

    if isempty(pts)
        vispts = false(0,1);
        return;
    end
    
    isindexes = size(pts,2)==1;
    if isindexes
        % pts is a list of indexes into vxs.
        pti = pts;
        pts = vxs(pti,:);
    else
        pti = [];
    end

    occludingfaces = true(size(faces,1),1);
    ptsLo = min(pts,[],1);
    ptsHi = max(pts,[],1);
    farvxs = vxs(:,3) > ptsHi(3);
    occludingfaces( all(farvxs(faces),2) ) = false;
    xlovxs = vxs(:,1) < ptsLo(1);
    occludingfaces( all(xlovxs(faces),2) ) = false;
    xhivxs = vxs(:,1) > ptsHi(1);
    occludingfaces( all(xhivxs(faces),2) ) = false;
    ylovxs = vxs(:,2) < ptsLo(2);
    occludingfaces( all(ylovxs(faces),2) ) = false;
    yhivxs = vxs(:,2) > ptsHi(2);
    occludingfaces( all(yhivxs(faces),2) ) = false;
    
    vispts = true(size(pts,1),1);
    candidateFaces = find(occludingfaces);
    if ~isempty(candidateFaces)
        for j=1:size(pts,1)
            for i=candidateFaces'
                % fprintf( 1, 'Testing point %d against face %d\n', j, i );
                face = faces(i,:);
                if isindexes && any( face==pti(j) )
                    continue;
                end
                facepts = vxs(face,:);
                [occludes,~] = triangleOccludesPoint( facepts, pts(j,:), [0 0 1] );
                if occludes
                    vispts(j) = false;
                    break;
                end
            end
        end
    end
end
