function [m,splitdata] = refinemesh( m, parameter, mode, iterative, maxiterations )
%[m,splitdata] = refinemesh( m, parameter, mode, iterative, maxiterations )
%   Refine a mesh by splitting every edge meeting a certain criterion,
%   depending on the 'mode' argument.

    if parameter <= 0, return; end
    
    if nargin < 3
        mode = 'random';
    end
    if nargin < 4
        iterative = false;
    end
    if nargin < 5
        maxiterations = 4;
    end

    isfraction = strcmp(mode,'random') || strcmp(mode,'longest');
    if isfraction
        iterative = false;
    end
    if ~iterative
        maxiterations = 1;
    end

    for i=1:maxiterations
        numedges = getNumberOfEdges( m );
        switch mode
            case 'random'
                [~,sortperm] = sort( rand( 1, numedges ) );
            case 'longest'
                lengthsqs = edgelengthsqs(m);
                [~,sortperm] = sort( lengthsqs, 'descend' );
            case 'longelements'
                lengthsqs = edgelengthsqs(m);
                if i==1
                    minlengthsq = min(lengthsqs);
                end
                longedges = lengthsqs > minlengthsq;
                if isVolumetricMesh( m )
                    longtris = all(longedges(m.FEconnectivity.feedges),2);
                    splitedges = unique( m.FEconnectivity.feedges( longtris, : ) );
                else
                    longtris = all(longedges(m.celledges),2);
                    splitedges = unique( m.celledges( longtris, : ) );
                end
                fprintf( '%s: %d long tris, %d edges, max ratio %f, 1/p2 %f.\n', ...
                    mfilename(), sum(longtris), length(splitedges), max(lengthsqs)/minlengthsq, 1/parameter^2 );
            case 'absolute'
                lengthsqs = edgelengthsqs(m);
                if i==1
                    minlengthsq = parameter^2;
                end
                splitedges = find( lengthsqs > minlengthsq );
            case 'relative'
                lengthsqs = edgelengthsqs(m);
                if i==1
                    minlengthsq = (parameter^2) * max(lengthsqs);
                end
                splitedges = find( lengthsqs > minlengthsq );
            otherwise
                return;
        end
        if isfraction
            e = ceil(numedges*parameter);
%             if e <= 0, e = 1; end
            if e > numedges, e = numedges; end
            splitedges = sortperm( 1:e );
        end
        if isempty(splitedges)
            break;
        end
        [m,splitdata] = splitalledges( m, reshape(splitedges,1,[]), true );
    end
    m = makeedgethreshsq( m );
end
