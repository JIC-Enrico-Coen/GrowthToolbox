function m = fillstreamlines( m )
%OBSOLETE: WILL NOT WORK.

    figure(1)
    cla;
    hold on;
    numcells = size(m.tricellvxs,1);
    m.hasstreamline = false( numcells, 1 );
    m.streambcstart = zeros( numcells, 3 );
    m.streambcend = zeros( numcells, 3 );
    rp = randperm(numcells);
    for ci=rp
        if ~m.hasstreamline(ci)
            m = traceStreamline( m, [], ci );
        end
    end
    hold off
    
    figure(2)
    cla;
    hold on
    plotstreamlines( m );
    hold off
end

function plotstreamlines( m )
    numcells = size(m.tricellvxs,1);
    for ci=1:numcells
        if m.hasstreamline(ci)
            vxs = m.nodes( m.tricellvxs(ci,:), : );
            pts = [ m.streambcstart(ci,:); m.streambcend(ci,:)] * vxs;
            plotpts( gca, pts, '-r', 'LineWidth', 2 );
          % drawnow
        end
    end
end
