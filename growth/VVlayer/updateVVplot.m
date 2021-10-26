function updateVVplot( vvlayer, varargin )
%updateVVplot( vvlayer, ... )
%   Update the drawing of the VV layer, rather than redrawing it from
%   scratch.

    if isempty( vvlayer )
        return;
    end
    
    s = varargin;
    
    updatePts( 'C' );
    updatePts( 'W' );
    updatePts( 'M' );
    updateEdges( 'CM' );
    updateEdges( 'MM' );
    updateEdges( 'WW' );
    updateEdges( 'WM' );
    
    maxmgensqrt = sqrt( max( [ max(vvlayer.mgenC), max(vvlayer.mgenW), max(vvlayer.mgenM) ] ) );
    updateValues( 'C' );
    updateValues( 'W' );
    updateValues( 'M' );
    
    
    function updateValues( e )
        hold on;
        ptsname = ['vvpts', e];
        valuename = ['vxval', e];
        
        mgenname = ['mgen', e ];
        if any(strcmp( valuename, s ))
            newdotsizes = sqrt(vvlayer.(mgenname))*(25/maxmgensqrt);
            for ii=1:size(vvlayer.(ptsname),1)
                havemgen = vvlayer.(mgenname)(ii) > 0;
                hadmgen = ishandle( vvlayer.plothandles.(valuename)(ii) );
                if havemgen
                    newdotsize = newdotsizes(ii);
                else
                    newdotsize = -1;
                end
                if hadmgen
                    curdotsize = get( vvlayer.plothandles.(valuename)(ii), 'MarkerSize' );
                else
                    curdotsize = -1;
                end
                if curdotsize ~= newdotsize
                    if havemgen
                        if hadmgen
                            % change the size of a point
                            set( vvlayer.plothandles.(valuename)(ii), 'MarkerSize', newdotsize );
                        else
                            % plot a new point
                            p = vvlayer.(ptsname)(ii,:);
                            vvlayer.plothandles.(valuename)(ii) = plot3( p(1),p(2),p(3), ...
                                'Parent', vvlayer.ax, ...
                                'Marker','o', ...
                                'MarkerSize',newdotsize, ...
                                'MarkerFaceColor','b','MarkerEdgeColor','b');
                        end
                    elseif hadmgen
                        % delete an old point
                        delete( vvlayer.plothandles.(valuename)(ii) );
                        vvlayer.plothandles.(valuename)(ii) = -1;
                    else
                        % do nothing
                    end
                end
            end
        end
        hold off;
    end
    
    function updateEdges( e )
        vt1 = e(1);
        vt2 = e(2);
        ptsfield1 = ['vvpts' vt1];
        ptsfield2 = ['vvpts' vt2];
        if any(strcmp( ptsfield1, s )) || any(strcmp( ptsfield2, s ))
            edgefield = ['edge', e];
            for ii=1:length(vvlayer.plothandles.(edgefield))
                p1 = vvlayer.(ptsfield1)(vvlayer.(edgefield)(ii,1));
                p2 = vvlayer.(ptsfield2)(vvlayer.(edgefield)(ii,2));
                set( vvlayer.plothandles.(edgefield)(ii), ...
                    'XData', [p1(1) p2(1)], ...
                    'YData', [p1(2) p2(2)], ...
                    'ZData', [p1(3) p2(3)] );
            end
        end
    end
        
    function updatePts( p )
        handlename = ['vv' p];
        dataname = ['vvpts' p];
        if any(strcmp( dataname, s ))
            plotptsNew( vvlayer.plothandles.(handlename), vvlayer.(dataname) );
        end
    end
end

function plotptsNew( h, pts )
    set( h, ...
        'XData', pts(:,1), ...
        'YData', pts(:,2), ...
        'ZData', pts(:,3) );
end
