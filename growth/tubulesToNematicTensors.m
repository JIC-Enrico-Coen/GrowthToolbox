function [nts,nos] = tubulesToNematicTensors( m )
%[nts,nos] = tubulesToNematicTensors( m )
%   Calculate the tensors representing the anisotropy of the tubules in
%   each finite element, and the measures of the anisotropies.

    numFEs = getNumberOfFEs( m );
    numTubules = getNumberOfTubules( m );
    nts = zeros( 3, 3, numFEs );
    segsPerElement = zeros( numFEs, 1 );
    
    for ti=1:numTubules
        t = m.tubules.tracks(ti);
        numsegs = size( t.globalcoords, 1 ) - 1;
        if numsegs > 0
            segmentVecs = t.globalcoords(2:end,:) - t.globalcoords(1:(end-1),:);
            nts1 = vecsToNematics( segmentVecs );
            for si=1:numsegs
                sci = t.segcellindex(si);
                nts(:,:,sci) = nts(:,:,sci) + nts1(:,:,si);
                segsPerElement(sci) = segsPerElement(sci) + 1;
            end
        end
    end
    
    if nargout > 1
        nos = nematicOrders( nts, 2 );
    end
end
