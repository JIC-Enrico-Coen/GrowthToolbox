function [ m, didsplit, splitdata, numunsplit ] = trysplit( m, splitlong, splitbent, splitthin, splitmgen )
%[ m, didsplit, splitdata, numunsplit ] = trysplit( m, splitlong, splitbent, splitthin, splitmgen )    Split all edges which are
%longer than the threshold for splitting.  Split them in descending order
%of length.  Also split elements bordering an edge where the angle has changed
%by too much.
%
%The four further arguments, if supplied, override certain flags in
%m.globalProps:
%
%     splitlong: m.globalProps.allowSplitLongFEM;
%     splitbent: m.globalProps.allowSplitBentFEM;  % Not supported.
%     splitthin: m.globalProps.allowSplitThinFEM;  % Not supported.
%     splitmgen: m.globalProps.thresholdmgen;  % Pretty much never used.

    if nargin < 2
        splitlong = m.globalProps.allowSplitLongFEM;
        splitbent = m.globalProps.allowSplitBentFEM;  % Not supported.
        splitthin = m.globalProps.allowSplitThinFEM;  % Not supported.
        splitmgen = m.globalProps.thresholdmgen;  % Pretty much never used.
    end
    didsplit = false;
    splitdata = [];
    if usesNewFEs( m )
        [ m, didsplit, splitdata, numunsplit ] = trysplitVolumetric( m, splitlong, splitbent, splitthin, splitmgen );
        return;
    end
    
    if (m.globalProps.thresholdsq==0) ...
            && (splitmgen==0) ...
            && (m.globalProps.bendsplit==0)
        return;
    end
    
    if m.globalProps.maxFEcells > 0
        numelements = size(m.tricellvxs,1);
        maxsplits = floor( (m.globalProps.maxFEcells - numelements)/2 );
        if maxsplits <= 0
            return;
        end
    else
        maxsplits = size(m.edgeends,1);
    end
    
    longedges = [];
    bentedges = [];
    thinedges = [];
    mgenedges = [];
    
    % Find edges that have bent too much.
    if splitbent ...
            && (~m.globalProps.alwaysFlat) ...
            && (~m.globalProps.twoD) ...
            && (m.globalProps.bendsplit > 0)
        m.initialbendangle = reshape( m.initialbendangle, [], 1 );
        edgebending = abs( m.currentbendangle - m.initialbendangle );
        bentedgemap = ...
            (edgebending > m.globalProps.bendsplit) ...
            & (m.edgecells(:,2) ~= 0);
        edgebending = edgebending(bentedgemap);
        bentedges = reshape( m.celledges( m.edgecells( bentedgemap, : ), : ), [], 1 );
        if ~isempty(bentedges)
            timedFprintf( 1, 'Bent edges:' );
            fprintf( 1, ' %d', bentedges );
            fprintf( 1, '\n' );
        end
    end
    
    % Find edges that are too long.
    if splitlong
        longedges = findlongedges( m );
    end
%     if (force || splitlong) && (m.globalProps.thresholdsq > 0)
%         lengthsqs = edgelengthsqs(m);
%         if m.globalProps.thresholdsq > 0
%             splitthreshold = currentEdgeThreshold( m );
%             splitmargin = max( m.globalProps.splitmargin, 1 )^2;
%             if any( lengthsqs > splitthreshold*splitmargin )
%                 longedges = find( lengthsqs > splitthreshold*splitmargin );
%             else
%                 longedges = [];
%             end
%         end
%         if ~isempty(longedges)
%             timedFprintf( 1, 'Long edges:' );
%             fprintf( 1, ' %d', longedges );
%             fprintf( 1, '\n' );
%         end
%     else
%         longedges = [];
%     end
    
    if splitthin
        thinedges = [];
      % thinedges = findThinElements( m );  % Under development, does not
                                            % work yet.
    end
    
    % Find edges with too great a variation in morphogen. (NOT USED.)
    if false && (splitmgen > 0)
        mins = min( m.morphogens, [], 1 );
        maxs = max( m.morphogens, [], 1 );
        ranges = maxs-mins;
        whichmgens = ranges > 0;
        ranges = ranges(whichmgens);
        if any(whichmgens)
            numedges = size( m.edgeends, 1 );
            x = abs(m.morphogens( m.edgeends(:,1), whichmgens ) ...
                     - m.morphogens( m.edgeends(:,2), whichmgens ));
            mgenedgemap = [];
            for i=1:numedges
                x(i,:) = x(i,:) ./ ranges;
                mgenedgemap(i) = any( x(i,:) > splitmgen );
            end
            mgenedges = reshape( find(mgenedgemap), [], 1 );
        end
        if ~isempty(mgenedges)
            timedFprintf( 1, 'Mgen edges:' );
            fprintf( 1, ' %d', mgenedges );
            fprintf( 1, '\n' );
        end
    end
    
    edgestosplit = unique( [ bentedges; longedges; thinedges; mgenedges ] );
  % [ sortedlengths, perm ] = sort( lengthsqs(edgestosplit), 1, 'descend' );
  % edgestosplit(perm) = edgestosplit;
    if maxsplits < length(edgestosplit)
        p = randperm( length(edgestosplit) );
        edgestosplit = edgestosplit(p);
        edgestosplit = edgestosplit(1:maxsplits);
    end
  % edgestosplit
    if ~isempty(edgestosplit)
        [m,splitdata] = splitalledges( m, edgestosplit );
        didsplit = true;
    end
    numunsplit = length(edgestosplit) - size(splitdata,1);
end
