function setGUIColors( h, backColor, foreColor )
%setGUIColors( h )
%   h is a handle to a GUI object.  This routine crawls over h to
%   determine the parent-child relations, then colours the background of
%   items according to their depth in the tree.  The figure background is
%   given the backColor, and successively nested panels are given colours
%   tending towards the foreColor.

    getNesting( h, 1, backColor, foreColor );
end

function getNesting( h, n, backColor, foreColor )
    if isempty(h) || ~ishandle(h), return; end
    [htype,ok] = tryget(h,'Type');
    if ~ok
        return;
    end
    hstyle = tryget(h,'Style');
    switch htype
        case ''
            cn = 0;
        case 'uimenu'
            cn = 0;
        case 'axes'
            switch get( h, 'Tag' )
                case 'colorbar'
                    cn = n-1;
                otherwise
                    cn = 0;
            end
        case 'figure'
            cn = n;
        case { 'uipanel', 'uibuttongroup' }
            switch get( h, 'Tag' )
                case { 'morphdistpanel', 'runsimpanel', ...
                       'bio1panel', 'bio2panel', ...
                       'growthtensorspanel' }
                    cn = n;
                case 'editorpanel'
                    cn = n;
                case 'picturepanel'
                    cn = -1;
                otherwise
                    if strcmp( get( h, 'bordertype' ), 'none' )
                        cn = n-1;
                    else
                        cn = n;
                    end
            end
        case 'uicontrol'
            switch hstyle
                case { 'pushbutton', 'togglebutton' }
                    cn = -1;
                case { 'radiobutton', 'checkbox' }
                    cn = n-1;
                case { 'text' }
                    t = get( h, 'Tag' );
                    switch t
                        case 'scalebar'
                            cn = 0;
                        otherwise
                            cn = n-1;
                    end
                    if strcmp(t,'colortexthi')
                        xxxx = 1;
                    elseif strcmp(t,'colortextlo')
                        xxxx = 1;
                    end
                case { 'edit', 'slider', 'listbox', 'popupmenu' }
                    cn = 0;
                case { 'frame' }
                    cn = n;
                otherwise
                  % fprintf( 1, '%s is a %s of unknown style %s.\n', ...
                  %     htag, htype, hstyle );
                    cn = 0;
            end
        otherwise
          % fprintf( 1, '%s has unknown type "%s" and style "%s".\n', ...
          %     htag, htype, hstyle );
            cn = 0;
    end
    if cn ~= 0
        if cn==-2
            color = [1 0 1];
        elseif cn==-1
            color = [1 1 1];
        else
            color = widgetColor(cn, backColor, foreColor);
        end
        setGUIElementColor( h, color );
    end
    hc = tryget( h, 'Children' );
    for i=1:length(hc)
        getNesting( hc(i), cn+1, backColor, foreColor );
    end
end

function c = widgetColor( n, backColor, foreColor )
%N is assumed to range from 1 to at most 5.
    MAXN = 5;
    n = min(n,MAXN);
    q = (n-1)/(MAXN-1);
    p = 1-q;
    
    SCALEN = -log(0.8);
    p = exp( -(n-1)*SCALEN );
    q = 1-p;
    
    c = p*backColor + q*foreColor;
  % c = [1 1 1] - 0.55*[1 0.3 1]*(1 - 0.1*n);
end
