function numframes = fadeBetweenFrames( vout, frame0, frame1, duration, includeFirst, includeLast )
%fadeBetweenFrames( vout, frame0, frame1, duration, includeFirst, includeLast )
%   Write a fade between two frames to a given VideoWriter object for a duration in
%   seconds. The duration is converted to a number of frames N using the
%   frame rate of VOUT. Frames 0 to N will be written, with frame 0 omitted
%   if includeFirst is false, and frame N omitted if includeLast is false.
%   Frame 0 is exactly frame0 with no admixture of frame 1; frame N is
%   exactly frame1 with no admixture of frame0.

    frame0 = img2double( frame0 );
    frame1 = img2double( frame1 );
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
        a = fadeCurve(fi/numframes);
        fadeFrame = (1-a) * frame0 + a * frame1;
        writeVideo( vout, fadeFrame );
    end
end

