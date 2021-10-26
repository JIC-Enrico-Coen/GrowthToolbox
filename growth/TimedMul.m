function a=TimedMul(realtimeNow,realtimeStart,realtimeStop,Value)
    %a=TimedMul(realtimeNow,realtimeStart,realtimeStop)
    %
    % a=value if start<=realtime<stop
    % else
    % a=1 
    if (realtimeNow>=realtimeStart)&&(realtimeNow<realtimeStop)
        a=Value;
    else
        a=1;
    end
end