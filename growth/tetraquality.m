function [quality,volume] = tetraquality( vxs, tetras )
%q = tetraquality( vxs, tetras )
%   VXS is a V*3 matrix holding a set of vertex positions.
%   TETRAS is a T*4 set of quadrupples of indexes into VXS,
%   The result is a measure of the quality and the volume of every
%   tetrahedron.  The quality is 1 for a regular tetrahedron, and less than
%   that for any other.

%     numtetras = size(tetras,1);
%     vxs = vxs';
%     allpositions = reshape( vxs(:,tetras(:,2:4)'), 3, 3, numtetras ); % D x (T-1) x NT
%     allrefvxs = reshape( vxs(:,tetras(:,1)), 3, 1, numtetras ); % D x 1 x NT
%     alledges = allpositions - repmat( allrefvxs, 1, 3, 1 ); % D x (T-1) x NT
    
    [volume,edgelengthsq,~] = tetravolume( vxs, tetras );
    maxedgelengthsq = max( edgelengthsq, [], 2 );
%     boxvol2 = maxedgelengthsq .^ 1.5;  % The cube of the longest edge length
%     quality1 = (1.414213562373*6)*abs(volume)./boxvol2;
    quality = (2.0396489*(abs(volume).^(1/3)))./sqrt(maxedgelengthsq);


%     edgevecs = vxs(2:4,:) - repmat( vxs(1,:), 3, 1 );
%     tetravol6 = abs(det(edgevecs));  % 6 times the volume of the tetrahedron.
%     edgevecs = [ edgevecs; (edgevecs([2 3 1],:) - edgevecs) ];
%     boxvol2 = max( sum( edgevecs.^2, 2 ) ) .^ 1.5;  % The cube of the longest edge length
%     quality = 1.414213562373*tetravol6/boxvol2;
end
