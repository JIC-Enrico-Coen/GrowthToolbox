function m = springEquilibrate( m, iters, frac )
% m = springEquilibrate( m, iters, frac )

    for i=1:iters
        m = springforces( m, true );
        m.nodes = m.nodes + frac*m.nodeforces;
        m = forceFlatThickness( m );
        mins = min(m.prismnodes,[],1);
        maxs = max(m.prismnodes,[],1);
        axisRange = reshape( [mins;maxs], 1, [] );
        m = leaf_plot(m,'axisRange',axisRange );
    end
end

