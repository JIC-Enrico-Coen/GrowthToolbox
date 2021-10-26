function cq = femCellQualities( m, cis )
    if nargin < 2
        cis = 1:size(m.tricellvxs,1);
    else
        cis = cis(cis ~= 0);
    end
    cq = zeros( length(cis), 1 );
    for cii = 1:length(cis)
        ci = cis(cii);
        corners = m.nodes( m.tricellvxs(ci,:), : );
        cq(cii) = triangleQuality(corners);
    end
end
