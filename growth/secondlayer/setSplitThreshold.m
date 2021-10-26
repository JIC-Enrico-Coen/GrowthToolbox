function m = setSplitThreshold( m, scale, cis )
%m = setSplitThreshold( m )
%   Set the split threshold to be the given multiple of the maximum cell
%   diameter.

    if nargin < 2, scale = sqrt(2); end
    numcells = length( m.secondlayer.cells );
    if nargin < 3, cis = 1:numcells; end
    
    if 1
        maxe = 0;
        for cii=1:length(cis)
            covarmx = cov(m.secondlayer.cell3dcoords( m.secondlayer.cells(cis(cii)).vxs, : ));
            if any(isnan(covarmx(:)))
                % No can do.
                e = inf;
            else
                es = eig(covarmx);
                e = sqrt(abs(es(3)));
            end
            if maxe < e, maxe = e; end
        end
        e = maxe*2;
    else
        edgevecs = m.secondlayer.cell3dcoords( m.secondlayer.edges(:,1), : ) - ...
                       m.secondlayer.cell3dcoords( m.secondlayer.edges(:,2), : );
        edgelengthssq = dotproc2( edgevecs', edgevecs' );
        e = sqrt( max( edgelengthssq ) );
    end
    newthreshold = e*scale;
    if m.secondlayer.splitThreshold < newthreshold
        m.secondlayer.splitThreshold = newthreshold;
    end
end
