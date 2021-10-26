function varargout = textdisplayDlg(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @textdisplayDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @textdisplayDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
%if nargin && ischar(varargin{1})
%    gui_State.gui_Callback = str2func(varargin{1});
%end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before textdisplayDlg is made visible.
function textdisplayDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for textdisplayDlg
    handles.output = -1;

    % Update handles structure
    guidata(hObject, handles);

    % Insert default values.
    if ~isempty(varargin)
        for index = 1:2:(length(varargin)-1),
            if nargin-3==index, break, end
            switch lower(varargin{index})
                case 'thetext'
                    set(handles.thetext, 'String', varargin{index+1});
                case 'title'
                    set(hObject, 'Name', varargin{index+1});
                case 'size'
                    figpos = get( hObject, 'Position' );
                    textpos = get( handles.thetext, 'Position' );
                    okpos = get( handles.okButton, 'Position' );
                    delta = varargin{index+1} - figpos([3 4]);
                    figpos([3 4]) = varargin{index+1};
                    textpos([3 4]) = textpos([3 4]) + delta;
                    okpos(1) = (figpos(3) - okpos(3))/2;
                    set(hObject, 'Position', figpos);
                    set(handles.thetext, 'Position', textpos);
                    set(handles.okButton, 'Position', okpos);
            end
        end
    end
  % get(handles.thetext)

    setGUIColors( hObject, [0.4 0.8 0.4], [0.9 1 0.9] );
    centreDialog(hObject);
    
    % Make the GUI modal
    % set(handles.figure1,'WindowStyle','modal');

    % UIWAIT makes textdisplayDlg wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = textdisplayDlg_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    % varargout{1} = handles.output;

    % The figure can be deleted now.
    if ishandle( hObject )
        delete(hObject);
    end
end
