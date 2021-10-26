function newpos = moveFigureToScreen( fig, screen )
    newpos = [];
    if isempty(fig) || ~ishghandle(fig) || ~isa( f, 'matlab.ui.Figure' )
        return;
    end
    screenPositions = get(0, 'MonitorPositions');
    numscreens = size(screenPositions,1);
    if (screen < 1) || (screen > numscreens)
        return;
    end
    screenPos = screenPositions( screen, : );
    u = fig.Units;
    fig.Units = 'pixels';
    oldpos = fig.Position;
    ir = intersectRect( screenPos, oldpos );
    newpos = oldpos;
    if all( ir==oldpos )
        % Figure is already entirely on that screen.
        return;
    end
%     if ir(3)*ir(4) > 0
%         movegui
%     end
    newpos([1 2]) = screenPos([1 2]);
    fig.Position = newpos;
    fig.Units = u;
end

function ir = intersectRect( pos1, pos2 )
    ii1 = intersectIntervals( [pos1([1 3]); pos2([1 3])] );
    ii2 = intersectIntervals( [pos1([2 4]); pos2([2 4])] );
    ir = [ii1(1) ii2(1) ii1(2) ii2(2)];
end

function ii = intersectIntervals( intervals )
    left = intervals(:,1);
    right = left + intervals(:,2);
    ii = [ max(left,[],1) min(right,[],1) ];
    ii(:,2) = max( ii(:,2)-ii(:,1), 0 );
end

