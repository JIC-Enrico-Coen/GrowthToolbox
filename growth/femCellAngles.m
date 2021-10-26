function cellangles = femCellAngles( m, cis )
    if nargin < 2
        cis = 1:size(m.tricellvxs,1);
    else
        cis = cis(cis ~= 0);
    end
    cellangles = zeros( length(cis), 3 );
    for cii = 1:length(cis)
        ci = cis(cii);
        corners = m.nodes( m.tricellvxs(ci,:), : );
        cellangles(cii,:) = triangleAngles(corners)';
    end
end
