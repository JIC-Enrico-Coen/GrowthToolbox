function stop = teststopbutton(m)
%stop = teststopbutton(m)
%   Determine whether the stop button has been pressed, and if so, record.

    if isempty(m)
        stop = false;
    elseif m.stop
        stop = true;
    else
        stop = userinterrupt( findStopButton( m ) );
        m.stop = stop;
    end
    
    if stop
        xxxx = 1;
    end
end
