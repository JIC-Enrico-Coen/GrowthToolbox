function v = pathViaEdge( v1, v2, e1, e2 )
%v = pathViaEdge( v1, v2, e1, e2 )
%   Set v3 to the point on the line joining e1 and e2 which minimises the
%   length of the path v1 v v2.
%   All vectors must be row vectors.
    % Error: there is a degenerate case where v1 and v2 both lie on the
    % line from e1 to e2
    edir = e2-e1;
    vdir = v2-v1;
    n = crossproc2(vdir,edir);
    n = crossproc2(vdir,n);
    if (n*n')==0
        % Degenerate case: v2-v1 is parallel to e2-e1.  Return the
        % midpoint of v1 and v2.
        v = (v1+v2) * 0.5;
    else
        pn = crossproc2(vdir,n);
        v = lineplaneIntersection( e1, e2, n, v1 );
    end
end
