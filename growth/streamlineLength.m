function len = streamlineLength( s, m )
%len = streamlineLength( s, m )
%   Calculate the physical length of a streamline, or an array of them.

    len = zeros(1,length(s));
    for i=1:length(s)
        v = zeros(size(s(i).barycoords));
        for j=1:length(s(i).vxcellindex)
            v(j,:) = s(i).barycoords(j,:) * m.nodes( m.tricellvxs( s(i).vxcellindex(j), : ), : );
        end
        len(i) = sum( sqrt( sum( (v(2:end,:) - v(1:(end-1),:)).^2, 2 ) ) );
    end
end
