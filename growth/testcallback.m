function stop = testcallback(m)
%stop = testcallback(m)
%   Callback function for passing to mycgs().

    if isempty(m)
        stop = false;
    else
        stop = m.stop || userinterrupt( findStopButton( m ) );
    end
end
