function c = multicolourmgens( m, mgens, multibrighten, mgenbound )
%
%   m: a mesh
%   mgens: an array of morphogen indexes or names.
%   multibrighten: a parameter affecting how colours are mixed.
%   mgenbound: Not sure what this does.  Never used.

    mvals = getEffectiveMgenLevels( m, mgens );
    
    % Here we need to translate the morphogen values to colours using the
    % current plotting preferences for the morphogen.
    
%     mgencolors = zeros( getNumberOfVertexes(m), length(mvals), 3 );
%     for i=1:size(mvals,2)
%         mgencolors(:,i,:) = getMgenColors( m, mvals(:,i) );
%     end
%     combineColors(mgencolors);
        
    c = combineColors( mvals, ...
            m.mgenposcolors(:,mgens), ...
            m.mgennegcolors(:,mgens), ...
            m.mgen_plotpriority(mgens), ...
            m.mgen_plotthreshold(mgens), ...
            multibrighten, ...
            mgenbound, ...
            m.plotdefaults.canvascolor );
    return;
    
    
    
    
    numnodes = getNumberOfVertexes(m);
    c = ones(numnodes,3);
    backtransparency = ones( numnodes, 1 );
    if ~isempty(m.mgenposcolors)
        mgencolorspernode = zeros( numnodes, length(mgens), 3 );
        [mgenprio,mgenperm] = sort( m.mgen_plotpriority(mgens) );
        permmgens = mgens(mgenperm);
        thresholds = m.mgen_plotthreshold(permmgens);
        mvals = getEffectiveMgenLevels( m, permmgens );
        if (nargin == 4) && ~isempty(mgenbound)
            mvals = min( mvals, mgenbound );
        end
        if (length(mgens) > 1) || isempty( mgenbound )
            maxmvals = max( abs(mvals), [], 1 );
        else
            maxmvals = mgenbound;
        end
        for i=1:length(permmgens)
            mi = permmgens(i);
            if maxmvals(i) > 0
                % When there are multiple morphogens to plot, they are all
                % auto-scaled.  It would be better to allow each morphogen
                % to separately have its own scale, but this is not
                % implemented.
                mvals(:,i) = mvals(:,i)/maxmvals(i);
            end
            nonnegvals = mvals(:,i) >= 0;
            mgencolorspernode(nonnegvals,i,:) = ...
                1 - mvals(nonnegvals,i) * (1 - m.mgenposcolors(:,mi)');
            mgencolorspernode(~nonnegvals,i,:) = ...
                1 - mvals(~nonnegvals,i) * (1 - m.mgennegcolors(:,mi)');
            if (mgenprio(i) <= 0) && (mgenprio(i) == mgenprio(1))
                backtransparency = backtransparency .* (1 - mvals(:,i));
            end
        end
%         if false && all(mgenprio==mgenprio(1))
%             c = subtractiveMix( mgencolorspernode, multibrighten );
%             c = mixBackground( c, backtransparency, m.plotdefaults.canvascolor );
%         else
            x = find(mgenprio(2:end) ~= mgenprio(1:(end-1)));
            starts = [ 1, x+1 ];
            ends = [ x, length(mgenprio) ];
            separatebackground = (mgenprio(1) > 0) && any(m.plotdefaults.canvascolor ~= 1);
            if separatebackground
                c = repmat( m.plotdefaults.canvascolor, numnodes, 1 );
                istart = 1;
            else
                c = subtractiveMix( mgencolorspernode(:,starts(1):ends(1),:), multibrighten );
                c = mixBackground( c, backtransparency, m.plotdefaults.canvascolor );
                istart = 2;
            end
            for i=istart:length(starts)
                c1 = subtractiveMix( mgencolorspernode(:,starts(i):ends(i),:), multibrighten );
                mask = any( mvals(:,starts(i)) > thresholds(starts(i)), 2 );
                for j=(starts(i)+1):ends(i)
                    mask = mask | any( mvals(:,j) > thresholds(j), 2 );
                end
                c(mask,:) = c1(mask,:);
            end
%         end
    end
    
%     if false  % Canvas color is mixed in above.
%         % Mix with the canvas color.  When the canvas is white, this has no
%         % effect.  When the canvas is black, the colours we just computed are
%         % averaged with black.  For intermediate values, intermediate things
%         % happen.
%         opacity = 1-transparency;
%         canvasopacity = max( 1 - m.plotdefaults.canvascolor );
%         if canvasopacity > 0
%             bkgndWeight = transparency*canvasopacity;
%             totalWeight = opacity+bkgndWeight;
%             opacity = opacity./totalWeight;
%             bkgndWeight = bkgndWeight./totalWeight;
%             c = repmat( opacity, 1, 3 ).*c + bkgndWeight*m.plotdefaults.canvascolor;
%         end
%     end
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

