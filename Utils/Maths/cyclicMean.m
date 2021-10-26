function [meanPos,meanValue,order] = cyclicMean( data, datatype, period, method )
%meanTheta = cyclicMean( data, period, datatype, method )
%   If DATATYPE is 'bins', then DATA is an array of bin sizes. Bin numbers
%   1 to n represent numbers (1:n)*(period/n).
%
%   If DATATYPE is 'value', then DATA is an array of values in the range
%   [0,PERIOD) (or if they lie outside this range, they are reduced mod
%   PERIOD).
%
%   METHOD specifies the method of calculating a cyclic mean. Possible
%   values are:
%
%   'average'  The angles are interpreted as points on the unit circle, and
%   the mean of those points is selected.  MEANPOS is that point. MEANTHETA
%   is its direction (NaN if meanPos is [0 0]). ORDER is the length of
%   MEANPOS.
%
%   'ellipse'  The angles are interpreted as diameters of the unit circle,
%   and a best-fit ellipse to all the endpoints of these lines is selected.
%   MEANANGLE is the direction of its major axis (subject to rescaling).
%   ORDER is the eccentricity of the ellipse (the ratio of interfocal
%   distance to major axis).
%
%   'quad' A weighted average of the angles relative to a candidate for
%   mean angle is obtained, and the candidate varied so as to maximise the
%   result. The weighting is an inverted parabolam maximum at zero and zero
%   at +/- period/2. This defines MEANTHETA. ORDER is...

    switch lower(method)
        case 'average'
            values = convertData( data, period, datatype, 'values' );
%             switch lower(mode)
%                 case 'bins'
%                     values = bins2values( data, period );
%                 case 'values'
%                     values = mod( data, period );
%             end
            values1 = values(:)*(2*pi/period);
            c = cos(values1);
            s = sin(values1);
            meanPos = sum( [c,s] )/length(values1);
            order = norm(meanPos);
            meanValue = atan2( meanPos(2), meanPos(1) )*(period/(2*pi));
            meanPos = order*[ cos(meanValue) sin(meanValue) ];
        case 'ellipse'
            values = convertData( data, period, datatype, 'values' );
            angles = convertNematic( values, period, true );
            c = cos(angles);
            s = sin(angles);
            [principalAxes,eigs,~] = bestFitEllipsoid( [c(:),s(:)], [], [0 0] );
            order = max(eigs)/sum(eigs);
            meanValue = mod( atan2( principalAxes(2,2), principalAxes(1,2) ), pi )*period/pi;
            meanPos = principalAxes(:,2)*order;
        case 'quad'
            values = convertData( data, period, datatype, 'values' );
            bincounts = convertData( data, period, datatype, 'bins' );
            meanValue = MyCalcCyclicMeanTheta(bincounts, period);
            meanTheta = meanValue*2*pi/period;
            order = calcOrderCoefficient(values,meanValue,period);
            meanPos = [ cos(meanTheta), sin(meanTheta) ] * order;
            xxxx = 1;
    end
end

function bincounts = values2bins( values, numbins, period )
    binwidth = period/numbins;
    values = mod( values, period );
    values = floor( values*(numbins/period) ) + 1;
%     values = mod( values, numbins ) + 1;
    [values,reps,~] = countreps( sort(values) );
    bincounts = zeros(1,numbins);
    bincounts(values) = reps;
end

function values = bins2values( bincounts, period )
    numbins = length(bincounts);
    numvalues = sum(bincounts);
    binvalues = (1:numbins)*(period/numbins);
    values = zeros(1,numvalues);
    vstart = 1;
    for i=1:length(bincounts)
        vnextstart = vstart+bincounts(i);
        values( vstart:(vnextstart-1) ) = binvalues(i);
        vstart = vnextstart;
    end
end

function [data,period] = convertNematic( data, period, nematic )
    if ~nematic
        return;
    end
    data = mod( data, period );
    data = [ data(:)', data(:)'+period ];
    period = 2*period;
end

function newdata = convertData( data, period, oldtype, newtype )
    if strcmp( oldtype, newtype )
        newdata = data;
    else
        switch oldtype
            case 'values'
%                 newdata = values2bins( data, length(data)*2, period );
                newdata = values2bins( data, length(data)*2, period );
            case 'bins'
                newdata = bins2values( data, period );
        end
    end
end

function meanTheta = MyCalcCyclicMeanTheta(thetaArray, period)
% function returns meanTheta, the mean angle from an array of angles
% Requires upLim and lowLim which are the upper and lower
% limits of the search.

    % append thetaArray to the beginning and end of itself to allow for the
    % cyclic nature of the data. Find the current point for start of search
    numbins = length(thetaArray);
    thetaArray = thetaArray(:)';
    upLim = length(thetaArray);
    thetaArray = [thetaArray, thetaArray, thetaArray];
    currentPoint = upLim + 1;

    % Begin the search for theta
    % eq(1:upLim) = 0;
    a(1:upLim) = 0;
    halfwidth = floor((upLim-1)/2);
    filter = ((-halfwidth):halfwidth).^2;
    for theta = 1:upLim
        upperWindowLimit = currentPoint + halfwidth;
        lowerWindowLimit = currentPoint - halfwidth;
        windowData = thetaArray(lowerWindowLimit:upperWindowLimit);
        eq = windowData .* filter;
        a(theta) = sum(eq);


        currentPoint = currentPoint + 1;
    end

    [~,ptr] = min(a);

    meanTheta = (ptr-0.5)*period/numbins;

end

function order = calcOrderCoefficient(values,meanValue,period)
    values = (values - meanValue)*(pi/period);
    order = mean((cos(values).^2) - (sin(values).^2));
end
