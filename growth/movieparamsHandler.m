function movieparamsHandler()
    curitem = gcbo();  % This is the button that was clicked.
    handles = guidata(curitem);
    fig = ancestor(curitem,'figure');
    ud = get( fig, 'userdata' );
    tag = get( curitem,'Tag');
    if isempty(tag)
        return;
    end
    switch tag
        case 'usersnaps'
            fprintf( 1, '%s: %s not implemented.\n', mfilename(), tag );
        case 'stagesnaps'
            fprintf( 1, '%s: %s not implemented.\n', mfilename(), tag );
        case 'movieframes'
            fprintf( 1, '%s: %s not implemented.\n', mfilename(), tag );
%         case 'preserveaspect'
%             changedaspect();
        case 'includecolorbar'
            changedcb();
        case { 'width', 'height', 'magnification' }
            [x,ok] = getDoubleFromDialog( handles.(tag) );
            if ~ok
                set( handles.(tag), 'String', sprintf( '%d', round(ud.(tag)) ) );
                beep;
            else
                ud.userfixed = tag;
                ud.(tag) = x;
                restoreConsistency();
            end
        case 'antialias'
            ud.antialias = get( handles.antialias, 'Value' );
            warntoobig();
        otherwise
            fprintf( 1, '%s: %s not recognised.\n', mfilename(), tag );
    end
    set( fig, 'userdata', ud );
    
    
    
    
function changedaspect()
    restoreConsistency();
end

function changedcb()
    if get( handles.includecolorbar, 'Value' )
        ud.w0 = ud.wp + ud.wcb;
        ud.h0 = max( ud.hp, ud.hcb );
    else
        ud.w0 = ud.wp;
        ud.h0 = ud.hp;
    end
    restoreConsistency();
end

function warntoobig()
    sz = ud.w0*ud.h0*(ud.magnification*(1+ud.antialias))^2;
    big = sz >= 16e6; % 4000x4000, or 2000x2000 with anti-aliasing.
    set( handles.X_toobigwarning, 'Visible', boolchar(big,'on','off') );
end

function restoreConsistency()
    switch ud.userfixed
        case 'width'
            requirewidth();
        case 'height'
            requireheight();
        case 'magnification'
            requiremag();
    end
    warntoobig();
end
    
function requirewidth()
    if true % get( handles.preserveaspect, 'Value' )
        ud.magnification = ud.width/ud.w0;
        ud.height = ud.magnification*ud.h0;
        set( handles.height, 'String', sprintf( '%d', ceil(ud.height) ) );
    else
        [~,~,ud.magnification] = fitrect( ud.w0, ud.h0, ud.width, ud.height );
    end
    set( handles.magnification, 'String', sprintf( '%g', ud.magnification ) );
end
    
function requireheight()
    if true % get( handles.preserveaspect, 'Value' )
        ud.magnification = ud.height/ud.h0;
        ud.width = ud.magnification*ud.w0;
        set( handles.width, 'String', sprintf( '%d', ceil(ud.width) ) );
    else
        [~,~,ud.magnification] = fitrect( ud.w0, ud.h0, ud.width, ud.height );
    end
    set( handles.magnification, 'String', sprintf( '%g', ud.magnification ) );
end
    
function requiremag()
    if true % get( handles.preserveaspect, 'Value' )
        ud.width = ud.magnification*ud.w0;
        ud.height = ud.magnification*ud.h0;
        set( handles.width, 'String', sprintf( '%d', ceil(ud.width) ) );
        set( handles.height, 'String', sprintf( '%d', ceil(ud.height) ) );
    else
        w = ud.magnification*ud.w0;
        if ud.width < w
            ud.width = w;
            set( handles.width, 'String', sprintf( '%d', ceil(ud.width) ) );
        end
        h = ud.magnification*ud.h0;
        if ud.height < h
            ud.height = h;
            set( handles.height, 'String', sprintf( '%d', ceil(ud.height) ) );
        end
    end
end
end

function [w,h,mag] = fitrect( w0, h0, w1, h1 )
% Scale a rectangle of w0 by h0 as large as possible and fit into a
% rectangle w1 by h1, while holding its aspect ratio constant.  Return the
% resulting width, height, and magnification.  The results will have the
% following properties:
%   w <= w1, h <= h1, and at least one of these is an equality.
%   mag is the smaller of w1/w0 and h1/h0.

    magw = w1/w0;
    magh = h1/h0;
    if magw < magh
        mag = magw;
        h = h0*mag;
        w = w1;
    else
        mag = magh;
        w = w0*mag;
        h = h1;
    end
end

