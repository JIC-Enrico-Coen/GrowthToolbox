function [nodes,abserr, relerr, stretchchange,numiters,ok] = BSequilibrate( ...
            nodes, edgeends, restlengths, triangles, springconst, t, iters, finald, ...
            fig, progressCallback )
%[nodes,abserr, relerr, stretchchange,numiters,ok] = BSequilibrate( ...
%            nodes, edgeends, restlengths, springconst, t, iters, maxerr, finald, ...
%            fig, progressCallback )
%   Use the ball and spring method to equilibrate a mesh.

    if ~exist( 'progressCallback', 'var' )
        progressCallback = [];
    end
    dt = t/iters;
    numiters = iters;
    oldstretches = zeros( size(edgeends,1), 1 );
    ok = true;
    flipinterval = 10;
    DO_FLIPPING = true;
    for i=1:iters
        [d,abserr,relerr,stretches] = springdisplacementR0( nodes, edgeends, restlengths, springconst, dt );
        scale = 1; % max( 1, 0.01 * abserr/max(abs(d(:))) );
        stretchchange = max(abs((stretches-oldstretches)./restlengths));
        nodes = nodes + d*scale;
        status = [];
        
        
        if DO_FLIPPING && (mod(i,flipinterval)==0)
            % Detect and flip inverted triangles.
            negtri = true( size(triangles,1), 1 );
            for ci=1:size(triangles,1)
                tripts = nodes( triangles(ci,:), : );
                negtri(ci) = isFlipped( tripts );
            end
            if sum(negtri) >= length(negtri)/2
                negtri = ~negtri;
            end
            badtriangles = find(negtri)';
            for ci=badtriangles
                tripts = nodes( triangles(ci,:), : );
                if isFlipped( tripts )
                    tripts = bestflipvxs( tripts );
                    nodes( triangles(ci,:), : ) = tripts;
                end
            end
        end
        
        
        if (~isempty(fig)) && (mod(i,10)==0)
            handles = guidata( fig );
          % plotsimplemesh( handles.plotAxes, nodes, edgeends );
            plotsimplemesh( handles.plotAxes, nodes, edgeends, stretches );
            axis equal
            drawnow;
            if ~isempty(progressCallback)
                status = progressCallback( fig, ...
                        struct( 'iter', i, ...
                                'iters', iters, ...
                                'relstretchchange', stretchchange, ...
                                'target', finald ) );
              % fprintf( 1, 'BSequilibrate progress = %d\n', ok );
            end
        end
        
        
        if (~isempty(status)) || (stretchchange <= finald)
            numiters = i;
            break;
        end
        oldstretches = stretches;
    end
end

function is = isFlipped( tripts )
    v31 = tripts(3,:)-tripts(1,:);
    v21 = tripts(2,:)-tripts(1,:);
    is = (v21(1)*v31(2)-v21(2)*v31(1)) < 0;
end


