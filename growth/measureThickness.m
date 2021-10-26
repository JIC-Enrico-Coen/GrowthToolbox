function t = measureThickness( m )
    evenmax = size(m.prismnodes,1);
    oddmax = evenmax-1;
    diffs = m.prismnodes( 1:2:oddmax, : ) - m.prismnodes( 2:2:evenmax, : );
    t = sum( sqrt(dot(diffs,diffs,2)), 1 )/(evenmax/2);
end
