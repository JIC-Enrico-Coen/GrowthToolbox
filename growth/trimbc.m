function bc = trimbc( bc, tolerance )
    if nargin < 2
        tolerance = 1e-8;
    end
    bc( bc < tolerance ) = 0;
    bc( bc > 1-tolerance ) = 1;
    
%     effectivelyOne = bc > 1-tolerance;
%     if any(effectivelyOne)
%         bc(effectivelyOne) = 1;
%         bc(~effectivelyOne) = 0;
%     else
%         bc( bc<tolerance ) = 0;
%         bc = bc/sum(bc);
%     end
end
