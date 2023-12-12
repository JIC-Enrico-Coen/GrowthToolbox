function c = directionalCurvature( m, ci, bcs, dirglobal, interpolationMode )
%c = directionalCurvature( m, ci, bcs, dirglobal )
%   Given a curvature field in m.auxdata.curvatures, a surface point
%   specified by an element ci and barycentric coordinates bcs, and a unit
%   tangent vector dirglobal, calculate the curvature along that direction
%   at that point.

    if nargin < 5
        interpolationMode = 'mid';
    end
    
    numitems = max( [ length(ci), size(bcs,1), size(dirglobal,1) ] );
    if length(ci)==1
        ci = ci + zeros(numitems,1);
    end
    if size(bcs,1)==1
        bcs = repmat( bcs, numitems, 1 );
    end
    if size(dirglobal,1)==1
        dirglobal = repmat( dirglobal, numitems, 1 );
    end
    c = zeros(numitems,1);

    if ~isfield( m, 'auxdata' ) || ~isfield( m.auxdata, 'curvatures' )
        return;
    end
    
    for i=1:numitems
        tricurvatures = m.auxdata.curvatures( :, :, m.tricellvxs( ci(i), : ) );
        switch interpolationMode
            case 'mid'
                pointcurvature = sum( tricurvatures .* shiftdim( bcs(i,:), -1 ), 3 );
            case 'min'
                traces = pagetrace( tricurvatures );
                [~,which] = min(traces);
                pointcurvature = tricurvatures( :, :, which );
            case 'max'
                traces = pagetrace( tricurvatures );
                [~,which] = max(traces);
                pointcurvature = tricurvatures( :, :, which );
        end
        c(i) = dirglobal(i,:) * pointcurvature * dirglobal(i,:)';
    end
end