function c = unwrapCircularData( c, period )
    if isempty(c)
        return;
    end
    
    sz = size(c);
    c = c(:);
    steps = c(2:end)-c(1:(end-1));
    jumps = zeros(size(steps));
    jumps(steps>period/2) = -period;
    jumps(steps<-period/2) = period;
    c = c + [0; cumsum(jumps)];
    c = reshape( c, sz );
end