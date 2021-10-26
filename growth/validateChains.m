function ok = validateChains( m )
%ok = validateChains( m )
%   Check the validity of m.nodecelledges, if it exists.

    ok = true;
    if ~isfield( m, 'nodecelledges' )
        return;
    end

    tcv = m.tricellvxs;
    for vi=1:length(m.nodecelledges)
        nce = m.nodecelledges{vi};
        if isempty( nce )
            warning( 'validateChains:chains1', ...
                'Node %d has an empty array of neighbours.', ...
                vi );
            ok = false;
        else
            ne = m.edgeends( nce(1,:), : );
            ne_valid = (ne(:,1)==vi) ~= (ne(:,2)==vi);
            if ~all(ne_valid)
                for ei=1:length(ne_valid)
                    if ~ne_valid(vi)
                        warning( 'validateChains:chains2', ...
                            'Vertex %d is not an end of edge %d in its chain: ends are [%d %d].', ...
                            vi, ei, m.edgeends(ei,1), m.edgeends(ei,2) );
                        ok = false;
                    end
                end
            end
            ncelen = size(nce,2);
            for ncei=1:ncelen
                ei1 = nce(1,ncei);
                ci = nce(2,ncei);
                ei2 = nce(1,mod(ncei,ncelen)+1);
                % ei1 and ei2 must each have vi as one of their ends.
              % if isempty(find(m.edgeends(ei1,:)==vi,1))
              % if ~any(m.edgeends(ei1,:)==vi)
                %{
                if (vi ~= m.edgeends(ei1,1))&& (vi ~= m.edgeends(ei1,2))
                    warning( 'validmesh:chains2', ...
                        'Vertex %d is not an end of edge %d in its chain: ends are [%d %d].', ...
                        vi, ei1, m.edgeends(ei1,1), m.edgeends(ei1,2) );
                    ok = false;
                end
              % if isempty(find(m.edgeends(ei2,:)==vi,1))
                if (vi ~= m.edgeends(ei2,1))&& (vi ~= m.edgeends(ei2,2))
                    warning( 'validmesh:chains3', ...
                        'Vertex %d is not an end of edge %d in its chain: ends are [%d %d].', ...
                        vi, ei2, m.edgeends(ei2,1), m.edgeends(ei2,2) );
                    ok = false;
                end
                %}
                if ci ~= 0
                    % ei1 and ei2 must be edges of ci in orientation order,
                    % with vi between them.
                    ce = m.celledges(ci,:);
                    ei1ci = find(ce==ei1);
                    ei2ci = find(ce==ei2);
                    no_ei1ci = isempty(ei1ci);
                    no_ei2ci = isempty(ei2ci);
                    if no_ei1ci
                        warning( 'validmesh:chains4', ...
                            'Vertex %d has invalid edge %d: should be an edge of cell %d, whose edges are [%d %d %d].', ...
                            vi, ei1, ci, ce(1), ce(2), ce(3) );
                        ok = false;
                    end
                    if no_ei2ci
                        warning( 'validmesh:chains5', ...
                            'Vertex %d has invalid edge %d: should be an edge of cell %d, whose edges are [%d %d %d].', ...
                            vi, ei2, ci, ce(1), ce(2), ce(3) );
                         ok = false;
                    end
                    if (~no_ei1ci) && ~no_ei2ci
                        ei12ci = ei1ci-ei2ci;
                        if (ei12ci ~= 1) && (ei12ci ~= -2) % mod(ei1ci-ei2ci,3) ~= 1
                            warning( 'validmesh:chains6', ...
                                'Vertex %d has invalid edge ordering in chain: e %d c %d e %d, cell edges are [%d %d %d].\n', ...
                                vi, ei1, ci, ei2, ce(1), ce(2), ce(3) );
                            ok = false;
                        end
                        nci = mod(ei1ci,3)+1;
                        if vi ~= tcv(ci,nci)
                            warning( 'validmesh:chains7', ...
                                'Vertex %d has invalid cell %d in chain: should be vertex %d but vertexes are [%d %d %d].', ...
                                vi, ci, nci, tcv(ci,1), tcv(ci,2), tcv(ci,2) );
                            ok = false;
                        end
                    end
                end
            end
        end
    end
end
