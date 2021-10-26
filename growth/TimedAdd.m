function a=TimedAdd(realtimeNow,realtimeStart,realtimeStop)
    %a=TimedAdd(realtimeNow,realtimeStart,realtimeStop)
    %
    % a=1 if start<=realtime<stop
    % else
    % a=0 
    if (realtimeNow>=realtimeStart)&&(realtimeNow<realtimeStop)
        a=1;
    else
        a=0;
    end
end