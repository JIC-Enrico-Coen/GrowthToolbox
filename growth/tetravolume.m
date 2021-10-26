function [volumes,edgelengthsq,alledges] = tetravolume( vxs, tetras )
%[volumes,edgelengthsq,alledges] = tetravolume( vxs, tetras )
%   Calculate the signed volume of each of a set of tetrahedrons.
%   The edgelengthsq and alledges results are available as a side effect of
%   the volume calculation.

    numtetras = size(tetras,1);
    vxs = vxs';
    allpositions = reshape( vxs(:,tetras(:,2:4)'), 3, 3, numtetras ); % D x (T-1) x NT
    allrefvxs = reshape( vxs(:,tetras(:,1)), 3, 1, numtetras ); % D x 1 x NT
    alledges = allpositions - repmat( allrefvxs, 1, 3, 1 ); % D x (T-1) x NT

    volumes = zeros( numtetras, 1 );
    for i=1:size(tetras,1)
        volumes(i) = det(alledges(:,:,i));
    end
    volumes = volumes/6;
    alledges = permute( [ alledges, (alledges(:,[2 3 3],:) - alledges(:,[1 1 2],:)) ], [2 1 3] ); % 6 x D x NT
    
    if nargout > 1
        edgelengthsq = permute( sum( alledges.^2, 2 ), [3 1 2] );
    end
end