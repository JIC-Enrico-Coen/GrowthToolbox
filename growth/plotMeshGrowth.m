function plotMeshGrowth( m, f1, f2 )
    if isfield( m.userdata, 'times' ) && isfield( m.userdata, 'areas' ) ...
            && ~isempty( m.userdata.times )
        if nargin < 2
            f1 = figure;
        end
        if nargin < 3
            f2 = figure;
        end
        timeunitname = m.globalProps.timeunitname;
        timeunitname(1) = upper(timeunitname(1));
        numpts = length(m.userdata.times);
        logareas = log(m.userdata.areas);
        rate = logareas(2:numpts) - logareas(1:(numpts-1));
        dt = m.userdata.times(2:numpts) - m.userdata.times(1:(numpts-1));
        figure(f1);
        plot( m.userdata.times, logareas, 'r-o' );
        set(get(gca,'XLabel'),'String',[ timeunitname, 's' ])
        set(get(gca,'YLabel'),'String','Ln area mmsq')
        figure(f2);
        plot( m.userdata.times(2:numpts), rate./dt, 'b-o' );
        set(get(gca,'XLabel'),'String',[ timeunitname, 's' ])
        set(get(gca,'YLabel'),'String','Karea mm2/hour')
    else
        beep;
        fprintf( 1, 'Area data not available.\n' );
    end
end