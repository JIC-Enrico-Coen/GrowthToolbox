function m = perturbSecondLayer( m, amount )
%m = perturbSecondLayer( m, amount )
%   Randomly move every second-layer vertex by the given amount.
%   The amount is a proportion of the barycentric coordinates.

    % Need to generate three random variables, which are independent except
    % for their sum being zero.
    
    if ~hasNonemptySecondLayer( m ), return; end
    if amount==0, return; end
    numvertexes = size( m.secondlayer.vxBaryCoords,1 );
    deltabc = (randBaryCoords( numvertexes ) - 1/3)*amount;
    m.secondlayer.vxBaryCoords = normaliseBaryCoords( m.secondlayer.vxBaryCoords + deltabc );
    m = calcCloneVxCoords( m );
    m = calcBioACellAreas( m );
end