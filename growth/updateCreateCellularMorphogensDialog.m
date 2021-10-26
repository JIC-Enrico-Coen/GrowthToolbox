function updateCreateCellularMorphogensDialog( h )
    if nargin < 1
        h = gcbo;
    end
    handles = guidata( h );
    if strcmp( get( h, 'Type' ), 'uibuttongroup' )
        h = get( h, 'SelectedObject' );
    end
    tag = get( h, 'Tag' );
    if ~isfield( handles, tag )
        % Either the tag is empty, in which case we are not interested in
        % the item, or the item does not belong to the dialog this procedure
        % expects to be called for.  (The latter case should never happen.)
        return;
    end
    
    switch tag
        case 'X_pb_removeselection'
            % Delete the selected elements of the list box
            v = get( handles.lb, 'Value' );
            if ~isempty(v)
                s = get( handles.lb, 'String' );
                if iscell(s)
                    keep = true( length(s), 1 );
                    keep(v) = false;
                    s = { s{keep} };
                else
                    s = {};
                end
                v = min( length(s), 1 + min(v) );
                if v==0, v = []; end
                set( handles.lb, 'String', s, 'Value', v );
            end
            uicontrol( handles.X_ed_mgenname );
        case 'X_ed_mgenname'
            s = get( h, 'String' );
            if ~isempty(s)
                % Combine s with the prefix.
                s = makeValidName( [ get( handles.X_tx_mgenprefix, 'String' ), s ], 1 );
                % Get the list of created morphogens.
                ss = get( handles.lb, 'String' );
                if ischar(ss)
                    if isempty(ss)
                        ss = {};
                    else
                        ss = {ss};
                    end
                end
                % Determine if s is already present.
                found = 1;
                while found <= length(ss)
                    if strcmp( s, ss{found} )
                        break;
                    end
                    found = found+1;
                end
                if found > length(ss)
                    % If s is new, add it at the end of the list and select
                    % it.
                    ss{end+1} = s;
                    set( handles.lb, 'String', ss, 'Value', length(ss) );
                    set( handles.X_ed_mgenname, 'String', '' );
                else
                    % If s exists already, beep.
                    beep;
                end
            end
        otherwise
            if ~isempty( regexp( tag, '^X_rb_type_', 'once' ) )
                % It's a radio button for morphogen type.  Update the
                % morphogen prefix and show or hide the side-selection
                % controls.
                showsubtype = strcmp( tag, 'X_rb_type_id' );
                showstring = boolchar( showsubtype, 'on', 'off' );
                if showsubtype
                    'id_';
                elseif strcmp( tag, 'X_rb_type_other' )
                    mgenprefix = '';
                else
                    mgenprefix = [regexprep( tag, '^X_rb_type_', '' ), '_' ];
                end
                set( handles.X_tx_mgenprefix, 'String', mgenprefix );
                uicontrol( handles.X_ed_mgenname );
            else
                % Ignore other items.
            end
    end
end
