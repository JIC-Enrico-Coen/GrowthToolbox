function blankColorBar( h, color )
%blankColorBar( h, color )
%   Clear the contents of the colorbar, but keep it visible.

%     params = get( h, 'UserData' );
%     drawColorbar( h, '', [], [0,0], 'blank', color );
%     set( h, 'UserData', params );

    cla(h);
    set( h, 'Color', color, 'XTick', [], 'YTick', [], 'ZTick', [], 'Visible', 'on' );
%     bounds = axis(h);
% %     xlo = bounds(1)*2 - bounds(2);
% %     xhi = bounds(2)*2 - bounds(1);
% %     ylo = bounds(3)*2 - bounds(4);
% %     yhi = bounds(4)*2 - bounds(3);
%     patch( bounds([1 2 2 1]), bounds([3 3 4 4]), color, 'Parent', h );
%     axis(h,'off');
end

