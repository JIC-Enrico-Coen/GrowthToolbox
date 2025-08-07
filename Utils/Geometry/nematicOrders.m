function nos = nematicOrders( nts, dims )
%nos = nematicOrders( nts )
%   Calculate the nematic order parameter of each of the nematic matrix
%   nts, a D * D * N matrix.
%
%   See also: nematicOrder

    if (nargin < 2) || (dims >= size(nts,1))
        dims = size(nts,1);
    end
    numTensors = size(nts,3);
    nos = zeros( numTensors, 1 );
    for nti=1:numTensors
        nos(nti) = nematicOrder( nts(:,:,nti), dims );
    end
end
