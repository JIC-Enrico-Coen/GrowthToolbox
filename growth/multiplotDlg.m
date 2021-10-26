function varargout = multiplotDlg(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @multiplotDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @multiplotDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before multiplotDlg is made visible.
function multiplotDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];
    setGUIColors( hObject, backColor, foreColor )

    handles.output = -1;
    guidata(hObject, handles);
    centreDialog(hObject);

    % Insert default values.
    if ~isempty(varargin)
        mgennames = {};
        selectedmgens = [];
        for index = 1:2:(length(varargin)-1)
            if nargin-3==index, break, end
            switch lower(varargin{index})
              case 'morphogens'
                  mgennames = upper(varargin{index+1});
              case 'selected'
                  selectedmgens = upper(varargin{index+1});
            end
        end
        selectedmgenindexes = zeros( 1, length(selectedmgens) );
        for j=1:length(selectedmgens)
            for i=1:length(mgennames)
                if strcmp( selectedmgens{j}, mgennames{i} )
                    selectedmgenindexes(j) = i;
                end
            end
        end
        selectedmgenindexes = selectedmgenindexes(selectedmgenindexes ~= 0);
        set( handles.mgenListbox, ...
             'String', mgennames, ...
             'Value', selectedmgenindexes );
    end

    % Make the GUI modal
    set(handles.figure1,'WindowStyle','modal');

    % UIWAIT makes timeunitDlg wait for user response (see UIRESUME)
    uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = multiplotDlg_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

    % The figure can be deleted now.
    delete(hObject);


function mgenListbox_Callback(hObject, eventdata, handles)

function mgenListbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function selectAllButton_Callback(hObject, eventdata, handles)
    s = get( handles.mgenListbox, 'String' );
    set( handles.mgenListbox, 'Value', 1:length(s) );

function selectNoneButton_Callback(hObject, eventdata, handles)
    set( handles.mgenListbox, 'Value', [] );

