function [faceaxis1,faceaxis2,edgeaxis] = faceedgecodeToAxes( m, fec )
%[faceaxis1,faceaxis2,edgeaxis] = faceedgecodeToAxes( m, fec )
%   This function is specific to the project GFT_Tubules_20260701.

    if fec(2)==char(0)
        xxxx = 1; %#ok<NASGU>
    end
    faceindex1 = find( fec(1)==m.auxdata.faceLetters, 1 );
    faceindex2 = find( fec(2)==m.auxdata.faceLetters, 1 );
    
    faceaxisletter1 = m.auxdata.directedAxisLetters( faceindex1 );
    faceaxisletter2 = m.auxdata.directedAxisLetters( faceindex2 );
    
    faceaxis1 = lower(faceaxisletter1) - 'x' + 1;
    faceaxis2 = lower(faceaxisletter2) - 'x' + 1;
    [~,edgeaxis] = othersOf3( faceaxis1, faceaxis2 );
end

