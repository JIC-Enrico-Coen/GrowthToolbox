function [m,vols,rectified] = calcFEvolumes( m, fei, rectify )
%[m,vols,rectified] = calcFEvolumes( m, fei, rectify )
%   Calculate the volumes of the given finite elements, by default all of
%   them, and store them in m.FEsets(1).fevolumes.  They are also returned
%   in vols.
%
%   Currently, this is only implemented for tetrahedral elements.
%
%   This depends only on the information in m.FEnodes (the vertex position)
%   and m.FEsets.fevxs (the finite element vertex indexes) and not on any
%   of the derived information in m.FEconnectivity.
%
%   If the RECTIFY argument is true (by default it is false), then the
%   vertex orderings of finite elements will be reversed if necessary to
%   make the calculation of signed volume positive.  Specifically, the
%   order of vertexes 3 and 4 will be reversed. Since this will
%   corrupt m.FEconnectivity, RECTIFY should only be true if
%   m.FEconnectivity is about to be recalculated.  The RECTIFIED result is
%   a boolean map of the finite elements, true for those that have been
%   rectified.

    numFEs = getNumberOfFEs( m );
    if (nargin < 2) || isempty(fei)
        fei = 1:numFEs;
    end
    rectified = false( numFEs, 1 );
    if ~isT4mesh(m)
        vols = [];
        return;
    end
    
    if nargin < 3
        rectify = false;
    end

    allFEs = numFEs==length(fei);
    
    %     n = length(fei);
%     foo = m.FEnodes( m.FEconnectivity.edgeends( m.FEconnectivity.feedges(fei,1:3)', : )', : );
%     foo = reshape( foo, 2, 9*n );
%     foo = permute( reshape( foo(1,:) - foo(2,:), 3, n, 3 ), [3 1 2] );
%     
%     vols1 = squeeze( foo(1,1,:).*(foo(2,2,:).*foo(3,3,:) - foo(2,3,:).*foo(3,2,:)) ...
%             + foo(1,2,:).*(foo(2,3,:).*foo(3,1,:) - foo(2,1,:).*foo(3,3,:)) ...
%             + foo(1,3,:).*(foo(2,1,:).*foo(3,2,:) - foo(2,2,:).*foo(3,1,:)) )/6;

        
        
    foo = reshape( m.FEnodes( m.FEsets.fevxs(fei,:)', : ), 4, [], 3 );
    foo = foo([2 3 4],:,:) - repmat( foo(1,:,:), 3, 1, 1 );
    foo = permute( foo, [1 3 2] );
    
    
    
    vols = squeeze( foo(1,1,:).*(foo(2,2,:).*foo(3,3,:) - foo(2,3,:).*foo(3,2,:)) ...
            + foo(1,2,:).*(foo(2,3,:).*foo(3,1,:) - foo(2,1,:).*foo(3,3,:)) ...
            + foo(1,3,:).*(foo(2,1,:).*foo(3,2,:) - foo(2,2,:).*foo(3,1,:)) )/6;
        
    if rectify
        rectifiedfei = fei(vols < 0);
        m.FEsets.fevxs( rectifiedfei, [3 4] ) = m.FEsets.fevxs( rectifiedfei, [4 3] );
%   The following not needed as FEconnectivity will be completely
%   recalculated after this procedure returns, but left in as
%   documentation.  This is how feedges and  fefaces should be revised
%   after a permutation of the vertexes of an element.
%         [edgeperm,faceperm] = vxPermtoEdgefacePerm( [1 2 4 3], m.FEsets.fe );
%         m.FEconnectivity.feedges(rectifiedfei,:) = m.FEconnectivity.feedges(rectifiedfei,edgeperm);
%         m.FEconnectivity.fefaces(rectifiedfei,:) = m.FEconnectivity.fefaces(rectifiedfei,faceperm);
        rectified(rectifiedfei) = true;
%         vols(rectifiedfei) = -vols(rectifiedfei);
        vols = abs(vols);
        if hasNonemptySecondLayer(m)
            bioVxsForRectification = rectified(m.secondlayer.vxFEMcell);
            m.secondlayer.vxBaryCoords(bioVxsForRectification,:) = ...
                m.secondlayer.vxBaryCoords(bioVxsForRectification,[1 2 4 3]);
        end
    end
    
%     vols = abs(vols);
    if allFEs
        m.FEsets(1).fevolumes = vols(:);
    else
        m.FEsets(1).fevolumes(fei(:)) = vols(:);
    end
    m.globalDynamicProps.currentVolume = sum( m.FEsets(1).fevolumes );
end
