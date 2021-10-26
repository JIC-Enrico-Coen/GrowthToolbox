function figspec = setGUISizes( figspec )
    switch figspec.type
        case { 'OKButton', 'cancelButton' }
            figspec.naturalsize = [84 26];
        case 'radiobutton'
            % Size of button plus text -- but how to measure that?
            textlength = 20;
            figspec.naturalsize = [18+textlength 18];
        case 'checkbox'
            % Size of button plus text -- but how to measure that?
            textlength = 20;
            figspec.naturalsize = [18+textlength 18];
        case 'text'
            textlength = 20;
            figspec.naturalsize = [max(18,textlength) 18];
        case 'edittext'
            textlength = 20;
            figspec.naturalsize = [max(26,textlength) 26];
        case { 'group', 'panel' }
            if strcmp( figspec.type, 'group' )
                figspec = defaultFromStruct( figspec, struct( 'separation', 10, 'margin', 0 ) );
            else
                figspec = defaultFromStruct( figspec, struct( 'separation', 10, 'margin', 10 ) );
            end
            numchildren = numel( figspec.children );
            havenv = isfield( figspec, 'nv' ) && (figspec.nv > 0);
            havenh = isfield( figspec, 'nh' ) && (figspec.nh > 0);
            if havenv
                figspec.nh = ceil(numchildren/figspec.nv);
            else
                if havenh
                    figspec.nv = ceil(numchildren/figspec.nh);
                else
                    figspec.nv = numchildren;
                    figspec.nh = 1;
                end
            end
            sizes = zeros( 2, figspec.nv, figspec.nh );
            hi = 0;
            vi = 0;
            for i=1:numel(figspec.children)
                if mod(vi, figspec.nv)==0
                    vi = 1;
                    hi = hi+1;
                else
                    vi = vi+1;
                end
                ci = figspec.children{i};
                ci = setGUISizes( ci );
                sizes( :, vi, hi ) = ci.naturalsize;
                figspec.children{i} = ci;
            end
            size(sizes)
            colwidths = reshape( max( sizes(1,:,:), [], 2 ), 1, [] );
            rowheights = reshape( max( sizes(2,:,:), [], 3 ), 1, [] );
            figspec.naturalsize = [ sum(colwidths), sum(rowheights) ] ...
                + ([length(colwidths), length(rowheights)]-1)*figspec.separation + figspec.margin*2;
            hi = 0;
            vi = 0;
            for i=1:numel(figspec.children)
                if mod(vi, figspec.nv)==0
                    vi = 1;
                    hi = hi+1;
                else
                    vi = vi+1;
                end
                ci = figspec.children{i};
                ci.relpos = [ sum(colwidths(1:(hi-1))) + (hi-1)*figspec.separation + figspec.margin, ...
                              figspec.naturalsize(2) - ...
                                (sum(rowheights(1:vi)) + (vi-1)*figspec.separation + figspec.margin), ...
                              colwidths(hi), ...
                              rowheights(vi) ];
                figspec.children{i} = ci;
            end
        otherwise
            figspec.naturalsize = [0 0];
    end
end

