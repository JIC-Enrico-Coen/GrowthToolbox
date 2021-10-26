function c = combineColors( values, poscolors, negcolors, priority, threshold, multibrighten, valuebound, backgroundcolor )
%c = combineColors( values, poscolors, negcolors, priority, threshold, multibrighten, valuebound, backgroundcolor )
%
%   Combine multiple colours into a single colour.
%
%   values: An N*V array specifying V values for each of N things.
%   poscolors:  A 3*V array specifying a colour for the positive values of
%       each value.
%   negcolors:  A 3*V array specifying a colour for the negative values of
%       each value.
%   priority:   A 1*V array specifying the priority of each value.  Higher
%       number = more in the foreground.
%   threshold:  A 1*V array specifying a threshold for each value.  Values
%   	closer to zero than their threshold are treated as zero.
%   multibrighten:  A parameter modifying how colours are mixed.
%   valuebound: All values are trimmed to within +/- valuebound.
%   backgroundcolor: The colour to show where there are no nonzero values
%       to plot.  The background's priority is that of the lowest priority
%       value or zero, whichever is less.
%
%   Alternatively, poscolors can be a colorinfo struct array, which is used
%   to map the values to colors. negcolors is then ignored.

    numnodes = size(values,1);
    numvals = size(values,2);
    c = ones(numnodes,3);
    backtransparency = ones( numnodes, 1 );
    
    
    if isempty(poscolors)
        return;
    end
    
    % Sort in ascending priority order: low priority = more in
    % background.
    [valueprio,valueperm] = sort( priority );
    values = values(:,valueperm);
    thresholds = threshold(valueperm);
    poscolors = poscolors(:,valueperm);
    if ~isempty(negcolors)
        negcolors = negcolors(:,valueperm);
    end

    % Apply the value bound.
    if ~isempty(valuebound)
        values = min( values, valuebound );
        values = max( values, -valuebound );
    end
    if (size(values,2) > 1) || isempty( valuebound )
        maxmvals = max( abs(values), [], 1 );
    else
        maxmvals = valuebound;
    end

    % Calculate the colour per node per value.  We also calculate how
    % much the background colour should show through.
    valuecolorspernode = zeros( numnodes, numvals, 3 );
    if isstruct( poscolors )
        for i=1:numvals
            [colors,poscolors(i)] = translateValuesToColors( values(:,i), poscolors(i) );
            valuecolorspernode(:,i,:) = permute( colors, [1 3 2] );
        end
    else
        for i=1:numvals
            if maxmvals(i) > 0
                % When there are multiple values to plot, they are all
                % auto-scaled.  It would be better to allow each morphogen
                % to separately have its own scale, but this is not
                % implemented.
                values(:,i) = values(:,i)/maxmvals(i);
            end
            nonnegvals = values(:,i) >= 0;
            valuecolorspernode(nonnegvals,i,:) = ...
                1 - values(nonnegvals,i) * (1 - poscolors(:,i)');
            valuecolorspernode(~nonnegvals,i,:) = ...
                1 - values(~nonnegvals,i) * (1 - negcolors(:,i)');
            if (valueprio(i) <= 0) && (valueprio(i) == valueprio(1))
                backtransparency = backtransparency .* (1 - values(:,i));
            end
        end
    end
    
    % Mix the colours.  Each set of colours of the same priority is
    % mixed.  Then each mixed set is overlaid on the previous one.
    x = find(valueprio(2:end) ~= valueprio(1:(end-1)));
    starts = [ 1, x+1 ];
    ends = [ x, length(valueprio) ];
    separatebackground = (valueprio(1) > 0) && any(backgroundcolor ~= 1);
    if separatebackground
        c = repmat( backgroundcolor, numnodes, 1 );
        istart = 1;
    else
        c = subtractiveMix( valuecolorspernode(:,starts(1):ends(1),:), multibrighten );
        c = mixBackground( c, backtransparency, backgroundcolor );
        istart = 2;
    end
    
    overthreshold = false( size(values) );
    if isstruct( poscolors )
        for i=1:numvals
            overthreshold(:,i) = abs(values(:,i))/max(abs(poscolors(i).range)) > thresholds(i);
        end
    else
        for i=1:numvals
            overthreshold(:,i) = values(:,i) > thresholds(i);
        end
    end
    
    for i=istart:length(starts)
        c1 = subtractiveMix( valuecolorspernode(:,starts(i):ends(i),:), multibrighten );
        
        mask = any( overthreshold(:,starts(i):ends(i)), 2 );
        
%         mask = any( values(:,starts(i)) > thresholds(starts(i)), 2 );
%         for j=(starts(i)+1):ends(i)
%             mask = mask | any( values(:,j) > thresholds(j), 2 );
%         end
        c(mask,:) = c1(mask,:);
    end
end

function c = mixBackground( c, transparency, bkgndcolor )
    canvasopacity = max( 1 - bkgndcolor );
    if canvasopacity > 0
        opacity = 1-transparency;
        bkgndWeight = transparency*canvasopacity;
        totalWeight = opacity+bkgndWeight;
        opacity = opacity./totalWeight;
        bkgndWeight = bkgndWeight./totalWeight;
        c = repmat( opacity, 1, 3 ).*c + bkgndWeight*bkgndcolor;
    end
end
