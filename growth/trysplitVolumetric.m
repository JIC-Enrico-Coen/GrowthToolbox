function [ m, didsplit, splitdata, numunsplit ] = trysplitVolumetric( m, splitlong, splitbent, splitthin, splitmgen )
%[ m, didsplit, splitdata, numunsplit ] = trysplitVolumetric( m, force )    Split all edges which are
%longer than the threshold for splitting.  Split them in descending order
%of length.
%
%If FORCE is true (the default is false), then the splitting will happen
%even if m.globalProps.allowSplitLongFEM is false.

    if nargin < 2
        splitlong = m.globalProps.allowSplitLongFEM;
        splitbent = m.globalProps.allowSplitBentFEM;  % Not supported.
        splitthin = m.globalProps.allowSplitThinFEM;  % Not supported.
        splitmgen = m.globalProps.thresholdmgen;  % Pretty much never used.
    end
    didsplit = false;
    splitdata = [];
    
    if ~usesNewFEs( m )
        % Use trysplit() for surface meshes.
        return;
    end
    
    if isempty(regexp( m.FEsets(1).fe.name, '^S3-', 'once' ) )
        % This procedure applies only to tetrahedral meshes.
        return;
    end
    
    if (m.globalProps.thresholdsq==0) ...
            && (splitmgen==0)
        return;
    end
    
    if m.globalProps.maxFEcells > 0
        numelements = getNumberOfFEs( m );
        maxsplits = floor( (m.globalProps.maxFEcells - numelements)/2 );
        if maxsplits <= 0
            return;
        end
    else
        maxsplits = size(m.FEconnectivity.edgefaces,1);
    end
    
    longedges = [];
    thinedges = [];
    mgenedges = [];
    
    % Find edges that are too long.
    if splitlong
        longedges = findlongedges( m, splitlong );
    end
%     if (force || m.globalProps.allowSplitLongFEM) && (m.globalProps.thresholdsq > 0)
%         lengthsqs = edgelengthsqs(m);
%         if m.globalProps.thresholdsq > 0
%             splitthreshold = currentEdgeThreshold( m );
%             splitmargin = max(m.globalProps.splitmargin, 1)^2;
%             if any( lengthsqs > splitthreshold*splitmargin )
%                 longedges = find( lengthsqs > splitthreshold*splitmargin );
%             else
%                 longedges = [];
%             end
%         end
%         if ~isempty(longedges)
%             timedFprintf( 1, 'Splitting %d long edges:', length(longedges) );
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
        interpolatedMgens = find( strcmp( m.mgen_interpType, 'mid' ) );
        mins = min( m.morphogens(:,interpolatedMgens), [], 1 );
        maxs = max( m.morphogens(:,interpolatedMgens), [], 1 );
        ranges = maxs-mins;
        bounds = max( abs(mins), abs(maxs) );
        rangemap = ranges./bounds >= splitmgen;
        if any(rangemap)
            whichmgens = interpolatedMgens( rangemap );
            ranges = ranges(rangemap);
            x = abs(m.morphogens( m.edgeends(:,1), whichmgens ) ...
                     - m.morphogens( m.edgeends(:,2), whichmgens ));
            x = x ./ ranges;
            mgenedgemap = any( x > splitmgen, 2 );
            mgenedges = find( mgenedgemap );
            if ~isempty(mgenedges)
                timedFprintf( 1, 'Mgen edges:' );
                fprintf( 1, ' %d', mgenedges );
                fprintf( 1, '\n' );
            end
        end
    end
    
    edgestosplit = unique( [ longedges; thinedges; mgenedges ] );
  % [ sortedlengths, perm ] = sort( lengthsqs(edgestosplit), 1, 'descend' );
  % edgestosplit(perm) = edgestosplit;
    if maxsplits < length(edgestosplit)
        p = randperm( length(edgestosplit), maxsplits );
        edgestosplit = edgestosplit(p);
    end
  % edgestosplit
    if ~isempty(edgestosplit)
        [m,splitdata] = splitT4Edges3D( m, edgestosplit );
        didsplit = true;
    end
    numunsplit = length(edgestosplit) - size(splitdata,1);
end
