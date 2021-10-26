function cmap = colorSteps( colors, stepsPerInterval, open1, open2 )
%cmap = colorSteps( colors, numsteps, open1, open2 )
%   Construct a colour map going through the given list of COLORS, an N*3
%   array.  NUMSTEPS has length N-1 and specifies how many intervals there
%   should be between successive colors.
%
%   If OPEN1 is true, the first value will be omitted.
%   If OPEN2 is true, the last value will be omitted.
%   OPEN1 and OPEN1 default to false.

    if nargin < 3, open1 = false; end
    if nargin < 4, open2 = false; end
    numintervals = length(stepsPerInterval);
    cmaps = cell( numintervals, 1 );
    for i=1:numintervals
        cmaps{i} = colorStep( colors(i,:), colors(i+1,:), stepsPerInterval(i), open1 && (i==1), open2 || (i<numintervals) );
    end
    cmap = cell2mat( cmaps );
end
 
