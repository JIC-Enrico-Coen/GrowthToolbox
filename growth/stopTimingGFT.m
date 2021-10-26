function elapsedTime = stopTimingGFT(cmd,startTic)
%elapsedTime = stopTimingGFT(cmd,startTic)
%   startTic is the value returned by a previous call of startTimingGFT(),
%   before executing the GFTbox command CMD.
%
%   If the output argument elapsedTime is requested, it will be the elapsed
%   time, provided that the previous call of startTimingGFT found timing to
%   be enabled, otherwise it is -1.
%
%   With no output argument, if timing was enabled then a message is
%   printed to the console reporting the command and the elapsed time.
%
%   The time reported does not include any time taken to replot the mesh or
%   update the GUI from changed properties of the mesh.
%
%   See also: startTimingGFT.

    if startTic ~= 0
        elapsedTime = toc(startTic);
        if nargout==0
            fprintf( 1, 'Command %s took %g seconds.\n', cmd, elapsedTime );
        end
    else
        elapsedTime = -1;
    end
end
