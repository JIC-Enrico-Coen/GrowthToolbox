function [m,movieparamsResult] = getMovieParams( m )
    global GFtboxFigure
    movieparamsResult = [];
    if nargin < 1
        if isempty(GFtboxFigure)
            return;
        end
        handles = guidata(GFtboxFigure);
        if ~isfield(handles,'mesh')
            return;
        end
        m = handles.mesh;
    elseif isempty(m)
        return;
    elseif isempty(m.pictures )
        return;
    else
        handles = guidata( m.pictures(1) );
    end
    picpos = get( m.pictures(1), 'Position' );
    if isempty(picpos)
        return;
    end
    
    picpos = get( m.pictures(1), 'Position' );
    userdata.wp = picpos(3);
    userdata.hp = picpos(4);
    if isfield( handles, 'colorbar' )
        cbpos = get( handles.colorbar, 'Position' );
        userdata.wcb = cbpos(3);
        userdata.hcb = cbpos(4);
    else
        userdata.wcb = 0;
        userdata.hcb = 0;
    end
    userdata.userfixed = 'magnification';
    
    if m.plotdefaults.colorbarinimages
        userdata.w0 = userdata.wp + userdata.wcb;
        userdata.h0 = max( userdata.hp, userdata.hcb );
    else
        userdata.w0 = userdata.wp;
        userdata.h0 = userdata.hp;
    end
    
    initvals = struct( ...
               'includecolorbar', m.plotdefaults.colorbarinimages, ...
                         'width', ceil(userdata.w0 * m.plotdefaults.hiresmagnification), ... % sprintf( '%g', userdata.w0 ), ...
                        'height', ceil(userdata.h0 * m.plotdefaults.hiresmagnification), ... % sprintf( '%g', userdata.h0 ), ...
                 'magnification', m.plotdefaults.hiresmagnification, ...
                     'antialias', m.plotdefaults.hiresantialias, ...
                     'usersnaps', m.plotdefaults.hiressnaps, ...
                    'stagesnaps', m.plotdefaults.hiresstages, ...
                        'movies', m.plotdefaults.hiresmovies );
    
    userdata = setFromStruct( userdata, initvals );
    movieparamsResult = performRSSSdialogFromFile( ...
        findGFtboxFile( 'guilayouts/movieparams.txt' ), ...
        initvals, ...
        userdata, ...
        @(h)setTooBigWarning(h,handles) );
    
    if ~isempty(movieparamsResult)
        m = leaf_plotoptions( m, ...
            'colorbarinimages', logical(movieparamsResult.includecolorbar), ...
            'hiressnaps', logical(movieparamsResult.usersnaps), ...
            'hiresstages',logical( movieparamsResult.stagesnaps), ...
            'hiresmovies', logical(movieparamsResult.movies), ...
            'hiresantialias', logical(movieparamsResult.antialias), ...
            'hiresmagnification', movieparamsResult.userdata.magnification );
    end
end

function setTooBigWarning( fig, handles )
    setGFtboxColourScheme( fig, handles );
    ud = get( fig, 'UserData' );
    big = ud.w0*ud.h0*ud.magnification*(1+ud.antialias) >= 25e6;
    handles1 = guidata( fig );
    set( handles1.X_toobigwarning, 'Visible', boolchar(big,'on','off') );
end

