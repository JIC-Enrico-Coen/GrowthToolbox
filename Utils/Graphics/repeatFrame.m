function numframes = repeatFrame( vout, frame, duration, includeFirst, includeLast )
%repeatFrame( vout, frame, duration, includeFirst, includeLast )
%   Write a given frame to a given VideoWriter object for a duration in
%   seconds. The duration is converted to a number of frames N using the
%   frame rate of VOUT. Frames 0 to N will be written, with frame 0 omitted
%   if includeFirst is false, and frame N omitted if includeLast is false.

    numframes = ceil( vout.FrameRate * duration );
    if includeFirst
        f0 = 0;
    else
        f0 = 1;
    end
    if includeLast
        f1 = numframes;
    else
        f1 = numframes-1;
    end
    for fi=f0:f1
        writeVideo( vout, frame );
    end
end

