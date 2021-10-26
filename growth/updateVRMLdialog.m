function updateVRMLdialog( h )
    if nargin < 1
        h = gcbo;
    end
    handles = guidata( h );
    tag = get( h, 'Tag' );
    if ~isfield( handles, tag )
        return;
    end
    switch tag
        case 'size_scaleby'
            set( handles.do_size_scaleby, 'Value', 1 );
            set( handles.do_size_scaleto, 'Value', 0 );
        case 'size_scaleto'
            set( handles.do_size_scaleby, 'Value', 0 );
            set( handles.do_size_scaleto, 'Value', 1 );
        case 'thickness_scaleby'
            set( handles.do_thickness_scaleby, 'Value', 1 );
            set( handles.do_thickness_scaleto, 'Value', 0 );
            set( handles.do_thickness_setall, 'Value', 0 );
        case 'thickness_scaleto'
            set( handles.do_thickness_scaleby, 'Value', 0 );
            set( handles.do_thickness_scaleto, 'Value', 1 );
            set( handles.do_thickness_setall, 'Value', 0 );
        case 'thickness_setall'
            set( handles.do_thickness_scaleby, 'Value', 0 );
            set( handles.do_thickness_scaleto, 'Value', 0 );
            set( handles.do_thickness_setall, 'Value', 1 );
        case 'thickness_setmin'
            set( handles.do_thickness_setmin, 'Value', 1 );
        case 'figure'
            setDefaultGUIColors( h );
    end

    ud = get( handles.figure, 'UserData' );
    displaybbdiam = ud.bbdiam;
    displaythickrange = ud.thickrange;
    
    params = struct();
    extractVRMLParam('size_scaleby');
    extractVRMLParam('size_scaleto');
    extractVRMLParam('thickness_scaleby');
    extractVRMLParam('thickness_scaleto');
    extractVRMLParam('thickness_setall');
    extractVRMLParam('thickness_setmin');
    
    if ~isempty(params.size_scaleby)
        displaybbdiam = ud.bbdiam*params.size_scaleby;
        ud.sizescale = params.size_scaleby;
    end
    if ~isempty(params.size_scaleto)
        displaybbdiam = params.size_scaleto;
        ud.sizescale = params.size_scaleto/ud.bbdiam;
    end
    if ~isempty(params.thickness_scaleby)
        displaythickrange = ud.thickrange * ud.sizescale * params.thickness_scaleby;
        ud.thicknessscale = params.thickness_scaleby;
        ud.allthickness = [];
    end
    if ~isempty(params.thickness_scaleto)
        sc = params.thickness_scaleto/(ud.sizescale*max(ud.thickrange));
        displaythickrange = ud.sizescale*ud.thickrange*sc;
        ud.thicknessscale = sc;
        ud.allthickness = [];
    end
    if ~isempty(params.thickness_setall)
        displaythickrange = [params.thickness_setall,params.thickness_setall];
        ud.thicknessscale = [];
        ud.allthickness = params.thickness_setall;
    end
    if ~isempty(params.thickness_setmin)
        displaythickrange = max( displaythickrange, params.thickness_setmin );
        ud.thickmin = params.thickness_setmin;
    end

    if min(displaythickrange) < 1
        textcolor = [0.5 0 0];
    elseif min(displaythickrange) < 2
        textcolor = [0.5 0.25 0];
    else
        textcolor = [0 0 0];
    end
    set( handles.text_bbdiam, 'String', sprintf( '%.2f mm', displaybbdiam ) );
    set( handles.text_thickrange, ...
        'String', sprintf( '%.1f ... %.1f mm', displaythickrange ), ...
        'ForegroundColor', textcolor );
    set( handles.figure, 'UserData', ud );

function extractVRMLParam( f )
    dof = ['do_', f];
    params.(dof) = get( handles.(dof), 'Value' );
    if params.(dof)
        params.(f) = getfloat( handles.(f) );
    else
        params.(f) = [];
    end
end
end

function [a,ok] = getfloat( h )
    t = get( h, 'String' );
    [a,c,msg,ind] = sscanf( t, '%f', inf );
    ok = (c==1) && (numel(a)==1);
    if ~ok
        a = [];
    end
end
