function [cmap,crange] = chooseColorMap( cmaptype, crange, monocolors, zerowhite, nsteps )
%[cmap,crange] = chooseColorMap( cmaptype, crange, monocolors, zerowhite, nsteps )
%   Return a color map and color range suitable for passing to the Matlab
%   functions colormap() and crange().
%
%   A valid color map is an N*3 array of real numbers in the range 0..1,
%   where N is at least 2.
%
%   A valid color range is either a pair of real numbers, the first less
%   than the second, or a pair of zeros.

    if (nargin < 5) || isempty(nsteps)
        nsteps = 50;
    end
    
    if isempty(crange)
        cmap = [ [1 1 1]; [1 1 1] ];
        crange = [0 0];
    else
        switch cmaptype
            case 'blank'
                cmap = [ [1 1 1]; [1 1 1] ];
                crange = [0 1];
            case { 'positive', 'rainbow' }
                [cmap,crange] = rainbowMap( crange, zerowhite, nsteps );
            case 'monochrome'
                [cmap,crange] = monoColormap( crange, monocolors, zerowhite, nsteps );
            case 'stress'
                [cmap,crange] = stresscolormap( crange, nsteps );
            case '3rdlayer'
                cmap = [ [ 0.5 0.5 1 ]; [ 1 1 0.8 ] ];
                crange = [ 0 1 ];
            case 'label'
                cmap = [ [ 1, 1, 0 ]; [ 0, 0.5, 0.7 ]; [ 0.8, 0.0, 0 ]; [ 0.8, 0.0, 0 ] ];
                crange = [ 0 3 ];
            otherwise
                fprintf( 1, 'chooseColorMap: unknown type "%s".\n', cmaptype );
                cmap = [ [1 1 1]; [1 1 1] ];
                crange = [0 0];
        end
    end
end

