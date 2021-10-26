function plotProfile( userdata, moviefile )
%plotProfile( userdata, moviefile )
%   DATA is an N*P matrix of N rows of P values.  Plot each row of values
%   against index, successively. A movie will be made if MOVIEFILE is
%   present and nonempty. The movie will be in uncompressed AVI format.
%   MOVIEFILE is either a relative or absolute math name.

    makemovie = (nargin >= 2) && ~isempty(moviefile);
    minx = 0;
    maxx = 0;
    maxval = 0;
    for i=1:length(userdata.poldata)
        v = userdata.poldata{i};
        minx = min( minx, min( v(1,:) ) );
        maxx = max( maxx, max( v(1,:) ) );
        maxval = max( maxval, max(max( v(2:size(v,1),:)) ) );
    end
    if makemovie
        movie = VideoWriter( moviefile, 'Compression', 'Uncompressed AVI' );
        open(movie);
    end
    for i=1:length(userdata.poldata)
        cla;
        hold on;
        v = userdata.poldata{i};
        xx = v(1,:);
        [xx,perm] = sort(xx);
        xx1 = (xx-min(xx))/(max(xx)-min(xx));
        for j=2:size(v,1)
            yy = v(j,perm);
            plot( xx1, yy, '-o' );
        end

        axisRange = [min(xx1) max(xx1) 0 maxval];
        axis( axisRange );
        text((axisRange(1)+axisRange(2))/2, (axisRange(3)+axisRange(4))/2, ...
            sprintf( 'diffusion %.3f\nsource %.3f\nsink %.3f\nproduction %.3f\ndecay %.3f\ndilution %s\ngrowth %.3f\ntime %.3f\ntimestep %.3f\nlength %.3f to %.3f', ...
                userdata.DIFFUSION, ...
                userdata.SOURCE_STRENGTH, ...
                userdata.SINK_STRENGTH, ...
                userdata.PRODUCTION, ...
                userdata.DECAY, ...
                boolchar( userdata.GROWTH==0, 'n/a', boolchar( userdata.DILUTION, 'on', 'off' ) ), ...
                userdata.GROWTH, ...
                userdata.TOTALTIME, ...
                userdata.TIMESTEP, ...
                userdata.INIT_LENGTH, ...
                userdata.FINAL_LENGTH ), ...
            'HorizontalAlignment','right');
        hold off;
        drawnow
        if makemovie
            frame = getframe(gca);
            writeVideo(movie,frame);
        end
    end
    
    if makemovie
        print( gcf(), '-dpng', '-r300', moviefile );
        close( movie );
    end
end
