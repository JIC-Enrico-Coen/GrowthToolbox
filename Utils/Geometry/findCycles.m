function cycles = findCycles( edges )
%cycles = findCycles( edges )
%   EDGES is an N*2 array of "vertex indexes".
%
%   A cycle is a maximum sequence of distinct indexes into 1:N such that
%   the indexed edges form a sequence, each edge sharing a vertex index
%   with its predecessor and successor.  The cycles may be open or closed.
%
%   CYCLES will list every such sequence of edge indexes, each sequence
%   terminated by a zero.

    [vis,~,edgesv] = unique(edges);
    vis = vis';
    edgesv = reshape( edgesv, size(edges) );
    % edgesv is the same shape as edges, but its values are indexes into
    % vis.
    
    numvxs = length(vis);
    cycles = zeros(1,numvxs);
    ci = 0;
    
    % Make a binary matrix to record all of the edges, taken in both
    % directions.
    k = false(numvxs,numvxs);
    k( sub2ind( size(k), edgesv(:,1), edgesv(:,2) ) ) = true;
    k = k | k';
%     e = zeros(numvxs,numvxs);
%     e( sub2ind( size(k), edgesv(:,1), edgesv(:,2) ) ) = 1:size(edges,1);
%     e( sub2ind( size(k), edgesv(:,2), edgesv(:,1) ) ) = 1:size(edges,1);
    
    
    % numvxsrem counts the number of vertexes not yet assigned to a cycle.
    numvxsrem = numvxs;
    
    while true
        % Find the first unused edge.
        ki = find(k(:),1);
        if isempty(ki)
            % There are none -- we have finished.
            break;
        end
        
        % Get the two vertexes, and remove the edge from k.
        [vi,vj] = ind2sub(size(k),ki);
        k(vi,:) = false;
        k(:,vj) = false;
        k(:,vi) = false;
        
        % Begin a cycle at this vertex, and decrement numvxsrem.
        vloop = zeros(1,numvxsrem);
        vloop([1 2]) = [vi,vj];
        vli = 2;
        vi = vj;
%         eloop = zeros(1,numvxsrem);
%         eloop(vli-1) = e(ki);
        numvxsrem = numvxsrem-1;
        
        % Extend the loop forwards.
        while true
            vj = find(k(vi,:),1);
            if isempty(vj)
                % We have reached the end of the cycle in this direction.
                break;
            end
            % Add vj to the cycle and remove the edge between vi and vj.
            vli = vli+1;
            vloop(vli) = vj;
            k(vi,:) = false;
            k(:,vj) = false;
            k(vj,vi) = false;
%             eloop(vli-1) = e(vi,vj);
            vi = vj;
            numvxsrem = numvxsrem-1;
        end
        
        if isempty(vj)
            % We ran into the end of an open chain.
            % Reverse the chain.
            vloop(1:vli) = vloop( vli:-1:1 );
            vi = vloop(vli);
            % Extend the chain in the other direction.
            while true
                vj = find(k(:,vi),1);
                if isempty(vj) || (vj==vloop(1))
                    break;
                end
                vli = vli+1;
                vloop(vli) = vj;
                k(:,vi) = false;
                k(vj,:) = false;
                k(vi,vj) = false;
%                 eloop(vli-1) = e(vi,vj);
                vi = vj;
                numvxsrem = numvxsrem-1;
            end
        end
        ci1 = ci+vli+1;
        cycles( (ci+1):ci1 ) = [vis(vloop(1:vli)) 0];
        ci = ci1;
    end
end
