function longedges = findlongedges( m, do )
    if nargin < 2
        do = true;
    end
    if do && (m.globalProps.thresholdsq > 0)
        lengthsqs = edgelengthsqs(m);
        if m.globalProps.thresholdsq > 0
            splitthreshold = currentEdgeThreshold( m );
            splitmargin = max( m.globalProps.splitmargin, 1 )^2;
            longedges = find( lengthsqs > splitthreshold * splitmargin );
        end
%         if ~isempty(longedges)
%             fprintf( 1, 'Long edges:' );
%             fprintf( 1, ' %d', longedges );
%             fprintf( 1, '\n' );
%         end
    else
        longedges = [];
    end
end
