function m = leaf_explode( m, amount )
%m = leaf_explode( m, amount )
%   Separate the connected components of m.
%
%   Arguments:
%       amount: Each component of m is moved so as to increase the distance
%       of its centroid from the centroid of m by a relative amount AMOUNT.
%       Thus AMOUNT==0 gives no movement and AMOUNT < 0 will draw the
%       pieces inwards.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    if nargin < 2
        fprintf( 1, '%s: No amount specified.\n', mfilename() );
        return;
    end
    if nargin > 2
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename, nargin-2 );
    end

    if amount ~= 0
        cc = connectedComponents( m );
        if length(cc) > 1
            centroid = sum( m.nodes, 1 )/size(m.nodes,1);
            for i=1:length(cc)
                vxs = unique( m.tricellvxs( cc{i}, : ) );
                centroid1 = sum( m.nodes(vxs,:), 1 )/length(vxs);
                delta = (centroid1 - centroid)*amount;
                m.nodes(vxs,:) = m.nodes(vxs,:) + repmat( delta, length(vxs), 1 );
                pvxs = vxs*2;
                pvxs = reshape( [ pvxs-1; pvxs ], 1, [] );
                m.prismnodes(pvxs,:) = m.prismnodes(pvxs,:) + repmat( delta, length(pvxs), 1 );
            end
        end
    end
end
