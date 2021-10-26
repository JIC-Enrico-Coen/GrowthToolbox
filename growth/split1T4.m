function [fevxs,ok,bcs] = split1T4( edges, pts )
%results = split1T4( edges, pts )
%   Split a T4 or T4Q element at all of the given edges.  The set of edges
%   must be either a single edge, two opposite edges, three edges of one
%   face, or all edges.
%
%   pts is ignored unless all edges are to be split.  If supplied, it
%   contains the positions of the new nodes.

% What should the results be?  A list of new vertexes, indexed from 4
% onwards, and a list of the quadruples of vertexes that are the new set of
% FEs.

    ok = true;
    if isempty(edges)
        return;
    end

    global FE_T4Q
    
    fevxs = [ 1 2 3 4 ];
    edges = sort(edges);
    edgeends = FE_T4Q.edges(:,edges);
    edgemidpointbcs = zeros( size(edgeends,2), 4 );
    edgemidpointbcs = setrowitems( edgemidpointbcs, edgeends', 0.5+zeros(size(edgeends,2),2) );
    bcs = [ eye(4); edgemidpointbcs ];
    
    switch length(edges)
        case 1
            fevxs = [ 1 2 3 4; 1 2 3 4 ];
            fevxs(1,edgeends(1)) = 5;
            fevxs(2,edgeends(2)) = 5;
        case 2
            % NEEDS UPDATING TO PRESERVE SENSE OF TETRAS.
            A = edgeends(1,1);
            B = edgeends(2,1);
            C = edgeends(1,2);
            D = edgeends(2,2);
            ok = A~=C && A~=D && B~=C && B~=D;
            if ok
                fevxs = repmat( 1:4, 4, 1 );
                fevxs(1,[A C]) = [5 6];
                fevxs(2,[A D]) = [5 6];
                fevxs(3,[B C]) = [5 6];
                fevxs(4,[B D]) = [5 6];
            end
        case 3
            % NEEDS UPDATING TO PRESERVE SENSE OF TETRAS.
            vxs = unique(edgeends(:));
            ok = length(vxs) == 3;
            if ok
                % Get fourth vertex v4.
                v4 = setdiff(fevxs,vxs);
                % For each of the other three vertexes, find which two
                % edges it belongs to.
                eis = [ floor( (find(vxs(1)==edgeends(:)) + 1)/2 )';
                        floor( (find(vxs(2)==edgeends(:)) + 1)/2 )';
                        floor( (find(vxs(3)==edgeends(:)) + 1)/2 )' ] + 4;
                fevxs = [ [ [v4;v4;v4], eis, vxs ]; [v4 5 6 7] ];
            end
        case 6
            % NEEDS UPDATING TO PRESERVE SENSE OF TETRAS.
            vxedges = invertIndexArray( edgeends', [], 'array' );
            if nargin >= 2
                % Find the shortest diagonal of the central octahedron.
                % It will be split into four tetrahedra along that axis.
                
                % The pairs of opposite edges are indexed 1 6, 2 5, and 3 4.
                octadiags = pts([1 2 3],:) - pts([6 5 4],:);
%                 octadiags = [ -1 -1 1 1; -1 1 -1 1; -1 1 1 -1 ] * pts;
                diaglensq = sum( octadiags.^2, 2 );
                [~,whichdiag] = min(diaglensq);
            else
                % If we are not given the location of the vertexes, choose
                % an arbitrary diagonal.
                whichdiag = 1;
            end
            opps = [whichdiag 7-whichdiag]+4;
            circum = othersOf3(whichdiag);
            circum = [ circum, 7-circum ]'+4;
            fevxs = [ 1 vxedges(1,:)+4;
                      2 vxedges(2,:)+4;
                      3 vxedges(3,:)+4;
                      4 vxedges(4,:)+4;
                      [ repmat(opps,4,1), [circum, circum([2 3 4 1]) ] ] ];
            % Note that fevxs is determined by whichdiag, which takes the
            % value 1, 2, or 3, and vxedges is determined by the FE_T4Q
            % element, which does not change. So we could just switch on
            % whichdiag and provide an explicit table of numbers for fevxs
            % in each case.  The algorithmic method is preferable because
            % it makes visible the thinking behind the construction, and
            % guarantees consistency, and requires no changes if for any
            % reason the internal indexing of the FE_T4Q element were
            % changed.
        otherwise
            ok = false;
    end
    
    % Check: the bcs should be the barycentric coordinate of the vertexes.
end