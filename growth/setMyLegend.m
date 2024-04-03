function setMyLegend( m )
%setMyLegend( m )
%   Update and draw the legend.
    if isempty( m ), return; end
    
    m.pictures = m.pictures( ishandle( m.pictures ) );
    if isempty( m.pictures ), return; end
    legends = [];
    for i=1:length(m.pictures)
        h = guidata( m.pictures(i) );
        if hashandle( h, 'legend' )
            legends(end+1) = h.legend;
        end
    end
    if isempty( legends )
        complain( 'setMyLegend: no legend handle.' );
        return;
    end
    legend_s = assembleLegend( m );
    nonemptyLegend = ~isempty(legend_s);
    timedFprintf( 1, 'Legend is ''%s''\n', legend_s );
    set( legends, 'String', legend_s, 'Visible', boolchar(nonemptyLegend && m.plotdefaults.drawlegend, 'on', 'off') );
    for i=1:length(legends)
        extent = get( legends(i), 'Extent' );
        pos = get( legends(i), 'Position' );
        set( legends(i), 'Position', ...
            [ pos(1), pos(2) + pos(4) - extent(4), extent([3 4]) ] );
    end
    drawnow;
end

function s = assembleLegend( m )
    template = m.globalProps.legendTemplate;
    s = '';
    ignoring = false;
    i = 1;
    while i < length(template)
        switch template(i)
            case '\'
                i = i+1;
                if ~ignoring
                    switch template(i)
                        case '\'
                            s(end+1) = '\';
                        case 'n'
                            s(end+1) = char(10);
                        case 'r'
                            s(end+1) = char(13);
                        case 't'
                            s(end+1) = char(8);
                        otherwise
                            s(end+1) = template(i);
                    end
                end
            case '%'
                i = i+1;
                if (template(i) >= '0') && (template(i) <= '9')
                    decplaces = template(i) - '0';
                    i = i+1;
                else
                    decplaces = 3;
                end
                switch template(i)
                    case '%'
                        s(end+1) = '%';
                    case 't'
                        s1 = timeString( m, decplaces );
                        ignoring = isempty(s1);
                        s = [s, s1];
                    case 'T'
                        s1 = fullTimeString( m, decplaces );
                        ignoring = isempty(s1);
                        s = [s, s1];
                    case 'q'
                        s1 = quantityString( m );
                        ignoring = isempty(s1);
                        s = [s, s1];
                    case 'm'
                        s1 = mutantString( m );
                        ignoring = isempty(s1);
                        s = [s, s1];
                    otherwise
                        if ~ignoring
                            s(end+1) = template(i);
                        end
                end
            otherwise
                if ~ignoring
                    s(end+1) = template(i);
                end
        end
        i = i+1;
    end
    if i == length(template)
        s(end+1) = template(end);
    end
    s = regexprep( s, '\s+$', '' );
end

function stuffname = quantityString( m )
    if ~isempty( m.plotdefaults.morphogen )
        if ischar( m.plotdefaults.morphogen ) || (length( m.plotdefaults.morphogen )==1)
            stuffname = FindMorphogenName( m, m.plotdefaults.morphogen );
            if isempty(stuffname)
                stuffname = '';
            else
                stuffname = stuffname{1};
            end
        else
            stuffname = 'MULTIPLE';
        end
    elseif ~isempty( m.plotdefaults.outputquantity )
        % Should do this more sensibly.  Split
        % m.plotdefaults.outputquantity into act/spec/resid,
        % growth/bend/aniso, and rate/*.
        p = '^(rotation)(|rate)$';
        xx = regexp( m.plotdefaults.outputquantity, p, 'tokens' );
        if ~isempty(xx)
            stuffname = 'Rotation';
            if ~isempty( xx{1}{2} )
                stuffname = [ stuffname, ' ', xx{1}{2} ];
            end
        else
            p = '^(actual|resultant|specified|residual)(growth|stress|bend|anisotropy|relativeanisotropy)(|rate)$';
            xx = regexp( m.plotdefaults.outputquantity, p, 'tokens' );
            if ~isempty(xx)
                switch xx{1}{1}
                    case { 'actual','resultant'}
                        stuffname = 'Act.';
                    case 'specified'
                        stuffname = 'Spec.';
                    case 'residual'
                        stuffname = 'Resid.';
                    otherwise
                        stuffname = '';
                end
                if strcmp( xx{1}{2}, 'relativeanisotropy' )
                    xx{1}{2} = 'rel.anisotropy';
                end
                stuffname = [stuffname xx{1}{2} ];
                if ~isempty(xx{1}{3})
                    stuffname = [ stuffname, ' ', xx{1}{3} ];
                end
                stuffname = [ stuffname, ' ', m.plotdefaults.outputaxes ];
            else
                % Error.
            end
        end
    else
        stuffname = '';
    end
end

function time_s = timeString( m, decplaces )
    time_s = sprintf( '%.*f', decplaces, m.globalDynamicProps.currenttime );
end

function time_s = fullTimeString( m, decplaces )
    if isempty(m.globalProps.timeunitname)
        time_s = sprintf( 'time %.*f', decplaces, m.globalDynamicProps.currenttime );
    else
        time_s = sprintf( '%.*f %ss', decplaces, m.globalDynamicProps.currenttime, m.globalProps.timeunitname );
    end
end

function mutant_s = mutantString( m )
    mutants = find( m.mutantLevel ~= 1 );
    if isempty( mutants )
        mutant_s = '';
    elseif m.allMutantEnabled
        mutantNames = joinstrings( ' ', m.mgenIndexToName(mutants) );
        mutant_s = ['MUTANT ' lower(mutantNames)];
    else
        mutant_s = 'WILDTYPE';
    end
end
