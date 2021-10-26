function chains = makeNonorientedChains( r )
%chains = makeNonorientedChains( r )
%   R is an N*3 array of triples [e v1 v2] specifying an undirected graph
%   in which e is an edge from vertex v1 to vertex v2.  Distinct rows must
%   have distinct values of e, and must not have the same two vertexes (in
%   either order).
%
%   R may also be N*2 specifying just the node pairs, in which case the
%   edges are considered to be 1:N.

    nv = length(uv);
    ne = size(vv,1);
    e = (1:ne)';
    
    if size(r,2)==2
        re = e;
        vv = r;
    else
        re = r(:,1);
        vv = r(:,[2 3]);
    end

    [uv,rv,vc] = unique( vv );
    uvv = reshape(vc,size(vv));
    

    incidence = full( sparse( uvv(:), [uvv(:,2);uvv(:,1)], [e;e], nv, nv, ne*2 ) );
    usededges = false( 1, ne );
    usedvxs = false( 1, nv );
    chains = emptystructarray( 'ce', 'cv' );
    
    for ei=1:ne
        if ~usededges(ei)
            ce = ei;
            cv = uvv(ei,:);
            usededges(ei) = true;
            usedvxs(cv) = true;
            incidence(cv(1),cv(2)) = 0;
            incidence(cv(2),cv(1)) = 0;
            lastv = cv(end);
            endfound = false;
            while true
                % Find an edge containing vertex lastv.
                [nextedge,nextv] = find( incidence(lastv,:) > 1, 1 );
                deadend = false;
                if isempty(nextedge)
                    % End of chain in this direction.
                    deadend = true;
                else
                    ce(end+1) = nextedge;
                    usededges(nextedge) = true;
                    if nextv==cv(1)
                        % Completed a loop.
                        break;
                    elseif usedvxs(nextv)
                        % End of chain in this direction.
                        deadend = true;
                    else
                        % Continue the chain.
                        usedvxs(nextv) = true;
                        cv(end+1) = nextv;
                        lastv = nextv;
                    end
                end
                if deadend
                    if endfound
                        break;
                    else
                        endfound = true;
                        % Repeat in the opposite direction.
                        ce = ce(end:-1:1);
                        cv = cv(end:-1:1);
                    end
                end
            end
            if length(ce) < length(cv)
                ce = [ce 0];
            end
            % Reindex here.
            chains(end+1) = struct('ce',re(ce),'cv',rv(cv) );
        end
    end
end
